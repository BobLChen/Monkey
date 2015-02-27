package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	
	public class Monkey extends Sprite {
		
		public function Monkey() {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
//			this.addChild(new Studio());	
			this.stage.nativeWindow.maximize();
			
			var sprite : Sprite = new Sprite();
			sprite.graphics.beginFill(0xFF0000);
			sprite.graphics.drawRect(0, 0, 100, 100);
			addChild(sprite);
			
			sprite.addEventListener(MouseEvent.CLICK, onClick);
			
			this.stage.addEventListener(MouseEvent.CLICK, lickStage);
		}
		
		protected function lickStage(event:MouseEvent) : void {
			trace("click stage");			
			trace(event.target == this.stage);			
		}
		
		protected function onClick(event:MouseEvent) : void {
			trace("click");			
		}
		
	}
}
