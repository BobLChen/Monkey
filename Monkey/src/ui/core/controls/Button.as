package ui.core.controls {
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;
	
	/**
	 * 
	 * @author neil
	 * 
	 */	
	public class Button extends Control {
		
		private var _text 		: String;			// 文本
		private var _align 		: uint;				// 对齐方式
		private var _state 		: String;  			// 状态
		private var _foreGround : Sprite;			// ...
		private var _backGround : Sprite;			// 背景色
		private var _loader 	: Loader;
		
		/**
		 * 按钮 
		 * @param txt		文本
		 * @param x			x
		 * @param y			y
		 * @param align		对齐方式
		 * 
		 */		
		public function Button(txt : String = "", x : Number = 0, y : Number = 0, align : uint = 18) {
			super("", x, y, 100, 20);
			this._loader 	 = new Loader();
			this._text 		 = txt;
			this._align 	 = align;
			this._foreGround = new Sprite();  
			this._backGround = new Sprite();
			this.view.addChild(this._backGround);
			this.view.addChild(this._foreGround);
			
			this.view.buttonMode = false;
			this.view.tabEnabled = true;
			this.view.addEventListener(MouseEvent.CLICK, 		clickEvent);
			this.view.addEventListener(MouseEvent.MOUSE_OVER, 	handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_OUT, 	handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, 	handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_UP, 	handleEvents);
			this.view.addEventListener(FocusEvent.FOCUS_IN,		focusInEvent);
			this.view.addEventListener(FocusEvent.FOCUS_OUT, 	focusOutEvent);
			this.view.addEventListener(KeyboardEvent.KEY_DOWN, 	keyDownEvent, false, 0, true);
			this.view.addEventListener(KeyboardEvent.KEY_UP, 	keyUpEvent,   false, 0, true);
			
			this.flexible  = 1;
			this.minWidth  = 20;
			this.minHeight = 18;
			this.maxHeight = 18;
			
			this.draw();
		}
		
		private function keyDownEvent(e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE) {
				this.view.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			}
		}
		
		private function keyUpEvent(e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE) {
				this.view.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				this.view.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}
		
		private function focusInEvent(e : FocusEvent) : void {
			this.view.filters = Style.focusFilter;
		}

		private function focusOutEvent(e : FocusEvent) : void {
			this.view.filters = [];
		}

		private function clickEvent(e : MouseEvent) : void {
			this.view.stage.focus = view;
			this.dispatchEvent(new ControlEvent(ControlEvent.CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}
		
		private function handleEvents(e : MouseEvent) : void {
			this._state = e.type;
			this.draw();
		}

		public function get text() : String {
			return this._text;
		}

		public function set text(value : String) : void {
			this._text = value;
			this.draw();
		}
		
		public function get align() : uint {
			return this._align;
		}

		public function set align(value : uint) : void {
			this._align = value;
			this.draw();
		}
		
		override public function draw() : void {
			this._backGround.graphics.clear();
			this._backGround.graphics.beginFill(0x000000);
			this._backGround.graphics.drawRoundRectComplex(0, 0, width, height, 15, 15, 15, 15);
			this._foreGround.graphics.clear();
			Style.defaultFont.draw(this._foreGround.graphics, 2, 0, width - 4, height, this.text, this.align);
		}
				
	}
}