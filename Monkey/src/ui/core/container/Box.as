package ui.core.container {

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;
	import flash.utils.Dictionary;
	
	import ui.core.Style;
	import ui.core.controls.Control;

	/**
	 * box容器
	 * @author neil
	 *
	 */
	public class Box extends Container {

		[Embed(source = "Box_ResizeV.png")]
		private static var BoxResizeV : Class;
		[Embed(source = "Box_ResizeH.png")]
		private static var BoxResizeH : Class;

		public static const VERTICAL 	: String = "vertical";
		public static const HORIZONTAL 	: String = "horizontal";

		private static var _curosrs 	: Boolean = false;
		
		public var space 	: Number = 5;
		public var margins 	: Number = 0;

		private var _borders 		: Shape;
		private var _contentBars 	: Sprite;
		private var _bar 			: Sprite;
		private var _last 			: Number;
		private var _orientation 	: String = "vertical";

		public function Box() {
			this._borders = new Shape();
			this._contentBars = new Sprite();
			if (!_curosrs) {
				var mouseCursor : MouseCursorData = new MouseCursorData();
				mouseCursor.data = Vector.<BitmapData>([new BoxResizeH().bitmapData]);
				mouseCursor.hotSpot = new Point(16, 16);
				Mouse.registerCursor("resize_h", mouseCursor);
				mouseCursor = new MouseCursorData();
				mouseCursor.data = Vector.<BitmapData>([new BoxResizeV().bitmapData]);
				mouseCursor.hotSpot = new Point(16, 16);
				Mouse.registerCursor("resize_v", mouseCursor);
			}
			_curosrs = true;
			this._contentBars.visible = false;
			if (name == null || name == "") {
				this.name = "Box" + new Date().getMilliseconds();
			}
		}
		
		override public function addControl(control : Control) : void {
			this.addControlAt(control, controls.length);
		}

		override public function addControlAt(control : Control, index : int = 0) : void {
			super.addControlAt(control, index);
			var bar : Sprite = new Sprite();
			bar.addEventListener(MouseEvent.MOUSE_OVER, 		this.mouseOverEvent, false, 0, true);
			bar.addEventListener(MouseEvent.MOUSE_OUT, 			this.mouseOutEvent,  false, 0, true);
			bar.addEventListener(MouseEvent.MOUSE_DOWN, 		this.mouseDownEvent, false, 0, true);
			bar.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, 	this.mouseDownEvent, false, 0, true);
			bar.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, 	this.mouseDownEvent, false, 0, true);
			this._contentBars.addChild(bar);
			this.view.addChild(this._borders);
			this.view.addChild(this._contentBars);
		}

		override public function removeControl(control : Control) : void {
			super.removeControl(control);
			this._contentBars.removeChildAt(0);
		}

		private function mouseOverEvent(e : MouseEvent) : void {
			if (!e.buttonDown) {
				Mouse.cursor = (this.orientation == HORIZONTAL) ? "resize_h" : "resize_v";
			}
		}
		
		private function mouseOutEvent(e : MouseEvent) : void {
			if (!e.buttonDown) {
				Mouse.cursor = MouseCursor.AUTO;
			}
		}

		private function mouseDownEvent(e : MouseEvent) : void {
			if (this.orientation == HORIZONTAL) {
				this._last = e.stageX;
			} else {
				this._last = e.stageY;
			}
			this._bar = e.target as Sprite;
			this.view.mouseChildren = false;
			this.view.mouseEnabled = false;
			this.view.stage.addEventListener(MouseEvent.MOUSE_UP, 		this.mouseUpEvent);
			this.view.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP,this.mouseUpEvent);
			this.view.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.mouseUpEvent);
			this.view.stage.addEventListener(MouseEvent.MOUSE_MOVE, 	this.mouseMoveEvent);
		}
		
		private function mouseUpEvent(e : MouseEvent) : void {
			this.view.mouseChildren = true;
			this.view.mouseEnabled = true;
			this.view.stage.removeEventListener(MouseEvent.MOUSE_UP, 		this.mouseUpEvent);
			this.view.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.mouseUpEvent);
			this.view.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, 	this.mouseUpEvent);
			this.view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, 		this.mouseMoveEvent);
			if (e.target != this._bar) {
				Mouse.cursor = MouseCursor.AUTO;
			}
		}

		private function get totalFlexible() : Number {
			var result : Number = 0;
			for each (var control : Control in controls) {
				if (control.visible) {
					result = result + control.flexible;
				}
			}
			return result;
		}
		
		private function mouseMoveEvent(e : MouseEvent) : void {
			var idx : int = this._contentBars.getChildIndex(this._bar);
			var totalFlexible : Number = this.totalFlexible;
			var deltaX : Number = 0;
			if (this.orientation == HORIZONTAL) {
				deltaX = (e.stageX - this._last);
				this._last = e.stageX;
				this.controls[idx].flexible = controls[idx].flexible + ((deltaX * totalFlexible) / width);
				this.controls[(idx + 1)].flexible = controls[(idx + 1)].flexible - ((deltaX * totalFlexible) / width);
			} else {
				deltaX = (e.stageY - this._last);
				this._last = e.stageY;
				this.controls[idx].flexible = controls[idx].flexible + ((deltaX * totalFlexible) / height);
				this.controls[(idx + 1)].flexible = controls[(idx + 1)].flexible - ((deltaX * totalFlexible) / height);
			}
			this.update();
			this.draw();
			for each (var control : Control in controls) {
				if (control.flexible != 0) {
					if (this.orientation == HORIZONTAL) {
						control.flexible = control.width / width;
					} else {
						control.flexible = control.height / height;
					}
				}
			}
		}
		
		public function normalize() : void {
			var totalWidth : Number = 0;
			var control : Control = null;
			for each (control in controls) {
				if (control.flexible != 0) {
					totalWidth += control.width;
				}
			}
			for each (control in controls) {
				if (control.flexible != 0) {
					control.flexible = control.width / totalWidth;
				}
			}
		}

		public function get allowResize() : Boolean {
			return this._contentBars.visible;
		}

		public function set allowResize(value : Boolean) : void {
			this._contentBars.visible = value;
			this.draw();
		}

		override public function update() : void {
			if (visible == false) {
				return;
			}
			if (this.orientation == VERTICAL) {
				this.spreadVertical();
			} else {
				this.spreadHorizontal();
			}
			for each (var control : Control in controls) {
				if (control is Container) {
					Container(control).update();
				}
			}
		}
		
		private function spreadHorizontal() : void {
			var i : int = 0;
			var w : Number = width - margins * 2 - (space * (controls.length - 1));
			var h : Number = height - margins * 2;
			var map : Dictionary = new Dictionary();
			do {
				var constWidth : Number = 0;			// 固定宽度
				var totalFlexible : Number = 0;			// 可变宽度比率
				var control : Control = null;			// 控制器
				for each (control in controls) {
					if (control.visible == true) {
						if (control.flexible == 0 || map[control] == true) {
							constWidth += control.width;
							map[control] = true;
						} else {
							totalFlexible += control.flexible;
						}
					}
				}
				var totalWidth : Number = 0;
				var surplus : Number = w - constWidth;		// 剩余宽度 = 宽度 - 定长宽度
				for each (control in controls) {
					if (control.visible) {					
						if (map[control] == undefined) {
							var w0 : Number = (control.flexible * surplus) / totalFlexible;	// w0 = 剩余宽度 * (flexible/flexiableTotal)
							control.width = w0;
							control.height = h;
							if (control.width != w0) {
								map[control] = true;
							}
						}
						totalWidth += control.width;
					}
				}
				if (totalWidth > w) {
					for each (control in controls) {
						if (control.visible) {
							if (control.flexible && (control.minWidth == -1) || (control.minWidth < control.width)) {
								delete map[control];
							}
						}
					}
				} else if (totalWidth < w) {
					for each (control in controls) {
						if (control.visible) {
							if (control.flexible && (control.maxWidth == -1) || (control.maxWidth > control.width)) {
								delete map[control];
							}
						}
					}
				}
			} while ((Math.abs(totalWidth - w) > 0.01) && i++ < 2);
		}

		private function spreadVertical() : void {

			var i : int = 0;
			var w : Number = width - margins * 2;
			var h : Number = height - margins * 2 - space * (controls.length - 1);

			var map : Dictionary = new Dictionary();

			do {
				var constHeight : Number = 0;
				var totalFlexible : Number = 0;
				var control : Control = null;
				
				for each (control in controls) {
					if (control.visible) {
						if ((control.flexible == 0) || (map[control] == true)) {
							constHeight += control.height;
							map[control] = true;
						} else {
							totalFlexible += control.flexible;
						}
					}
				}

				var totalHeight : Number = 0;
				var surplus : Number = h - constHeight;

				for each (control in controls) {
					if (control.visible) {
						if (map[control] == undefined) {
							var newHeight : Number = ((control.flexible * surplus) / totalFlexible);
							control.width = w;
							control.height = newHeight;
							if (control.height != newHeight) {
								map[control] = true;
							}
						}
						totalHeight += control.height;
					}
				}
				
				if (totalHeight > h) {
					for each (control in controls) {
						if (control.visible) {
							if (control.flexible && (control.minHeight == -1) || (control.minHeight < control.height)) {
								delete map[control];
							}
						}
					}
				} else if (totalHeight < h) {
					for each (control in controls) {
						if (control.visible) {
							if (control.flexible && (control.maxHeight == -1) || (control.maxHeight > control.height)) {
								delete map[control];
							}
						}
					}
				}
			} while ((Math.abs(totalHeight - h) > 0.01) && i++ < 2);
		}

		override public function draw() : void {
			if (visible == false) {
				return;
			}
			super.draw();
			var xIdx : Number = this.margins;
			for each (var control : Control in controls) {
				if (control.visible) {
					if (this.orientation == VERTICAL) {
						control.y = xIdx;
						control.x = this.margins;
						xIdx = control.y + control.height + this.space;
					} else {
						control.x = xIdx;
						control.y = this.margins;
						xIdx = control.x + control.width + this.space;
					}
					control.draw();
				}
			}
			
			if (this._contentBars.visible) {
				this._contentBars.x = 0;
				this._contentBars.y = 0;
				view.addChild(this._contentBars);
				var i : int = 0;
				var visibleBar : Sprite;
				while (i < controls.length) {
					var tmpBar : Sprite = (this._contentBars.getChildAt(controls.indexOf(controls[i])) as Sprite);
					tmpBar.graphics.clear();
					tmpBar.visible = controls[i].visible;
					if (tmpBar.visible) {
						visibleBar = tmpBar;
					}
					if (this.orientation == VERTICAL) {
						tmpBar.x = 0;
						tmpBar.y = ((controls[i].y + controls[i].height) + (this.space * 0.5));
						tmpBar.graphics.beginFill(0xFFFF00, 0);
						tmpBar.graphics.drawRect(0, -3, width, 6);
						tmpBar.graphics.lineStyle(3, Style.borderColor, 1, true);
						tmpBar.graphics.moveTo(0, 0);
						tmpBar.graphics.lineTo(width, 0);
					} else {
						tmpBar.y = 0;
						tmpBar.x = ((controls[i].x + controls[i].width) + (this.space * 0.5));
						tmpBar.graphics.beginFill(0xFFFF00, 0);
						tmpBar.graphics.drawRect(-3, 0, 6, height);
						tmpBar.graphics.lineStyle(3, Style.borderColor, 1, true);
						tmpBar.graphics.moveTo(0, 0);
						tmpBar.graphics.lineTo(0, height);
					}
					i++;
				}
				if (visibleBar) {
					visibleBar.visible = false;
				}
			}
		}
		
		override public function set width(value : Number) : void {
			var min : Number = this.minWidth;
			var max : Number = this.maxWidth;
			if (flexible != 0) {
				if (min != -1 && value < min) {
					value = min;
				}
				if (max != -1 && value > max) {
					value = max;
				}
			}
			if (value < 0) {
				value = 0;
			}
			if (value != super.width) {
				super.width = value;
			}
		}
		
		override public function set height(value : Number) : void {
			var min : Number = this.minHeight;
			var max : Number = this.maxHeight;
			if (flexible != 0) {
				if (min != -1 && value < min) {
					value = min;
				}
				if (max != -1 && value > max) {
					value = max;
				}
			}
			if (value < 0) {
				value = 0;
			}
			if (value != super.height) {
				super.height = value;
			}
		}
		
		override public function get minWidth() : Number {
			if (flexible == 0) {
				return super.width;
			}
			if (!visible) {
				return super.minWidth == -1 ? -1 : 0;
			}
			var result : Number = 0;
			var len : int = controls.length;
			if (result == 0) {
				return super.minWidth;
			}
			var i : int = 0;
			while (i < len) {
				var control : Control = controls[i];
				if (control.visible) {
					if (this.orientation == VERTICAL) {
						if (control.flexible == 0) {
							result = Math.max(result, control.width);
						} else {
							result = Math.max(result, control.minWidth);
						}
					} else {
						if (control.flexible == 0) {
							result = result + control.width;
						} else {
							result = result + Math.max(0, control.minWidth);
						}
					}
				}
				i++;
			}
			result = result + this.margins * 2 + ((this.orientation == VERTICAL) ? 0 : this.space * (controls.length - 1));
			return Math.max(super.minWidth, result);
		}

		override public function get maxWidth() : Number {
			if (flexible == 0) {
				return super.width;
			}
			if (!visible) {
				return super.maxWidth == -1 ? -1 : 0;
			}
			var result : Number = 0;
			var len : int = controls.length;
			if (len == 0) {
				return super.maxWidth;
			}
			var i : int = 0;
			while (i < len) {
				var control : Control = controls[i];
				if (control.visible) {
					if (this.orientation == VERTICAL) {
						if (control.flexible == 0) {
							result = control.width;
						} else if (control.maxWidth != -1) {
							result = Math.max(result, control.maxWidth);
						} else {
							return (super.maxWidth);
						}
					} else {
						if (control.flexible == 0) {
							result = (result + (control.width + this.space));
						} else if (control.maxWidth != -1) {
							result = (result + Math.max(0, control.maxWidth));
						} else {
							return super.maxWidth;
						}
					}
				}
				i++;
			}
			result = result + this.margins * 2 + ((this.orientation == VERTICAL) ? this.space * (controls.length - 1) : 0);
			return Math.min(((super.maxWidth) != -1) ? super.maxWidth : result, result);
		}
		
		override public function get minHeight() : Number {	
			if (flexible == 0) {
				return super.height;
			}
			if (!visible) {
				return super.minHeight == -1 ? -1 : 0;
			}
			if (super.minHeight == -1) {
				return super.minHeight;
			}
			
			var result : Number = 0;
			var len : int = controls.length;
			var i : int = 0;
			while (i < len) {
				var control : Control = controls[i];
				if (control.visible) {
					if (this.orientation == VERTICAL) {
						if (control.flexible == 0) {
							result = (result + control.height);
						} else {
							result = (result + Math.max(0, control.minHeight));
						}
					} else {
						if (control.flexible == 0) {
							result = Math.max(result, control.height);
						} else {
							result = Math.max(result, control.minHeight);
						}
					}
				}
				i++;
			}
			result = (result + ((this.margins * 2) + (((this.orientation == VERTICAL)) ? (this.space * (controls.length - 1)) : 0)));
			return Math.max(super.minHeight, result);
		}

		override public function get maxHeight() : Number {
			if (flexible == 0) {
				return (super.height);
			}
			if (!visible) {
				return (((super.maxHeight == -1)) ? -1 : 0);
			}
			if (super.maxHeight == -1)
				return -1;
			
			var result : Number = 0;
			var len : int = controls.length;
			var i : int;
			while (i < len) {
				var control : Control = controls[i];
				if (control.visible) {
					if (this.orientation == VERTICAL) {
						if (control.flexible == 0) {
							result = (result + (control.height + this.space));
						} else if (control.maxHeight != -1) {
							result = (result + Math.max(0, control.maxHeight));
						} else {
							return (super.maxHeight);
						}
					} else {
						if (control.flexible == 0) {
							result = Math.max(result, control.height);
						} else if (control.maxHeight != -1) {
							result = Math.max(result, control.maxHeight);
						} else {
							return (super.maxHeight);
						}
					}
				}
				i++;
			}
			result = (result + ((this.margins * 2) + (((this.orientation == VERTICAL)) ? (this.space * (controls.length - 1)) : 0)));
			return Math.min(((super.maxHeight) != -1) ? super.maxHeight : result, result);
		}

		public function get orientation() : String {
			return this._orientation;
		}
		
		public function set orientation(value : String) : void {
			this._orientation = value;
		}

	}
}
