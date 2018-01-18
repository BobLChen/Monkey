package {
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.Quad;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.LutFilter;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.textures.RttTexture;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Input3D;

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
	 * @date   Jul 3, 2015
	 */
	public class Test_LUT extends Test_Unity3DLightmapWithCustomMaterial {
		
		[Embed(source="../assets/lut/changed_lut.png")]
		private var IMG  : Class;
		private var rtt  : Texture3D;
		private var lut  : Bitmap2DTexture; 
		private var quad : Quad;
		
		public function Test_LUT() {
			super();
			
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, onEnterFrame);
		}
		
		private function onCreate(event:Event) : void {
			
			var txt : TextField = new TextField();
			txt.defaultTextFormat = new TextFormat(null, 20, 0xFF0000);
			txt.width = 500;
			txt.text = "ON/OFF PRESS F";
			txt.y = 100;
			this.addChild(txt);
			
			this.rtt = new RttTexture(2048, 2048);
			this.rtt.upload(scene);
			
			this.lut = new Bitmap2DTexture(new IMG().bitmapData);
			this.lut.upload(scene);
			
			var shader : Shader3D = new Shader3D([]);
			shader.addFilter(new LutFilter(this.rtt, this.lut));
			
			this.quad = new Quad(0, 0, 0, 0, true);
			this.quad.material = new Material3D(shader);
			
			this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, onPreRender);
		}
		
		protected function onEnterFrame(event:Event) : void {
			if (Input3D.keyHit(Input3D.F)) {
				if (this.scene.hasEventListener(Scene3D.PRE_RENDER_EVENT)) {
					this.scene.removeEventListener(Scene3D.PRE_RENDER_EVENT, onPreRender);
				} else {
					this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, onPreRender);
				}
			}
		}
		
		protected function onPreRender(event:Event) : void {
			
			this.scene.context.setRenderToTexture(this.rtt.texture, true, 4);
			this.scene.context.clear(0, 0, 0, 1.0);
			this.scene.render();
			this.scene.context.setRenderToBackBuffer();
			
			this.quad.draw(scene, true);
			
			this.scene.skipCurrentRender = true;
		}
		
	}
}
