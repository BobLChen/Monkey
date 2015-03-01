package ui.core.container {

	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import ui.core.Style;
	import ui.core.controls.BitmapFont;
	import ui.core.controls.Control;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;

	/**
	 *
	 * @author neil
	 *
	 */
	public class Accordion extends Container {

		protected static var HEADER_HEIGHT : Number = 15;
		[Embed(source = "arrow.png")]
		protected static var Arrow : Class;
		protected static var font  : BitmapFont = new BitmapFont(new TextFormat("tahoma", 10, 0x404040, true));

		protected var _header 	: Sprite;
		protected var _arrow 	: Bitmap;
		protected var _box 		: Box;
		protected var _text 	: String = "";
		protected var _open 	: Boolean;
		
		public function Accordion(txt : String = "") {
			super();
			this._header = new Sprite();
			this._box = new Box();
			this._box.margins = 0;
			this._box.space = 1;
			this._arrow = new Arrow();

			this._header.transform.colorTransform = Style.colorTransform;
			this._header.addEventListener(MouseEvent.CLICK, this.clickHeaderEvent, false, 0, true);
			this._header.buttonMode = true;
			this._header.addChild(this._arrow);
			this._header.tabChildren = false;
			this._header.tabEnabled = false;
			this._box.y = HEADER_HEIGHT + this._box.space;
			this._box.addEventListener(ControlEvent.CLICK, dispatchEvent);
			this._box.addEventListener(ControlEvent.UNDO, dispatchEvent);
			this._box.addEventListener(ControlEvent.STOP, dispatchEvent);
			this._box.addEventListener(ControlEvent.CHANGE, dispatchEvent);
			this.contentHeight = 100;
			this.view.addChild(this._box.view);
			this.text = txt;
			this.open = true;
		}

		public function set contentHeight(value : Number) : void {
			this._box.minHeight = value;
			this._box.maxHeight = value;
			this._box.height = value;
			this._box.update();
			this._box.draw();
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
				TweenLite.to(this._arrow, 0.25, {rotation: 90});
				TweenLite.to(this._box.view, 0.25, {alpha: 1, onComplete: this.completeResizeEvent});
				maxHeight = HEADER_HEIGHT + Math.max(this._box.maxHeight, 0);
				minHeight = HEADER_HEIGHT + Math.max(this._box.minHeight, 0);
				height = HEADER_HEIGHT + Math.max(this._box.height, 0);
				this.updateEvent();
				dispatchEvent(new ControlEvent(Event.RESIZE, this));
			} else {
				this._box.visible = false;
				TweenLite.killTweensOf(this);
				TweenLite.to(this._arrow, 0.25, {rotation: 0});
				TweenLite.to(this._box.view, 0.25, {alpha: 0, onComplete: this.completeResizeEvent});
				TweenLite.to(this, 0.2, {minHeight: HEADER_HEIGHT, maxHeight: HEADER_HEIGHT, onUpdate: this.updateEvent, onComplete: this.completeEvent});
			}
		}

		private function completeResizeEvent() : void {
			if (view.stage) {
				view.stage.dispatchEvent(new Event(Event.RESIZE));
				view.stage.dispatchEvent(new Event(Event.RESIZE));
			}
		}

		override public function set height(value : Number) : void {
			super.height = value;
		}

		override public function get height() : Number {
			if (open) {
				if (HEADER_HEIGHT + _box.height < minHeight)
					return minHeight;
				return HEADER_HEIGHT + _box.height;
			} else {
				if (HEADER_HEIGHT < minHeight)
					return minHeight;
				return HEADER_HEIGHT;
			}
		}

		private function updateEvent() : void {
			var control : Container = this;

			while (control.parent != null) {
				control = control.parent;
			}
			control.update();
			control.draw();
		}

		private function completeEvent() : void {
			this._box.visible = false;
			this.dispatchEvent(new ControlEvent(Event.RESIZE, this));
		}

		public function get text() : String {
			return this._text;
		}

		public function set text(value : String) : void {
			this._text = value;
			this.draw();
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
				this.maxHeight = (HEADER_HEIGHT + this._box.maxHeight);
			}
			super.update();
		}

		override public function draw() : void {
			super.draw();
			this._box.width = width;
			this._box.update();
			this._box.draw();
			this._header.graphics.clear();
			this._header.graphics.beginFill(0xB0B0B0);
			this._header.graphics.drawRect(0, 0, width, HEADER_HEIGHT);
			this._arrow.x = 10;
			this._arrow.y = HEADER_HEIGHT * 0.25;
			font.draw(this._header.graphics, 17, -1, width - 10, HEADER_HEIGHT, this.text, Align.LEFT + Align.VCENTER);
			view.addChildAt(this._header, 0);
			this.dispatchEvent(new ControlEvent(ControlEvent.DRAW, this));
		}

	}
}
