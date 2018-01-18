package ui.core.controls {

	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import ui.core.container.Container;

	/**
	 * 控制器
	 * @author neil
	 *
	 */
	public class Control extends EventDispatcher {
		
		public var parent 		: Container; 		// 父级
		public var name 		: String; 			// name
		
		private var _view 		: View;				// view
		private var _enabled 	: Boolean = true;	// enable
		private var _flexible 	: Number = 0;		// 自适应
		private var _x 			: Number = 0;		// x
		private var _y 			: Number = 0;		// y
		private var _width 		: Number = 100; 	// 宽度
		private var _height 	: Number = 20; 		// 高度
		private var _minWidth 	: Number = -1; 		// 最小宽度
		private var _minHeight 	: Number = -1; 		// 最小宽度
		private var _maxWidth 	: Number = -1; 		// 最大宽度
		private var _maxHeight 	: Number = -1; 		// 最大高度

		/**
		 *
		 * @param name		名称
		 * @param x			x
		 * @param y			y
		 * @param width		宽度
		 * @param height	高度
		 *
		 */
		public function Control(name : String = "", x : Number = 0, y : Number = 0, width : Number = 100, height : Number = 100) {
			this._view  = new View(this);
			this._width = width;
			this._height= height;
			
			this.x    = x;
			this.y    = y;
			this.name = name;
		}

		public function get x() : Number {
			return this._x;
		}
		
		public function set x(x : Number) : void {
			this._x = x;
			this.view.x = x;
		}

		public function get y() : Number {
			return this._y;
		}

		public function set y(y : Number) : void {
			this._y = y;
			this.view.y = y;
		}

		public function get width() : Number {
			return this._width;
		}
		
		/**
		 * 设置宽度 
		 * @param value
		 * 
		 */		
		public function set width(value : Number) : void {
			if (this._width == value) {
				return;
			}
			if (this.flexible != 0) {
				if (this._minWidth != -1 && value < this._minWidth) {
					value = this._minWidth;
				}
				if (this._maxWidth != -1 && value > this._maxWidth) {
					value = this._maxWidth;
				}
			}
			if (value < 0) {
				value = 0;
			}
			this._width = value;
		}
				
		public function get height() : Number {
			return this._height;
		}
		
		/**
		 * 设置高度 
		 * @param value
		 * 
		 */		
		public function set height(value : Number) : void {
			if (this._height == value) {
				return;
			}
			if (this.flexible != 0) {
				if (this._minHeight != -1 && value < this._minHeight) {
					value = this._minHeight;
				}
				if (this._maxHeight != -1 && value > this._maxHeight) {
					value = this._maxHeight;
				}
			}
			if (value < 0) {
				value = 0;
			}
			this._height = value;
		}

		public function get minWidth() : Number {
			return this._minWidth;
		}

		public function set minWidth(value : Number) : void {
			this._minWidth = value;
		}

		public function get minHeight() : Number {
			return this._minHeight;
		}

		public function set minHeight(value : Number) : void {
			this._minHeight = value;
		}

		public function get maxWidth() : Number {
			return this._maxWidth;
		}

		public function set maxWidth(value : Number) : void {
			this._maxWidth = value;
		}

		public function get maxHeight() : Number {
			return this._maxHeight;
		}

		public function set maxHeight(value : Number) : void {
			this._maxHeight = value;
		}

		public function get flexible() : Number {
			return this._flexible;
		}

		public function set flexible(value : Number) : void {
			if (value < 0) {
				value = 0;
			}
			this._flexible = value;
		}

		public function get enabled() : Boolean {
			return this._enabled;
		}
		
		/**
		 * 是否启用 
		 * @param value
		 * 
		 */		
		public function set enabled(value : Boolean) : void {
			this.view.mouseEnabled  = value;
			this.view.mouseChildren = value;
			this.view.tabChildren   = value;
			this.view.alpha 		= value ? 1 : 0.5;
			this._enabled 			= value;
		}
		
		public function get view() : View {
			return this._view;
		}

		public function get visible() : Boolean {
			return this._view.visible;
		}

		public function set visible(value : Boolean) : void {
			this._view.visible = value;
		}
		
		/**
		 * tooltip 
		 * @param txt
		 * 
		 */		
		public function set toolTip(txt : String) : void {
			ToolTip.setToolTip(this, txt);
		}
		
		/**
		 * tooltip 
		 * @return 
		 * 
		 */		
		public function get toolTip() : String {
			return ToolTip.getToolTip(this);
		}
		
		public function draw() : void {

		}
		
		override public function toString() : String {
			var clazz : String = getQualifiedClassName(this);
			clazz = clazz.substr((clazz.indexOf("::") + 2));
			return "[" + clazz + " name=" + this.name + "]";
		}
		
	}
}
