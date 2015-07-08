package {
	import flash.display.BitmapData;
	import flash.events.Event;
	
	import monkey.core.entities.Quad;
	import monkey.core.materials.DiffuseMaterial;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.BlurFilter;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.textures.RttTexture;
	import monkey.core.textures.Texture3D;

	/**
	 *　　　　　　　　┏┓　　　┏┓+ +
	 *　　　　　　　┏┛┻━━━┛┻┓ + +
	 *　　　　　　　┃　　　　　　　┃ 　
	 *　　　　　　　┃　　　━　　　┃ ++ + + +
	 *　　　　　　 ████━████ ┃+
	 *　　　　　　　┃　　　　　　　┃ +
	 *　　　　　　　┃　　　┻　　　┃
	 *　　　　　　　┃　　　　　　　┃ + +
	 *　　　　　　　┗━┓　　　┏━┛
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + + + +
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + 　　　　　　
	 *　　　　　　　　　┃　　　┃
	 *　　　　　　　　　┃　　　┃　　+　　　　　　　　　
	 *　　　　　　　　　┃　 　　┗━━━┓ + +
	 *　　　　　　　　　┃ 　　　　　　　┣┓
	 *　　　　　　　　　┃ 　　　　　　　┏┛
	 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
	 *　　　　　　　　　　┃┫┫　┃┫┫
	 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
	 * @author Neil
	 * @date   Jul 7, 2015
	 */
	public class BlurDarkTask {
		
		/** 原图rtt */
		private var rtt  		: Texture3D;				
		/** 暗度图 */
		private var drak  		: Bitmap2DTexture;
		/** 渐变图 */
		private var grad		: Bitmap2DTexture;
		/** 最终显示 */
		private var finalQuad 	: Quad;
		/** 以1/4尺寸重绘场景rtt */
		private var downQuad	: Quad;
		/** 水平模糊rtt */		
		private var hblurTex	: Texture3D;
		/** 水平模糊quad */
		private var hblurQuad	: Quad;
		/** 纵向模糊rtt */
		private var vblurTex	: Texture3D;
		/** 纵向模糊quad */
		private var vblurQuad	: Quad;
		/** 模糊rtt */
		private var blurTex		: Texture3D;		
		/** 场景 */
		private var scene 		: Scene3D;
		
		private var _enabled	: Boolean;
		private var _disposed	: Boolean;
		
		/**
		 * 初始化scene完成只会才能创建Task
		 * 确保3D的viewport尺寸正确 
		 * @param scene	
		 * @param drakbmp	暗度图(用于制作明暗区域)
		 * @param gradbmp	渐变图(用于制作模糊区域)
		 * 
		 */		
		public function BlurDarkTask(scene : Scene3D, darkbmp : BitmapData, gradbmp : BitmapData) {
			this.scene = scene;
			// 原图
			this.rtt  = new RttTexture(2048, 2048);
			this.rtt.upload(scene);
			// 暗度图
			this.drak = new Bitmap2DTexture(darkbmp);
			this.drak.upload(scene);
			// 渐变图
			this.grad = new Bitmap2DTexture(gradbmp);
			this.grad.upload(scene);
			// downfilter
			this.downQuad  = new Quad(0, 0, 0, 0, true);
			this.downQuad.material = new DiffuseMaterial(this.rtt);
			// 水平模糊
			this.hblurTex  = new RttTexture(256, 256);
			this.hblurTex.upload(scene);
			this.hblurQuad = new Quad(0, 0, 0, 0, true);
			this.hblurQuad.material  = new Material3D(new Shader3D([new BlurFilter(hblurTex, 4 / scene.viewPort.width, 0)]));
			// 纵向模糊
			this.vblurTex	= new RttTexture(256, 256);
			this.vblurTex.upload(scene);
			this.vblurQuad	= new Quad(0, 0, 0, 0, true);
			this.vblurQuad.material  = new Material3D(new Shader3D([new BlurFilter(vblurTex, 0, 4 / scene.viewPort.height)]));
			// 最终高斯模糊texture
			this.blurTex 	= new RttTexture(256, 256);
			this.blurTex.upload(scene);			
			// 最终显示
			this.finalQuad = new Quad(0, 0, 0, 0, true);
			this.finalQuad.material = new Material3D(new Shader3D([new GradingFilter(this.rtt, this.vblurTex, this.drak, this.grad)]));
		}
		
		/**
		 * 是否被销毁 
		 * @return 
		 * 
		 */		
		public function get disposed():Boolean {
			return _disposed;
		}

		public function set enable(value : Boolean) : void {
			if (this.disposed) {
				return;
			}
			this._enabled = value;
			if (value) {
				this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, 	onPreRender);
			} else {
				this.scene.removeEventListener(Scene3D.PRE_RENDER_EVENT, onPreRender);
			}
		}
		
		public function get enable() : Boolean {
			return this._enabled;
		}
		
		private function onPreRender(event:Event) : void {
			// 将整个场景渲染到rtt
			this.scene.context.setRenderToTexture(this.rtt.texture, true, 4);
			this.scene.context.clear(0, 0, 0, 1.0);
			this.scene.render();
			this.scene.context.setRenderToBackBuffer();
			// 以1/4尺寸绘制到hblurTex
			this.scene.context.setRenderToTexture(this.hblurTex.texture, true, 4);
			this.scene.context.clear(0, 0, 0, 1.0);
			this.downQuad.draw(scene);
			this.scene.context.setRenderToBackBuffer();
			// 进行横向高斯模糊
			this.scene.context.setRenderToTexture(this.vblurTex.texture, true, 4);
			this.scene.context.clear(0, 0, 0, 1.0);
			this.hblurQuad.draw(scene);
			this.scene.context.setRenderToBackBuffer();
			// 进行纵向高斯模糊
			this.scene.context.setRenderToTexture(this.blurTex.texture, true, 4);
			this.scene.context.clear(0, 0, 0, 1.0);
			this.vblurQuad.draw(scene);
			this.scene.context.setRenderToBackBuffer();
			// 显示。。。
			this.finalQuad.draw(scene, true);
			this.scene.skipCurrentRender = true;
		}
		
		public function dispose() : void {
			this.enable = false;
			
			this.rtt.dispose();
			this.drak.dispose();
			this.grad.dispose();
			this.hblurTex.dispose();
			this.vblurTex.dispose();
			this.blurTex.dispose();
			
			this.downQuad.dispose();
			
			this.hblurQuad.material.shader.dispose();
			this.hblurQuad.dispose();
			
			this.vblurQuad.material.shader.dispose();
			this.vblurQuad.dispose();
			
			this.finalQuad.material.shader.dispose();
			this.finalQuad.dispose();
			
			this._disposed = true;
		}
		
	}
}


import monkey.core.base.Surface3D;
import monkey.core.shader.filters.Filter3D;
import monkey.core.shader.utils.FsRegisterLabel;
import monkey.core.shader.utils.ShaderRegisterCache;
import monkey.core.shader.utils.ShaderRegisterElement;
import monkey.core.textures.Texture3D;

/**
 * 模拟景深 
 * @author Neil
 * 
 */
class GradingFilter extends Filter3D {
	
	private var rttLabel  : FsRegisterLabel;
	private var blurLabel : FsRegisterLabel;
	private var darkLabel : FsRegisterLabel;
	private var gradLabel : FsRegisterLabel;
	
	/**
	 * 透明度表示模糊
	 * 颜色表示亮度
	 * @param rtt		rtt贴图
	 * @param blur		模糊图
	 * @param dark		明暗图
	 * @param grad		渐变图
	 */	
	public function GradingFilter(rtt : Texture3D, blur : Texture3D, dark : Texture3D, grad : Texture3D) : void {
		this.rttLabel  = new FsRegisterLabel(rtt);
		this.blurLabel = new FsRegisterLabel(blur);
		this.darkLabel = new FsRegisterLabel(dark);
		this.gradLabel = new FsRegisterLabel(grad);
	}
	
	public function set rtt(value : Texture3D) : void {
		this.rttLabel.texture = value;
	}
	
	public function get rtt() : Texture3D {
		return this.rttLabel.texture;
	}
	
	public function set dark(value : Texture3D) : void {
		this.gradLabel.texture = value;
	}
	
	public function get dark() : Texture3D {
		return this.gradLabel.texture;
	}
	
	override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
		var fs0  : ShaderRegisterElement = regCache.getFs(rttLabel);
		var fs1  : ShaderRegisterElement = regCache.getFs(blurLabel);
		var fs2  : ShaderRegisterElement = regCache.getFs(darkLabel);
		var fs3  : ShaderRegisterElement = regCache.getFs(gradLabel);
		
		var ft0  : ShaderRegisterElement = regCache.getFt();
		var ft1  : ShaderRegisterElement = regCache.getFt();
		var ft2  : ShaderRegisterElement = regCache.getFt();
		var ft3  : ShaderRegisterElement = regCache.getFt();
		
		var code : String = "";
		// 原图采样
		code += "tex " + ft0 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs0 + " <2d, linear, mipnone, repeat> \n";
		// 模糊图采样
		code += "tex " + ft1 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs1 + " <2d, linear, mipnone, repeat> \n";
		// 暗度图采样
		code += "tex " + ft2 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs2 + " <2d, linear, mipnone, repeat> \n";
		// 渐变图采样
		code += "tex " + ft3 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs3 + " <2d, linear, mipnone, repeat> \n";
		// 渐变图
		
		// 1 - 渐变
		code += "sub " + ft3 + ".y, " + regCache.fc0123 + ".y, " + ft3 + ".x \n";
		// (1 - 渐变) * 模糊
		code += "mul " + ft1 + ".xyz, " + ft1 + ".xyz, " + ft3 + ".y \n";
		// 渐变 * 原图
		code += "mul " + ft0 + ".xyz, " + ft0 + ".xyz, " + ft3 + ".x \n";
		// add
		code += "add " + ft0 + ".xyz, " + ft0 + ".xyz, " + ft1 + ".xyz \n";
		// 变暗
		code += "mul " + ft0 + ".xyz, " + ft0 + ".xyz, " + ft2 + ".x \n";
		
		code += "mov " + regCache.oc + ", " + ft0 + " \n";
		
		regCache.removeFt(ft0);
		regCache.removeFt(ft1);
		regCache.removeFt(ft2);
		regCache.removeFt(ft3);
				
		return code;
	}
	
}