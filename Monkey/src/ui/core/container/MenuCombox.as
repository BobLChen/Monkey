package ui.core.container {
	
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import ui.core.Style;
	import ui.core.controls.Control;
	import ui.core.controls.InputText;
	import ui.core.event.ControlEvent;

	public class MenuCombox extends Container {
		
		protected static const HEADER_HEIGHT : Number = 15;
		
		protected var _header 	: Sprite;
		protected var _text 	: String = "";
		protected var _open 	: Boolean;
		protected var _input 	: TextField;		
		protected var _box 		: Box;
		
		public function MenuCombox(name : String) {
			super();
			this._box 				= new Box();
			this._box.margins 		= 0;
			this._box.space 		= 0;
			this._box.orientation 	= Box.VERTICAL;
			this._box.y 			= HEADER_HEIGHT;
			this._box.width 		= this.width;
			this._input 			= new TextField();
			var format : TextFormat = new TextFormat("calibri", 12, 0x808080);
			format.align			= TextFormatAlign.CENTER;
			this._input.height 		= HEADER_HEIGHT;
			this._input.defaultTextFormat = format;
			this._input.selectable 	= true;
			this._input.text 		= name;
			this._input.selectable 	= false;
			this._header = new Sprite();
			this._input.mouseEnabled= true;
			this._input.addEventListener(ControlEvent.CLICK, clickHeaderEvent);
			
			this.view.addChild(this._header);
			this.view.addChild(this._input);
			this.view.addChild(this._box.view);
			
			this.open = false;
		}
		
		public function addMenuItem(name : String, callback : Function) : void {
			var inputText : InputText = new InputText(name);
			inputText.textField.selectable = false;
			if (callback != null)
				inputText.addEventListener(MouseEvent.CLICK, callback);
			inputText.addEventListener(MouseEvent.CLICK, close);
			this.addControl(inputText);
		}
		
		protected function close(event:Event) : void {
			this.open = false;			
		}
		
		public function set margins(margin : Number) : void {
			this._box.margins = margin;
			this.draw();
		}
		
		public function get margins() : Number {
			return this._box.margins;
		}
		
		public function set space(space : Number) : void {
			this._box.space = space;
			this.draw();
		}
		
		public function get space() : Number {
			return this._box.space;
		}
		
		private function clickHeaderEvent(e : MouseEvent) : void {
			this.open = !this._open;
		}
		
		public function get open() : Boolean {
			return this._open;
		}
		
		public function set open(value : Boolean) : void {
			this._open = value;
			if (value) {
				this._box.visible = true;
				TweenLite.killTweensOf(this);
				TweenLite.killTweensOf(this._box);
				TweenLite.to(this._box.view, 0.25, {alpha: 1, onComplete: this.completeResizeEvent});
				this.maxHeight = (HEADER_HEIGHT + Math.max(this._box.minHeight, 0));
				this.minHeight = (HEADER_HEIGHT + Math.max(this._box.minHeight, 0));
				this.updateEvent();
				this.dispatchEvent(new ControlEvent(Event.RESIZE, this));
			} else {
				this._box.visible = false;
				TweenLite.killTweensOf(this);
				TweenLite.to(this._box.view, 0.25, {alpha: 0, onComplete: this.completeResizeEvent});
				TweenLite.to(this, 0.25, {minHeight: HEADER_HEIGHT, maxHeight: HEADER_HEIGHT, onUpdate: this.updateEvent, onComplete: this.completeEvent});
			}
		}
		
		private function completeResizeEvent() : void {
			if (this.view.stage) {
				this.view.stage.dispatchEvent(new Event(Event.RESIZE));
				this.view.stage.dispatchEvent(new Event(Event.RESIZE));
			}
		}
		
		private function updateEvent() : void {
			var control : Container = parent;
			while (control != null) {
				control.update();
				control.draw();
				control = control.parent;
			}
		}
		
		private function completeEvent() : void {
			this._box.visible = false;
			this.dispatchEvent(new ControlEvent(Event.RESIZE, this));
		}
		
		override public function removeAllControls() : void {
			this._box.removeAllControls();
		}
		
		override public function get controls() : Vector.<Control> {
			return this._box.controls;
		}
		
		override public function addControl(control : Control) : void {
			this._box.addControl(control);
		}
		
		override public function addControlAt(control : Control, idx : int = 0) : void {
			this._box.addControlAt(control, idx);
		}
		
		override public function removeControl(control : Control) : void {
			this._box.removeControl(control);
		}
		
		override public function update() : void {
			if (this._open) {
				this.minHeight = (HEADER_HEIGHT + this._box.minHeight);
				this.maxHeight = (HEADER_HEIGHT + this._box.minHeight);
			}
			super.update();
		}
		
		override public function set width(value:Number):void {
			super.width 		= value;
			this._input.width 	= this.width;
			this._box.width 	= this.width;
		}
		
		override public function draw():void {
			this._box.update();
			this._box.draw();
			this._header.graphics.clear();
			this._header.graphics.lineStyle(1, Style.borderColor2, 1, true);
			this._header.graphics.beginFill(Style.backgroundColor2);
			this._header.graphics.drawRoundRect(0, 0, width, HEADER_HEIGHT, 12);
		}
				
	}
}
