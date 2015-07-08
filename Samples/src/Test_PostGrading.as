package {
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import monkey.core.base.Object3D;
	import monkey.core.scene.Scene3D;
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
	public class Test_PostGrading extends Test_Unity3DLightmapWithCustomMaterial {
		
		private var task : BlurDarkTask;
		
		[Embed(source="../assets/grad/黑遮罩图.jpg")]
		private var IMG_DARK  	: Class;
		[Embed(source="../assets/grad/模糊遮罩图b.png")]
		private var IMG_GRAD	: Class;
		
		public function Test_PostGrading() {
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
			
			this.task = new BlurDarkTask(this.scene, new IMG_DARK().bitmapData, new IMG_GRAD().bitmapData);
			this.task.enable = true;
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