package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.utils.Dictionary;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.materials.UnityLightmapDiffuseMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Input3D;
	
	/**
	 * Bloom特效 
	 * @author Neil
	 * 
	 */	
	public class Test_Bloom extends Sprite { 
		
		private var scene: Scene3D;
		private var cfg : Object;
		private var res : String;
		
		private var meshPool : Dictionary = new Dictionary();
		private var texturePool : Dictionary = new Dictionary();
		
		private var task : BloomTask;
		
		public function Test_Bloom() {
			super(); 
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.stage.addChild(new FPSStats());
			
			this.scene = new Viewer3D(this);
			this.scene.camera.far = 10000;
			this.scene.camera.transform.z = -500;
			this.scene.autoResize = true; 
			
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
		}
		
		public static function dirName(path : String, up : int = 0) : String {
			var parts : Array = path.split("/");
			parts = parts.slice(0, parts.length - up - 1);
			return parts.join("/");
		}
		
		protected function onCreate(event:Event) : void {
//			this.res = dirName(this.loaderInfo.url) + "/../assets/Test_09/";
//			var url : String = this.res + "scene.lightmap"
//			// 加载配置文件
//			var loader : URLLoader = new URLLoader();
//			loader.dataFormat = URLLoaderDataFormat.TEXT;
//			loader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
//			loader.load(new URLRequest(url));
			
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, onUpdate);
			
			for (var i:int = 0; i < 10; i++) {
				for (var j:int = 0; j < 10; j++) {
					var color : Color = i % 2 == 0 ? Color.GRAY : Color.WHITE;
					var obj : Object3D = new Object3D();
					obj.addComponent(new MeshRenderer(new Cube(), new ColorMaterial(color)));
					obj.transform.x = (i - 5) * 20;
					obj.transform.y = (j - 5) * 20;
					this.scene.addChild(obj);
				}
			}
			
			// 启用Bloom效果
			this.task = new BloomTask(this.scene); 
			this.task.enable();
		}
		
		private function onUpdate(event:Event) : void {
			// 开关bloom特效
			if (Input3D.keyHit(Input3D.SPACE)) {
				if (this.task.enabled) {
					this.task.disable();
				} else {
					this.task.enable();
				}
			}
			if (Input3D.keyDown(Input3D.Q)) {
				this.scene.camera.transform.translateY(1);
			} else if (Input3D.keyDown(Input3D.E)) {
				this.scene.camera.transform.translateY(-1);
			}
			if (Input3D.keyDown(Input3D.W)) {
				this.scene.camera.transform.translateZ(1);
			} else if (Input3D.keyDown(Input3D.S)) {
				this.scene.camera.transform.translateZ(-1);
			}
			if (Input3D.keyDown(Input3D.A)) {
				this.scene.camera.transform.translateX(-1);
			} else if (Input3D.keyDown(Input3D.D)) {
				this.scene.camera.transform.translateX(1);
			}
		}
		
		private function onConfigLoadComplete(event:Event) : void {
			trace("配置文件载入完成...");
			var loader : URLLoader = event.target as URLLoader;
			this.cfg = JSON.parse(loader.data);
			for each (var obj : Object in this.cfg.scene) {
				var root : Object3D = this.createObject(obj);
				this.scene.addChild(root);
			}
			this.scene.transform.updateTransforms(true);
		}
		
		public function getMesh(name : String) : UMesh {
			if (meshPool[name]) {
				return meshPool[name];
			}
			var mesh : UMesh = new UMesh(this.res + name + ".mesh");
			meshPool[name] = mesh;
			return mesh;
		}
		
		public function getTetxure(name : String) : UTexture {
			if (texturePool[name]) {
				return texturePool[name];
			}
			var texture : UTexture = new UTexture(this.res + name.replace("psd", "jpg"));
			texturePool[name] = texture;
			return texture;
		}
		
		private function createObject(config : Object) : Object3D {
			var obj : Object3D = new Object3D();
			obj.name = config.name;
			obj.setLayer(config.layer);
			obj.transform.setPosition(config.pos[0], config.pos[1], config.pos[2]);
			obj.transform.setScale(config.scale[0], config.scale[1], config.scale[2]);
			obj.transform.setRotation(config.rotation[0], config.rotation[1], config.rotation[2]);
			
			if (config.MainTexture && config.Mesh && config.lightmap) {
				obj.addComponent(
					new MeshRenderer(getMesh(config.Mesh),
						new UnityLightmapDiffuseMaterial(
							getTetxure(config.MainTexture),
							getTetxure(config.lightmap + ".png"),
							new Vector3D(config.tilingOffset[0], config.tilingOffset[1], config.tilingOffset[2], config.tilingOffset[3])
						))
				);
				// Mesh加载完成之后需要充值一下transform
				// BUG:
				(obj.renderer.mesh as UMesh).addEventListener(Event.COMPLETE, function(e : Event):void{
					obj.transform.updateTransforms(false);
				});
			}
			
			for each (var child : Object in config.children) {
				obj.addChild(this.createObject(child));
			}
			
			trace("创建GameObject", obj.name, config.scale);
			return obj;
		}
		
	}
}
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import monkey.core.base.Surface3D;
import monkey.core.entities.Mesh3D;
import monkey.core.entities.Quad;
import monkey.core.materials.Material3D;
import monkey.core.scene.Scene3D;
import monkey.core.shader.Shader3D;
import monkey.core.shader.filters.BloomExtractFilter;
import monkey.core.shader.filters.BlurFilter;
import monkey.core.shader.filters.CombineFilter;
import monkey.core.shader.filters.TextureMapFilter;
import monkey.core.textures.Bitmap2DTexture;
import monkey.core.textures.RttTexture;
import monkey.core.utils.Mesh3DUtils;
import monkey.core.utils.Texture3DUtils;

class BloomTask {
	
	private var scene : Scene3D;
	private var _enabled : Boolean;
	
	/** 原图Texture */
	private var originalTexture 	: RttTexture;
	private var originalQuad 		: Quad;
	/** 亮色Texture */
	private var brightnessTexture	: RttTexture;
	private var brightnessQuad	 	: Quad;
	/** 横向高斯模糊 */
	private var hblurTexture		: RttTexture;
	private var hblurQuad			: Quad;
	/** 纵向高斯模糊 */
	private var vblurTexture		: RttTexture;
	private var vblurQuad			: Quad;
	/** 最终结果 */
	private var finalTexture		: RttTexture;
	private var finalQuad			: Quad;
	
	public function BloomTask(scene : Scene3D) : void {
		this.scene = scene;
		// 因为是后期渲染，材质一般都是整个场景只有一个，因此可以不用为了优化shader而使用单例的Shader模式
		// 原图RTT
		originalTexture 	= new RttTexture(2048, 2048);
		originalQuad		= new Quad(0, 0, 0, 0, true);
		originalQuad.material = new Material3D(new Shader3D([new TextureMapFilter(originalTexture)]));
		// 亮色RTT
		brightnessTexture	= new RttTexture(256, 256);
		brightnessQuad    	= new Quad(0, 0, 0, 0, true);
		brightnessQuad.material = new Material3D(new Shader3D([new BloomExtractFilter(brightnessTexture, 1.0 / scene.viewPort.width, 1.0 / scene.viewPort.height, 0.5)]));
		// hblur
		hblurTexture		= new RttTexture(256, 256);
		hblurQuad			= new Quad(0, 0, 0, 0, true);
		hblurQuad.material  = new Material3D(new Shader3D([new BlurFilter(hblurTexture, 8 / scene.viewPort.width, 0)]));
		// vblue
		vblurTexture		= new RttTexture(256, 256);
		vblurQuad			= new Quad(0, 0, 0, 0, true);
		vblurQuad.material  = new Material3D(new Shader3D([new BlurFilter(vblurTexture, 0, 8 / scene.viewPort.height)]));
		// final
		finalTexture		= new RttTexture(2048, 2048);
		finalQuad			= new Quad(0, 0, 0, 0, true);
		finalQuad.material  = new Material3D(new Shader3D([new CombineFilter(originalTexture, finalTexture, 3.0)]));
	}
	
	public function get enabled():Boolean {
		return _enabled;
	}

	public function enable() : void {
		this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, onPreRenderer);
		this._enabled = true;
	}
	
	private function onPreRenderer(event:Event) : void {
		// 将场景的所有模型全部渲染到originalTexture贴图
		this.scene.context.setRenderToTexture(originalTexture.texture, true, scene.antialias);
		this.scene.context.clear(0, 0, 0, 1);
		this.scene.render();
		this.scene.context.setRenderToBackBuffer();
		// 对originalTexture贴图进行提取亮色保存到brightnessTexture
		this.scene.context.setRenderToTexture(brightnessTexture.texture, true, scene.antialias);
		this.scene.context.clear(0, 0, 0, 1.0);
		this.originalQuad.draw(this.scene);
		this.scene.context.setRenderToBackBuffer();
		// 对brightnessTexture贴图进行横向高斯模糊
		this.scene.context.setRenderToTexture(hblurTexture.texture, true, scene.antialias);
		this.scene.context.clear(0, 0, 0, 1);
		this.brightnessQuad.draw(this.scene);
		this.scene.context.setRenderToBackBuffer();
		// 对hblurTexture题图进行纵向高斯模糊
		this.scene.context.setRenderToTexture(vblurTexture.texture, true, scene.antialias);
		this.scene.context.clear(0, 0, 0, 1);
		this.hblurQuad.draw(this.scene);
		this.scene.context.setRenderToBackBuffer();
		// 将hblurTexture和originalTexture融合到一起
		this.scene.context.setRenderToTexture(finalTexture.texture, true, scene.antialias);
		this.scene.context.clear(0, 0, 0, 1);
		this.vblurQuad.draw(this.scene);
		this.scene.context.setRenderToBackBuffer();
		// 绘制融合之后的贴图
		this.finalQuad.draw(this.scene);
		// 因此已经拥有了整个场景的图像，因此不在需要再次渲染场景
		this.scene.skipCurrentRender = true;
	}
	
	public function disable() : void {
		this.scene.removeEventListener(Scene3D.PRE_RENDER_EVENT, onPreRenderer);	
		this._enabled = false;
	}
	
}

class UMesh extends Mesh3D {
	
	private var _loaded : Boolean;
	private var url : String;
	
	public function UMesh(url : String) : void {
		super([]);
		this.url = url;
		this.load();
	}
	
	public function get loaded():Boolean {
		return _loaded;
	}
	
	private function load() : void {
		var loader : URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, loadComplete);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		loader.load(new URLRequest(this.url));
	}
	
	private function onIoError(event:IOErrorEvent) : void {
		trace(event);
		this.dispatchEvent(event);
	}
	
	private function loadComplete(event:Event) : void {
		var mesh : Mesh3D = Mesh3DUtils.readMesh((event.target as URLLoader).data as ByteArray);
		this.surfaces = mesh.surfaces;
		if (!mesh.surfaces[0].formats[Surface3D.UV1]) {
			this.surfaces = Vector.<Surface3D>([]);
		}
		this._loaded = true;
		this.bounds = mesh.bounds;
		this.dispatchEvent(event);
	}
	
} 

class UTexture extends Bitmap2DTexture {
	
	private var _loaded : Boolean;
	private var loader : Loader;
	private var url : String;
	
	public function UTexture(url : String) : void {
		super(Texture3DUtils.nullBitmapData);
		this._loaded = false;
		this.url = url;
		this.load();
	}
	
	private function load() : void {
		this.loader = new Loader();
		this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
		this.loader.load(new URLRequest(this.url));
	}
	
	private function onIoError(event:IOErrorEvent) : void {
		trace(event);
		this.dispatchEvent(event);
	}
	
	private function onLoadComplete(event:Event) : void {
		this.bitmapData = (this.loader.content as Bitmap).bitmapData;
		this._loaded = true;
		this.dispatchEvent(event);
	}
	
	public function get loaded():Boolean {
		return _loaded;
	}
	
}
