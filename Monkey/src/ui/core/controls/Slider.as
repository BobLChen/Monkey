package ui.core.controls {

	import com.greensock.TweenLite;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;

	/**
	 * slider
	 * @author neil
	 *
	 */
	public class Slider extends Control {

		public static const VERTICAL 	: String = "vertical";
		public static const HORIZONTAL 	: String = "horizontal";

		private var _min 			: Number = 0;
		private var _max 			: Number = 100;
		private var _value 			: Number = 0;
		private var _orientation 	: String;
		private var _last 			: Point;
		private var _scrollWidth 	: Number = 0;
		private var _scrollHeight 	: Number = 0;
		private var _scrollPos 		: Point;
		private var _state 			: String = "up";
		private var _background 	: Sprite;
		private var _scrollBar 		: Sprite;
		private var _border 		: Sprite;
		private var _lastWidth 		: Number;
		private var _lastHeight 	: Number;
		private var _lastState 		: String;
		
		public function Slider(orientation : String = "vertical") {
			super("", 0, 0, 15, 15);
			this._last 			= new Point();
			this._background 	= new Sprite();
			this._scrollBar 	= new Sprite();
			this._border 		= new Sprite();
			this._orientation 	= orientation;
			this._scrollPos 	= new Point(0, 0);
			this._background.filters = [new DropShadowFilter(6, (((orientation == VERTICAL)) ? 0 : 90), 0, 0.35, 4, 4, 1, 4, true)];
			this._scrollBar.filters  = [new DropShadowFilter(4, 45, 0, 0.5, 4, 4, 1, 4, false)];
			
			this.width = width;
			this.height = height;
			this.flexible = 1;
			
			this.view.cacheAsBitmap = true;
			this.view.addChild(this._background);
			this.view.addChild(this._scrollBar);
			this.view.addChild(this._border);
			this.view.addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWheelEvent);
			
			this._scrollBar.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownEvent);
			this._scrollBar.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.middleDownEvent);
			this._scrollBar.addEventListener(MouseEvent.MOUSE_OVER, this.mouseOverEvent);
			this._scrollBar.addEventListener(MouseEvent.MOUSE_OUT, this.mouseOutEvent);
			this._scrollBar.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this._background.addEventListener(MouseEvent.MOUSE_DOWN, this.backMouseDownEvent);
			
			this.draw();
		}

		private function middleDownEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
		}

		private function backMouseDownEvent(e : MouseEvent) : void {
			e.stopPropagation();
			this._background.addEventListener(MouseEvent.MOUSE_UP, this.backMouseUpEvent);
		}

		private function backMouseUpEvent(e : MouseEvent) : void {
			this._background.removeEventListener("mouseUp", this.backMouseUpEvent);
			var point : Point = view.globalToLocal(new Point(e.stageX, e.stageY));
			if (this._orientation == VERTICAL) {
				TweenLite.to(this._scrollPos, 0.25, {y: (point.y - (this._scrollBar.height * 0.5)), onUpdate: this.tweenUpdate});
			} else {
				TweenLite.to(this._scrollPos, 0.25, {x: (point.x - (this._scrollBar.width * 0.5)), onUpdate: this.tweenUpdate});
			}
			this._scrollBar.alpha = 0;
			TweenLite.to(this._scrollBar, 0.5, {alpha: 1});
			this.evaluate();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
			this.draw();
		}
		
		private function mouseWheelEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			if (e.delta != 0) {
				TweenLite.to(this, 0.25, {position: (this.position - (e.delta * 20)), onUpdate: this.tweenUpdate});
			}
			this.evaluate();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
			this.draw();
		}

		private function tweenUpdate() : void {
			this.evaluate();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
			this.draw();
		}

		private function mouseDownEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this._last.x = view.stage.mouseX - this._scrollPos.x;
			this._last.y = view.stage.mouseY - this._scrollPos.y;
			this.evaluate();
			this.draw();
			this.view.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveEvent);
			this.view.stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this._scrollBar.removeEventListener(MouseEvent.MOUSE_OVER, this.mouseOverEvent);
			this._scrollBar.removeEventListener(MouseEvent.MOUSE_OUT, this.mouseOutEvent);
			this.state = "down";
		}
		
		private function mouseOverEvent(e : MouseEvent) : void {
			this.state = "over";
		}

		private function mouseOutEvent(e : MouseEvent) : void {
			this.state = "up";
		}

		private function mouseUpEvent(e : MouseEvent) : void {
			this.view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveEvent);
			this.view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this._scrollBar.addEventListener(MouseEvent.MOUSE_OVER, this.mouseOverEvent);
			this._scrollBar.addEventListener(MouseEvent.MOUSE_OUT, this.mouseOutEvent);
			if (e.target == this._scrollBar) {
				this.state = "over";
			} else {
				this.state = "up";
			}
		}

		private function mouseMoveEvent(e : MouseEvent) : void {
			if (this._orientation == VERTICAL) {
				this._scrollPos.y = view.stage.mouseY - this._last.y;
			} else {
				this._scrollPos.x = view.stage.mouseX - this._last.x;
			}
			this.evaluate();
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		public function get position() : Number {
			return this._value * (this._max - this._min) + this._min;
		}

		public function set position(value : Number) : void {
			this.value = (value - this._min) / (this._max - this._min);
		}

		public function get min() : Number {
			return this._min;
		}

		public function set min(value : Number) : void {
			this._min = value;
		}

		public function get max() : Number {
			return this._max;
		}

		public function set max(value : Number) : void {
			this._max = value;
		}

		public function get orientation() : String {
			return this._orientation;
		}

		public function set orientation(orien : String) : void {
			this._orientation = orien;
			if (this.orientation == VERTICAL) {
				this.minWidth = 15;
				this.maxWidth = 15;
				this.minHeight = 0;
				this.maxHeight = -1;
			} else if (this.orientation == HORIZONTAL) {
				this.minWidth = 0;
				this.maxWidth = -1;
				this.minHeight = 15;
				this.maxHeight = 15;
			}
		}

		public function get value() : Number {
			return this._value;
		}

		public function set value(value : Number) : void {
			this._value = Math.min(Math.max(0, value), 1);
			this.draw();
		}

		private function set state(tate : String) : void {
			this._state = tate;
			this.draw();
		}

		private function evaluate() : void {
			if (this._orientation == VERTICAL) {
				if (this._scrollPos.y < 0) {
					this._scrollPos.y = 0;
				}
				if ((this._scrollPos.y + Math.max(this._scrollHeight, 15)) > height) {
					this._scrollPos.y = height - Math.max(this._scrollHeight, 15);
				}
				this._value = this._scrollPos.y / (height - Math.max(this._scrollHeight, 15));
			} else {
				if (this._scrollPos.x < 0) {
					this._scrollPos.x = 0;
				}
				if (this._scrollPos.x + Math.max(this._scrollWidth, 15) > width) {
					this._scrollPos.x = width - Math.max(this._scrollWidth, 15);
				}
				this._value = this._scrollPos.x / (width - Math.max(this._scrollWidth, 15));
			}
		}

		override public function draw() : void {
			if (this._orientation == VERTICAL) {
				this._scrollWidth = width;
				this._scrollHeight = height / 5;
				this._scrollPos.y = this._value * (height - Math.max(this._scrollHeight, 15));
			} else {
				this._scrollWidth = width / 5;
				this._scrollHeight = height;
				this._scrollPos.x = this._value * (width - Math.max(this._scrollWidth, 15));
			}
			this._scrollBar.x = this._scrollPos.x;
			this._scrollBar.y = this._scrollPos.y;
			if ((this._lastWidth == width) && (this._lastHeight == height) && (this._lastState == this._state)) {
				return;
			}
			this.view.graphics.clear();
			var wh : int = 14;
			this._border.graphics.clear();
			this._border.graphics.lineStyle(1, Style.borderColor2, 1, true);
			this._border.graphics.drawRoundRect(0, 0, width, height, wh, wh);
			this._border.graphics.drawRect(0, 0, width, height);
			this._background.graphics.clear();
			this._background.graphics.beginFill(Style.backgroundColor);
			this._background.graphics.drawRect(0, 0, width, height);
			var w : Number = Math.max(this._scrollWidth, 15);
			var h : Number = Math.max(this._scrollHeight, 15);
			this._scrollBar.graphics.clear();
			var mt : Matrix = new Matrix();
			mt.createGradientBox(w, h, (this.orientation == VERTICAL ? 0 : Math.PI * 0.5));
			if (this._state != "down") {
				this._scrollBar.graphics.beginGradientFill(GradientType.LINEAR, [0x707070, 0x404040], null, null, mt);
			} else {
				this._scrollBar.graphics.beginGradientFill(GradientType.LINEAR, [0x606060, 0x303030], null, null, mt);
			}
			this._scrollBar.graphics.drawRoundRect(3, 3, w - 5, h - 5, wh, wh);
			this._lastWidth = width;
			this._lastHeight = height;
			this._lastState = this._state;
		}

	}
}
