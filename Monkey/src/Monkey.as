package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import ide.Studio;
	
	public class Monkey extends Sprite {
		
		public function Monkey() {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.addChild(new Studio());
			this.stage.nativeWindow.maximize(); 
		}
		
	}
}
