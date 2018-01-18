package ui.core.controls {

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	import ui.core.Style;
	import ui.core.event.ControlEvent;
	
	/**
	 * 文本框 
	 * @author Neil
	 * 
	 */	
	public class InputText extends Control {
		
		private var _input 			: TextField;
		private var _vScroll 		: Slider;
		private var _skipScrollEvent: Boolean;
		private var _changed 		: Boolean;
		
		/**
		 * 输入框 
		 * @param txt
		 * @param multiline
		 * 
		 */		
		public function InputText(txt : String = "", multiline : Boolean = false) {
			super("", x, y, 80, 20);
			this._input = new TextField();
			this._input.defaultTextFormat = new TextFormat("calibri", 12, 0x808080);
			this._input.selectable = true;
			this._input.type = TextFieldType.INPUT;
			this._input.text = txt;
			this._input.addEventListener(Event.CHANGE, 			this.changeEvent, false, 0, true);
			this._input.addEventListener(Event.SCROLL, 			this.scrollEvent, false, 0, true);
			this._input.addEventListener(FocusEvent.FOCUS_IN, 	this.focusInEvent);
			this._input.addEventListener(FocusEvent.FOCUS_OUT, 	this.focusOutEvent);
			this._input.addEventListener(KeyboardEvent.KEY_UP, 	this.keyUpEvent);
			
			this.view.addChild(this._input);
			this.height 	= 18;
			this.multiline 	= multiline;
			this.flexible 	= 1;
			this.minHeight 	= 18;
			this.minWidth 	= 40;
			if (!multiline) {
				this.maxHeight = 18;
			}
		}
		
		private function keyUpEvent(e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.ENTER) {
				this._input.stage.focus = null;
			}
		}

		private function focusOutEvent(e : FocusEvent) : void {
			this.view.filters = null;
			this.draw();
		}

		private function focusInEvent(e : FocusEvent) : void {
			this._changed = false;
			this.view.filters = Style.focusFilter;
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CLICK, this));
		}

		private function changeEvent(e : Event) : void {
			if (!this._changed) {
				this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
			}
			this._changed = true;
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		public function get text() : String {
			return this._input.text;
		}

		public function set text(txt : String) : void {
			this._input.text = txt;
			this.draw();
		}

		public function get multiline() : Boolean {
			return this._input.multiline;
		}

		public function set multiline(value : Boolean) : void {
			if (value) {
				this._vScroll = new Slider();
				this._vScroll.addEventListener(ControlEvent.CHANGE, this.scrollBarEvent, false, 0, true);
				this.view.addChild(this._vScroll.view);
				this.minHeight = 30;
			} else if (this._vScroll) {
				this.view.removeChild(this._vScroll.view);
				this._vScroll.removeEventListener(ControlEvent.CHANGE, this.scrollBarEvent);
				this._vScroll  = null;
				this.minHeight = 18;
			}
			this._input.multiline = value;
			this.draw();
		}
		
		private function scrollBarEvent(value : ControlEvent) : void {
			this._skipScrollEvent = true;
			this._input.scrollV   = this._vScroll.value * (this._input.maxScrollV - 1) + 1;
			this._skipScrollEvent = false;
		}
		
		private function scrollEvent(e : Event) : void {
			if (!this.multiline || this._skipScrollEvent) {
				return;
			}
			this._vScroll.value = (this._input.scrollV - 1) / (this._input.maxScrollV - 1);
			this._vScroll.draw();
		}

		public function get textField() : TextField {
			return this._input;
		}
		
		override public function draw() : void {
			this.view.graphics.clear();
			this.view.graphics.lineStyle(1, Style.borderColor2, 1, true);
			this.view.graphics.beginFill(Style.backgroundColor2);
			this.view.graphics.drawRoundRect(0, 0, width, height, 12);
			if (this.multiline) {
				this._vScroll.visible = (this._input.maxScrollV > 1);
				this._vScroll.x = (width - 15);
				this._vScroll.height = height;
				this._vScroll.draw();
				this._vScroll.visible = (height >= 30);
			}
			this._input.x = 2;
			this._input.y = 1;
			this._input.width = (width - 4) - ((this.multiline && this._vScroll.visible) ? 15 : 0);
			this._input.height = height;
		}

	}
}
