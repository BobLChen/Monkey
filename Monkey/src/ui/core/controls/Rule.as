package ui.core.controls {

	import com.greensock.TweenLite;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;

	public class Rule extends Control {

		private var _gui 			: Shape;
		private var _cursor 		: Shape;
		private var _bmpHeader 		: BitmapData;
		private var _matrix 		: Matrix;
		private var _currentFrame 	: Number = 0;
		private var _mouse 			: Point;
		private var _position 		: Number = 0;
		public var step 			: Number = 5;
		public var size 			: Number = 8;
		
		public function Rule() {
			super();
			this._gui = new Shape();
			this._cursor = new Shape();
			this._matrix = new Matrix();
			this._mouse = new Point();
			this.flexible = 1;
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownEvent, false, 0, true);
			this.view.addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWheelEvent, false, 0, true);
			this.view.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, this.mouseDragEvent, false, 0, true);
			this.view.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.mouseDragEvent, false, 0, true);
			this.view.addChild(this._cursor);
			this.view.addChild(this._gui);
			this.width = 400;
			this.height = 28;
			this.update();
			this.draw();
		}
		
		public function update() : void {
			var cursorHeight : Number = 25;
			this._cursor.graphics.clear();
			this._cursor.graphics.beginFill(Style.backgroundColor2, 0.7);
			this._cursor.graphics.lineStyle(1, 10564660);
			this._cursor.graphics.drawRect(0, 0, this.size, cursorHeight - 1);
			this._bmpHeader = new BitmapData(this.size, 28, true, 0);
			this._gui.graphics.clear();
			this._gui.graphics.lineStyle(1, Style.borderColor2, 1, true);
			this._gui.graphics.moveTo(0, 0);
			this._gui.graphics.lineTo(0, 4);
			this._gui.graphics.moveTo(0, cursorHeight - 4);
			this._gui.graphics.lineTo(0, cursorHeight);
			this._bmpHeader.draw(this._gui);
		}
		
		private function mouseDragEvent(e : MouseEvent) : void {
			this._mouse.setTo(view.mouseX, view.mouseY);
			view.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveDragEvent, false, 0, true);
			view.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.mouseUpDragEvent, false, 0, true);
			view.stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, this.mouseUpDragEvent, false, 0, true);
		}

		private function mouseUpDragEvent(e : MouseEvent) : void {
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveDragEvent);
			view.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, this.mouseUpDragEvent);
			view.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, this.mouseUpDragEvent);
		}

		private function mouseMoveDragEvent(e : MouseEvent) : void {
			this.position = this.position + this._mouse.x - view.mouseX;
			this._mouse.setTo(view.mouseX, view.mouseY);
		}

		private function mouseDownEvent(e : MouseEvent) : void {
			view.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseFrameMoveEvent, false, 0, true);
			view.stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent, false, 0, true);
			view.stage.addEventListener(Event.ENTER_FRAME, this.enterFrameEvent, false, 0, true);
			this.currentFrame = int((view.mouseX / this.size) + (this._position / this.size));
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}
		
		private function mouseUpEvent(e : MouseEvent) : void {
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseFrameMoveEvent);
			view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			view.stage.removeEventListener(Event.ENTER_FRAME, this.enterFrameEvent);
		}

		private function enterFrameEvent(e : Event) : void {
			if (view.mouseX < this.step) {
				this.position = this.position - this.step * 2;
			}
			if (view.mouseX > width) {
				this.position = this.position + this.step * 2;
			}
			var temp : int = this._currentFrame;
			this.currentFrame = int((view.mouseX / this.size) + (this._position / this.size));
			if (temp != this._currentFrame) {
				this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
			}
		}
		
		private function mouseFrameMoveEvent(e : MouseEvent) : void {
			this.currentFrame = int((view.mouseX / this.size) + (this._position / this.size));
			dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function mouseWheelEvent(e : MouseEvent) : void {
			TweenLite.to(this, 0.25, {position: (this.position - (e.delta * 25))});
		}
		
		override public function draw() : void {
			if (this._bmpHeader == null) {
				this.update();
			}
			this.view.scrollRect = new Rectangle(0, 0, width, height);
			this._cursor.x = this._currentFrame * this.size + 1 - this._position;
			var value : int = int(((this._position / this.size) / this.step)) * this.step;
			var lx : int = this._position % (this.size * this.step);
			this._matrix.setTo(1, 0, 0, 1, -(this._position), 0);
			this._gui.graphics.clear();
			this._gui.graphics.beginBitmapFill(this._bmpHeader, this._matrix);
			this._gui.graphics.drawRect(0, 0, width, height);
			var i : int = 0;
			while (i < width) {
				var tx : Number = i - lx + 2;
				Style.defaultFont.draw(this._gui.graphics, tx, (height - 20), 30, height, value.toString(), Align.LEFT);
				if (tx > width) {
					break;
				}
				value = value + this.step;
				i = i + this.size * this.step;
			}
		}
		
		public function get position() : Number {
			return this._position;
		}
		
		public function set position(value : Number) : void {
			this._position = value;
			if (this._position < 0) {
				this._position = 0;
			}
			this.draw();
		}

		public function get currentFrame() : Number {
			return this._currentFrame;
		}
		
		public function set currentFrame(value : Number) : void {
			this._currentFrame = value;
			if (this._currentFrame < 0) {
				this._currentFrame = 0;
			}
			this._cursor.x = this._currentFrame * this.size + 1 - this._position;
		}
		
	}
}
