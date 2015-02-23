package ui.core.controls {

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;

	/**
	 * Combox
	 * @author neil
	 *
	 */
	public class ComboBox extends Control {

		[Embed(source = "arrow.png")]
		private static const Arrow : Class;

		public var align 		: uint = 17;
		public var selectIndex 	: int = -1;
		public var selectData 	: Object;
		public var customMenu 	: NativeMenu;

		private var _text 		: String = "";
		private var _items 		: Array;
		private var _data 		: Array;
		private var _state 		: String;
		private var _lock 		: Boolean;
		private var _arrow 		: Bitmap;
		private var _background : MovieClip;
		private var _foreground : Sprite;
		
		public function ComboBox(items : Array = null, datas : Array = null) {
			super();
			this._arrow = new Arrow();
			this._background = new MCButton();
			this._foreground = new Sprite();
			this._arrow.transform.colorTransform = Style.colorTransform;
			this._arrow.rotation = 90;
			this._items = items ? items : [];
			this._data = datas ? datas : [];
			this.flexible = 1;
			this.maxHeight = 18;
			this.minHeight = 18;
			this.height = 18;
			this.minWidth = 24;
			if (this._items.length > 0) {
				this.text = this._items[0];
			}
			this.view.addChild(this._background);
			this.view.addChild(this._foreground);
			this.view.addChild(this._arrow);
			this.view.addEventListener(MouseEvent.CLICK, this.clickEvent);
			this.view.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.rightClickEvent);
			this.view.addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWhellEvent);
			this.view.addEventListener(MouseEvent.MOUSE_OVER, this.handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_OUT, this.handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, this.handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_UP, this.handleEvents);
			this.view.addEventListener(FocusEvent.FOCUS_IN, this.focusInEvent);
			this.view.addEventListener(FocusEvent.FOCUS_OUT, this.focusOutEvent);
			this.view.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownEvent);
			this.view.addEventListener(KeyboardEvent.KEY_UP, this.keyUpEvent);
			this.view.tabEnabled = true;
		}
		
		private function rightClickEvent(e : MouseEvent) : void {
			view.stage.focus = view;
			this.move(1, true);
		}
		
		private function mouseWhellEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this.move(e.delta < 0 ? 1 : -1);
		}
		
		private function move(delta : int, loop : Boolean = false) : void {
			if (!this.items || this.items.length == 0) {
				return;
			}
			this.selectIndex += delta;
			if (loop) {
				if (this.selectIndex < 0) {
					this.selectIndex = this.items.length - 1;
				}
				if (this.selectIndex >= this.items.length) {
					this.selectIndex = 0;
				}
			} else {
				if (this.selectIndex < 0) {
					this.selectIndex = 0;
				}
				if (this.selectIndex >= this.items.length) {
					this.selectIndex = this.items.length - 1;
				}
			}
			this.selectData = this.data[this.selectIndex];
			this._text = this.items[this.selectIndex];
			if (this._text == "-") {
				this.move(delta, loop);
			} else {
				this.draw();
				this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
			}
		}
		
		private function keyDownEvent(e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE) {
				view.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
			}
		}
		
		private function keyUpEvent(e : KeyboardEvent) : void {
			if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE) {
				e.preventDefault();
				e.stopImmediatePropagation();
				view.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				view.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}
		}

		private function focusInEvent(e : FocusEvent) : void {
			view.filters = Style.focusFilter;
		}
		
		private function focusOutEvent(e : FocusEvent) : void {
			view.filters = [];
		}

		public function addItem(item : String, data : Object = null) : void {
			this.items.push(item);
			this.data.push(data);
		}
		
		public function removeItem(item : String) : void {
			var idx : int = this.items.indexOf(item);
			if (idx > -1) {
				this.items.splice(idx, 1);
				this.data.splice(idx, 1);
			}
		}
		
		private function clickEvent(e : MouseEvent) : void {
			if (this._lock) {
				return;
			}
			view.stage.focus = view;
			var menu : NativeMenu = null;
			if (!this.customMenu) {
				menu = new NativeMenu();
				for each (var s : String in this.items) {
					var item : NativeMenuItem = null;
					if (s == "-") {
						item = menu.addItem(new NativeMenuItem("", true));
					} else {
						item = menu.addItem(new NativeMenuItem(s));
					}
					if (item.label.charAt(0) == "/") {
						item.label = item.label.substr(1);
						item.enabled = false;
					}
					if (item.label == this.text) {
						item.checked = true;
					}
				}
			} else {
				menu = this.customMenu;
			}
			this._lock = true;
			var position : Point = view.localToGlobal(new Point(0, view.height));
			menu.addEventListener(Event.SELECT, this.selectMenuEvent, false, 0, true);
			menu.display(view.stage, position.x, position.y);
			setTimeout(function() : void {
				_lock = false;
				view.stage.focus = view;
			}, 500);
		}
		
		private function handleEvents(e : MouseEvent) : void {
			if (e.type == MouseEvent.MOUSE_DOWN) {
				e.stopImmediatePropagation();
			}
			this._state = e.type;
			this.draw();
		}
		
		private function selectMenuEvent(e : Event) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
			if (!this.customMenu) {
				this.selectIndex = this.items.indexOf(e.target.label);
				this.selectData = this.data[this.selectIndex];
				this.text = e.target.label;
			}
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
			this.draw();
		}
				
		public function get text() : String {
			return this._text || "";
		}
		
		public function set text(str : String) : void {
			this._text = str;
			this.selectIndex = this.items.indexOf(this._text);
			this.selectData = this.data[this.selectIndex];
			if (this.selectIndex > -1) {
				this._text = this.items[this.selectIndex];
				this.draw();
			}
		}
		
		public function get items() : Array {
			return this._items;
		}
		
		public function set items(value : Array) : void {
			this._items = value;
			if (this.selectIndex == -1 && this._items.length > 0) {
				this.selectIndex = 0;
				this.selectData = this.data[this.selectIndex];
				this.text = this._items[0];
			}
		}
		
		public function get data() : Array {
			return this._data;
		}

		public function set data(value : Array) : void {
			this._data = value;
		}
		
		override public function draw() : void {
			this._background.graphics.clear();
			this._background.width = width;
			this._background.height = height;
			this._foreground.graphics.clear();
			switch (this._state) {
				case MouseEvent.MOUSE_DOWN:
					this._background.gotoAndStop(1);
					break;
				case MouseEvent.MOUSE_OVER:
					this._background.gotoAndStop(2);
					break;
				default:
					this._background.gotoAndStop(3);
			}
			Style.defaultFont.draw(this._foreground.graphics, 4, 0, width - 20, height, this.text, this.align);
			this._arrow.x = width - 12;
			this._arrow.y = height * 0.5 - 2;
		}

	}
}
