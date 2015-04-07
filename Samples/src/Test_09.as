package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import monkey.core.base.Object3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Input3D;
	
	public class Test_09 extends Sprite { 
		
		private var scene: Scene3D;
		private var cfg : Object;
		private var res : String;
		
		private var meshPool : Dictionary = new Dictionary();
		private var texturePool : Dictionary = new Dictionary();
		
		public function Test_09() {
			super(); 
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.stage.addChild(new FPSStats());
			
			this.scene = new Viewer3D(this);
			this.scene.camera.far = 10000;
			this.scene.camera.transform.z = -1;
			this.scene.autoResize = true; 
						
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
		}
		
		public static function dirName(path : String, up : int = 0) : String {
			var parts : Array = path.split("/");
			parts = parts.slice(0, parts.length - up - 1);
			return parts.join("/");
		}
		
		protected function onCreate(event:Event) : void {
			this.scene.context.enableErrorChecking = true;		
			
			this.res = dirName(this.loaderInfo.url) + "/../assets/Test_09/";
			var url : String = this.res + "scene.lightmap"
			// 加载配置文件
			var loader : URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onConfigLoadComplete);
			loader.load(new URLRequest(url));
				
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, onUpdate);
		}
		
		private function onUpdate(event:Event) : void {
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
					new LightmapMaterial(
						getTetxure(config.MainTexture),
						getTetxure(config.lightmap + ".png"),
						new Vector3D(config.tilingOffset[0], config.tilingOffset[1], config.tilingOffset[2], config.tilingOffset[3])
					))
				);
			}
			
			for each (var child : Object in config.children) {
				obj.addChild(this.createObject(child));
			}
			
			trace("创建GameObject", obj.name);
			return obj;
		}
		
	}
}
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Vector3D;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import monkey.core.base.Surface3D;
import monkey.core.entities.Mesh3D;
import monkey.core.materials.DiffuseMaterial;
import monkey.core.materials.shader.DiffuseShader;
import monkey.core.scene.Scene3D;
import monkey.core.shader.filters.Filter3D;
import monkey.core.shader.utils.FcRegisterLabel;
import monkey.core.shader.utils.FsRegisterLabel;
import monkey.core.shader.utils.ShaderRegisterCache;
import monkey.core.shader.utils.ShaderRegisterElement;
import monkey.core.textures.Bitmap2DTexture;
import monkey.core.textures.Texture3D;
import monkey.core.utils.Mesh3DUtils;
import monkey.core.utils.Texture3DUtils;

class U3DLightmapFilter extends Filter3D {
	
	private var _data : Vector.<Number>;
	private var _label : FsRegisterLabel;
	
	public function U3DLightmapFilter() : void {
		this.priority = 14;
		this._data = Vector.<Number>([1, 1, 0, 0]);
		this._label = new FsRegisterLabel(null);
	}
	
	public function set texture(value:Texture3D):void {
		this._label.texture = value;
	}
	
	public function set tilingOffset(value : Vector3D) : void {
		this._data[0] = value.x;
		this._data[1] = value.y;
		this._data[2] = value.z;
		this._data[3] = value.w;
	}
	
	override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
		
		var bias : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_data));
		var temp : ShaderRegisterElement = regCache.getFt();
		var fs0  : ShaderRegisterElement = regCache.getFs(this._label);
		var intensity : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(Vector.<Number>([2.0, 0, 0, 0])));
		
		var code : String = "";
		
		if (agal) {
			// scale
			code += "mul " + temp + ".xy, " + regCache.getV(Surface3D.UV1) + ".xy, " + bias + ".xy\n";
			code += "add " + temp + ".xy, " + temp + ".xy, " + bias + ".zw \n";
			// opengl vs dx=> 1-uv.y
			code += "sub " + temp + ".y, " + regCache.fc0123 + ".y, " + temp + ".y \n";
			code += "tex " + temp + ", " + temp + ".xy, " + fs0 + description(this._label.texture);
			code += "mul " + temp + ", " + temp + ", " + intensity + ".x \n";
			code += "mul " + regCache.oc + ", " + regCache.oc + ", " + temp + " \n";
		}
		
		regCache.removeFt(temp);
		return code;
	}
	
}

class LightmapShader extends DiffuseShader {
	
	private static var _instance : LightmapShader;
	
	private var filter : U3DLightmapFilter;
		
	public function LightmapShader() : void {
		this.filter = new U3DLightmapFilter();
		this.addFilter(this.filter);
	}
	
	public function set tilingOffset(value : Vector3D) : void {
		this.filter.tilingOffset = value;
	}
	
	public function set lightmap(value : Texture3D) : void {
		this.filter.texture = value;
	}
	
	public static function get instance() : LightmapShader {
		if (!_instance) {
			_instance = new LightmapShader();
		}
		return _instance;
	}
	
}

class LightmapMaterial extends DiffuseMaterial {
	
	private var _lightmap : Texture3D;
	private var _tilingOffset : Vector3D;
	
	public function LightmapMaterial(texture : Texture3D, lightmap : Texture3D, tilingOffset : Vector3D) : void {
		super(texture);
		this._shader = LightmapShader.instance;
		this.lightmap = lightmap;
		this.tilingOffset = tilingOffset;
	}
	
	override public function updateMaterial(scene:Scene3D):void {
		LightmapShader(shader).texture = this.texture;	
		LightmapShader(shader).tillingOffset(repeatX, repeatY, offsetX, offsetY);
		LightmapShader(shader).tilingOffset = this.tilingOffset;
		LightmapShader(shader).lightmap = this.lightmap;
	}
	
	public function get tilingOffset():Vector3D {
		return _tilingOffset;
	}

	public function set tilingOffset(value:Vector3D):void {
		_tilingOffset = value;
	}

	public function get lightmap():Texture3D {
		return _lightmap;
	}

	public function set lightmap(value:Texture3D):void {
		_lightmap = value;
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
	}
	
	public function get loaded():Boolean {
		return _loaded;
	}

}
