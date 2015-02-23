package ui.core.controls {
	
	import flash.display.DisplayObject;

	public class DisplayView extends Control {
		
		private var _display : DisplayObject;
				
		public function DisplayView(display : DisplayObject) {
			super("DisplayView", 0, 0, _display.width, _display.height);
			this._display 	= display;
			this.view.addChild(this._display);
			this.minWidth	= _display.width;
			this.minHeight 	= _display.height;
			this.maxWidth 	= _display.width;
			this.maxHeight 	= _display.height;
		}
		
		public function scale(value : Number) : void {
			this._display.scaleX += value;
			this._display.scaleY += value;
		}
		
		override public function get height():Number {
			return _display.height;
		}
		
		override public function set height(value:Number):void {
			
		}
		
		override public function get width():Number {
			return _display.width;
		}
		
		override public function set width(value:Number):void {
			
		}
		
	}
}
