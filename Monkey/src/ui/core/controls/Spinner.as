package ui.core.controls {

	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;

	public class Spinner extends Control {

		private static const NORMAL 	: String = "normal";
		private static const FOCUS 		: String = "focus";
		private static const EDITABLE 	: String = "editable";

		private var _back 		: TextField;
		private var _field_txt 	: TextField;
		private var _value 		: Number;
		private var _min 		: Number = 0;
		private var _max 		: Number = 100;
		private var _decimals 	: int = 2;
		private var _increment 	: Number;
		private var _lastX 		: Number = 0;
		private var _lastY 		: Number = 0;
		private var _default 	: Number = 0;
		private var _prevValue 	: Number = 0;
		private var _changed 	: Boolean;
		private var _activated 	: Boolean;
		private var _textColor 	: int;
		
		public function Spinner(value : Number = 0, min : Number = 0, max : Number = 0, decimal : int = 2, increment : Number = 0) {

			this._textColor = Style.labelsColor;
			this._back 		= new TextField();
			this._field_txt = new TextField();
			this._field_txt.autoSize = TextFieldAutoSize.LEFT;
			this._field_txt.textColor = this._textColor;
			this._field_txt.backgroundColor = Style.labelsColor;
			this._field_txt.restrict = "-.0-9";
			this._field_txt.tabEnabled = true;
			this._field_txt.multiline = false;
			
			this.view.addChild(this._back);
			this.view.addChild(this._field_txt);
			
			this._field_txt.addEventListener(MouseEvent.MOUSE_OVER, 	this.mouseOverEvent, 	false, 0, true);
			this._field_txt.addEventListener(MouseEvent.MOUSE_OUT, 		this.mouseOutEvent, 	false, 0, true);
			this._field_txt.addEventListener(MouseEvent.MOUSE_DOWN, 	this.mouseDownEvent, 	false, 0, true);
			this._field_txt.addEventListener(MouseEvent.RIGHT_CLICK, 	this.rightClickEvent, 	false, 0, true);
			this._field_txt.addEventListener(KeyboardEvent.KEY_DOWN, 	this.keyDownEvent, 		false, 0, true);
			this._field_txt.addEventListener(FocusEvent.FOCUS_IN, 		this.focusInEvent, 		false, 0, true);
			this._field_txt.addEventListener(FocusEvent.FOCUS_OUT, 		this.focusOutEvent, 	false, 0, true);
			this._field_txt.addEventListener(Event.CHANGE, 				this.changeEvent, 		false, 0, true);
			
			this._default  	= value;
			this._decimals 	= decimal;
			this.min 		= min;
			this.max 		= max;
			this.value 		= value;
			this.increment 	= increment;
			this.flexible 	= 1;
			this.minHeight 	= 18;
			this.maxHeight 	= 18;
			this.minWidth 	= 25;
			this.width 		= minWidth;
			this.height 	= minHeight;
			this.setState(NORMAL);
		}

		public function get increment() : Number {
			return this._increment;
		}

		public function set increment(value : Number) : void {
			this._increment = value;
		}

		private function changeEvent(e : Event) : void {
			e.stopPropagation();
			this.draw();
		}

		private function focusOutEvent(e : FocusEvent) : void {
			var value : Number = this._value;
			this._value = Number(this._field_txt.text);
			this.setState(NORMAL);
			this.evaluate();
			if (this._value.toFixed(this._decimals) != value.toFixed(this._decimals)) {
				this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
				this.dispatchEvent(new ControlEvent(ControlEvent.STOP, this));
			}
		}

		private function focusInEvent(e : FocusEvent) : void {
			this.setState(EDITABLE);
		}

		private function keyDownEvent(e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.ENTER) {
				this.ok();
			}
			if (e.keyCode == Keyboard.TAB) {
				this.ok();
			}
			if (e.keyCode == Keyboard.ESCAPE) {
				this.esc();
			}
		}

		private function rightClickEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this.view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this.view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveEvent);
			this.view.stage.removeEventListener(MouseEvent.RIGHT_CLICK, this.rightClickEvent);
			this._changed = false;
			if (this.view.stage.focus == this._field_txt) {
				this.esc();
			}
		}

		private function mouseUpEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this.view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this.view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveEvent);
			this.view.stage.removeEventListener(MouseEvent.RIGHT_CLICK, this.rightClickEvent);
			if (this._changed) {
				this.setState(FOCUS);
				this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
				this.dispatchEvent(new ControlEvent(ControlEvent.STOP, this));
			} else {
				this.setState(EDITABLE);
			}
			this._changed = false;
		}

		private function mouseMoveEvent(e : MouseEvent) : void {
			if (!this._changed) {
				this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
			}
			this._changed = true;
			var xspeed : Number = view.stage.mouseX - this._lastX;
			var yspeed : Number = view.stage.mouseY - this._lastY;
			if (e.ctrlKey) {
				if (Math.abs(xspeed) < 10) {
					return;
				}
				xspeed = int(xspeed / 10);
			}
			if (!e.shiftKey) {
				if (Math.abs(xspeed) < 3) {
					return;
				}
				xspeed = int(xspeed / 3);
			}
			var max : Number = 100000;
			var increValue : Number = Math.abs(this._increment);
			if (increValue == 0) {
				increValue = Math.max((Math.abs(this._value) * 0.01), 0.01);
			}
			this._value = this._value * max;
			this._value = this._value + (xspeed * increValue) * max;
			this._value = this._value / max;
			this.evaluate();
			this._lastX = view.stage.mouseX;
			this._lastY = view.stage.mouseY;
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function mouseDownEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this.setState(FOCUS);
			this.view.stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this._changed = false;
			this._lastX = view.stage.mouseX;
			this._lastY = view.stage.mouseY;
			this.view.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveEvent);
			this.view.stage.addEventListener(MouseEvent.RIGHT_CLICK, this.rightClickEvent);
		}
		
		private function mouseOutEvent(e : MouseEvent) : void {
			Mouse.cursor = MouseCursor.AUTO;
		}

		private function mouseOverEvent(e : MouseEvent) : void {
			Mouse.cursor = MouseCursor.BUTTON;
		}

		private function ok() : void {
			var value : Number = this._value;
			if (this.value.toFixed(this._decimals) != this._field_txt.text) {
				dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
			}
			this._value = Number(this._field_txt.text);
			this.setState(FOCUS);
			this.evaluate();
			if (this._value.toFixed(this._decimals) != value.toFixed(this._decimals)) {
				this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
				this.dispatchEvent(new ControlEvent(ControlEvent.STOP, this));
			}
		}

		private function esc() : void {
			var value : Number = this._value;
			this._value = this._prevValue;
			this.setState(FOCUS);
			this.evaluate();
			if (this._value.toFixed(this._decimals) != value.toFixed(this._decimals)) {
				this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
				this.dispatchEvent(new ControlEvent(ControlEvent.STOP, this));
			}
		}

		private function evaluate() : void {
			if ((this._max != this._min) && (this._value > this._max)) {
				this._value = this._max;
			}
			if ((this._min != this._max) && (this._value < this._min)) {
				this._value = this._min;
			}
			if (isNaN(this._value)) {
				this._value = this._min;
			}
			this._field_txt.text = this._value.toFixed(this._decimals);
			this.draw();
		}

		public function get value() : Number {
			return this._value;
		}

		public function set value(value : Number) : void {
			if (value == this._value) {
				return;
			}
			this._value = value;
			this.evaluate();
		}

		private function setState(state : String = "normal") : void {
			switch (state) {
				case NORMAL:
					this._field_txt.type 		= TextFieldType.INPUT;
					this._field_txt.border 		= false;
					this._field_txt.background 	= false;
					this._field_txt.selectable 	= false;
					this._field_txt.autoSize 	= TextFieldAutoSize.LEFT;
					this._field_txt.multiline 	= false;
					this._field_txt.contextMenu = null;
					this._field_txt.textColor 	= this._textColor;
					this._back.filters 			= null;
					this._back.visible 			= false;
					break;
				case FOCUS:
					this._prevValue 				= Number(this._field_txt.text);
					this._field_txt.type 			= TextFieldType.DYNAMIC;
					this._field_txt.border 			= false;
					this._field_txt.background 		= true;
					this._field_txt.backgroundColor = this._textColor;
					this._field_txt.textColor 		= Style.backgroundColor;
					this._field_txt.selectable 		= false;
					this._field_txt.setSelection(0, 0);
					this._field_txt.autoSize 		= TextFieldAutoSize.LEFT;
					this._field_txt.multiline 		= false;
					this._field_txt.contextMenu 	= null;
					this._back.filters 				= null;
					this._back.visible 				= false;
					break;
				case EDITABLE:
					this._prevValue 			= Number(this._field_txt.text);
					this._field_txt.type 		= TextFieldType.INPUT;
					this._field_txt.border 		= false;
					this._field_txt.background 	= false;
					this._field_txt.textColor 	= 0x606060;
					this._field_txt.selectable 	= true;
					this._field_txt.setSelection(0, this._field_txt.length);
					this._field_txt.autoSize 	= TextFieldAutoSize.LEFT;
					this._back.filters = Style.focusFilter;
					this._back.visible = true;
					break;
			}
		}

		public function set text(value : String) : void {
			this._field_txt.text = value;
		}

		public function set min(min : Number) : void {
			this._min = min;
		}

		public function get min() : Number {
			return this._min;
		}

		public function set max(max : Number) : void {
			this._max = max;
		}

		public function get max() : Number {
			return this._max;
		}

		override public function draw() : void {
			this._field_txt.y 		= -1;
			this._field_txt.width 	= this._field_txt.textWidth;
			this._back.x 			= this._field_txt.x;
			this._back.y 			= this._field_txt.y;
			this._back.width 		= this._field_txt.width;
			this._back.height 		= 18;
			this.view.graphics.clear();
			this.view.graphics.lineStyle(1, this._textColor, 0.75, true, LineScaleMode.NONE);
			this.view.graphics.moveTo((this._field_txt.x + 2), (this._field_txt.y + this._field_txt.textHeight - 0));
			this.view.graphics.lineTo((this._field_txt.x + this._field_txt.textWidth + 4), (this._field_txt.y + this._field_txt.textHeight - 0));
		}

	}
}
