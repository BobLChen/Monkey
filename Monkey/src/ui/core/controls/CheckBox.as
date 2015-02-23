package ui.core.controls {
	
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.ui.Keyboard;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;
	
	/**
	 * 
	 * @author neil
	 * 
	 */	
	public class CheckBox extends Control {

		private var _text 	: String;
		private var _value 	: Boolean;
		private var _piv	: Sprite;
		private var _check 	: MCCheckBox;
		private var _align 	: int;
		
		/**
		 * check box 
		 * @param txt		文本
		 * @param value		是否选中
		 * @param align		对齐方式
		 * 
		 */		
		public function CheckBox(txt : String = "", value : Boolean = false, align : int = 1) {
			super();
			this._check = new MCCheckBox();
			this._check.transform.colorTransform = Style.colorTransform;
			this._text  = txt;
			this._value = value;
			this._piv   = new Sprite();
			this._piv.addChild(this._check);
						
			this.view.addChild(this._piv);
			this.view.addEventListener(MouseEvent.MOUSE_OVER,	this.mouseOverEvent);
			this.view.addEventListener(MouseEvent.MOUSE_OUT, 	this.mouseOutEvent);
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, 	this.mouseDownEvent);
			this.view.addEventListener(MouseEvent.CLICK, 		this.clickEvent);
			this.view.addEventListener(FocusEvent.FOCUS_IN, 	this.focusInEvent);
			this.view.addEventListener(FocusEvent.FOCUS_OUT, 	this.focusOutEvent);
			this.view.addEventListener(KeyboardEvent.KEY_DOWN, 	this.keyDownEvent, 	false, 0, true);
			this.view.addEventListener(KeyboardEvent.KEY_UP, 	this.keyUpEvent, 	false, 0, true);
			this.view.tabEnabled = true;
			
			this.flexible  = 1;
			this.maxHeight = 18;
			this.minHeight = 18;
			this.height    = 18;
			this.align     = align;
		}
		
		private function keyDownEvent(e : KeyboardEvent) : void {
			if ((e.keyCode == Keyboard.ENTER) || (e.keyCode == Keyboard.SPACE)) {
				this.view.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			}
		}

		private function keyUpEvent(e : KeyboardEvent) : void {
			if ((e.keyCode == Keyboard.ENTER) || (e.keyCode == Keyboard.SPACE)) {
				this.view.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				this.view.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}

		private function mouseDownEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this.view.stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent, false, 0, true);
			this.view.transform.colorTransform = new ColorTransform(0.75, 0.75, 0.75, 1);
		}
		
		private function mouseUpEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this.view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this.view.transform.colorTransform = new ColorTransform();
		}

		private function mouseOverEvent(e : MouseEvent) : void {
			this._piv.filters = Style.innerFocusFilter;
		}

		private function mouseOutEvent(e : MouseEvent) : void {
			this._piv.filters = [];
		}

		private function focusInEvent(e : FocusEvent) : void {
			this._piv.filters = Style.innerFocusFilter;
		}

		private function focusOutEvent(e : FocusEvent) : void {
			this._piv.filters = [];
		}

		private function clickEvent(e : MouseEvent) : void {
			this.view.stage.focus = view;
			this.value = !(this.value);
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}
		
		override public function draw() : void {
			if (this._align == Align.LEFT) {
				Style.defaultFont.draw(view.graphics, 15, 0, (width - 18), height, this._text, (Align.LEFT + Align.VCENTER));
				this._check.x = 0;
			} else {
				Style.defaultFont.draw(view.graphics, 0, 0, (width - 18), height, this._text, (Align.RIGHT + Align.VCENTER));
				this._check.x = (width - 15);
			}
			this._check.y = Math.ceil(height * 0.5 - 5);
			this._check.check.visible = this.value;
		}
		
		public function get text() : String {
			return this._text;
		}

		public function set text(value : String) : void {
			this._text = value;
		}

		public function get value() : Boolean {
			return this._value;
		}

		public function set value(value : Boolean) : void {
			this._value = value;
			this.draw();
		}

		public function get align() : int {
			return this._align;
		}

		public function set align(value : int) : void {
			this._align = value;
			this.draw();
		}

	}
}