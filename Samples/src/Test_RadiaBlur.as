package {
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.Quad;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.RadiaBlurFilter;
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
	 * @date   Jul 7, 2015
	 */
	public class Test_RadiaBlur extends Test_Unity3DLightmapWithCustomMaterial {
		
		private var task : BlurDarkTask;
		
		[Embed(source="../assets/grad/黑遮罩图.jpg")]
		private var IMG_DARK  	: Class;
		[Embed(source="../assets/grad/模糊遮罩图b.png")]
		private var IMG_GRAD	: Class;
		
		public function Test_RadiaBlur() {
			super();
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, onEnterFrame);
		}
		
		
		private var quad : Quad;
		private var rtt  : Texture3D;
		
		private function onCreate(event:Event) : void {
			
			var txt : TextField = new TextField();
			txt.defaultTextFormat = new TextFormat(null, 20, 0xFF0000);
			txt.width = 500;
			txt.text = "ON/OFF PRESS F";
			txt.y = 100;
			this.addChild(txt);
			
			this.quad = new Quad(0, 0, 0, 0, true);
			this.rtt  = new RttTexture(2048, 2048);
			this.quad.material = new Material3D(new Shader3D([new RadiaBlurFilter(this.rtt)]));
			
			this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, onPreRenderer);
		}
		
		protected function onPreRenderer(event:Event) : void {
			// 将整个场景渲染到rtt
			this.scene.context.setRenderToTexture(this.rtt.texture, true, 4);
			this.scene.context.clear(0, 0, 0, 1.0);
			this.scene.render();
			this.scene.context.setRenderToBackBuffer();
			// draw
			this.quad.draw(scene, true);
			this.scene.skipCurrentRender = true;
		}
		
		protected function onEnterFrame(event:Event) : void {
			if (Input3D.keyHit(Input3D.F)) {
				this.task.enable = !this.task.enable;
			} else if (Input3D.keyHit(Input3D.G)) {
				this.task.dispose();
			}
		}
		
	}
}