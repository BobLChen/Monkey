package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
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
		
		protected function onCreate(event:Event) : void {
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
		
	}
}
import flash.events.Event;

import monkey.core.entities.Quad;
import monkey.core.materials.Material3D;
import monkey.core.scene.Scene3D;
import monkey.core.shader.Shader3D;
import monkey.core.shader.filters.BloomExtractFilter;
import monkey.core.shader.filters.BlurFilter;
import monkey.core.shader.filters.CombineFilter;
import monkey.core.shader.filters.TextureMapFilter;
import monkey.core.textures.RttTexture;

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
