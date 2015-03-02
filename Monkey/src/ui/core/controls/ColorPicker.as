package ui.core.controls {

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IColorControl;

	/**
	 *
	 * @author neil
	 *
	 */
	public class ColorPicker extends Control implements IColorControl {

		private static var h : int;
		private static var v : int;
		private static var nullBitmapData : BitmapData = new BitmapData(32, 32, false, 0xFF0000);

		private var _picker : Sprite;
		private var _color : int = 0xFFFFFF;
		private var _alpha : Number = 1;
		private var _mode : int;
		private var _colorPanel : ColorPanel;
		private var _colorWindow : Window;

		public function ColorPicker(color : int = 0xFFFFFF, alpha : Number = 1, mode : int = 0) {
			this._colorPanel = new ColorPanel();
			this._colorWindow = new Window(Window.CENTER);
			this._colorWindow.window = this._colorPanel;
			this._colorWindow.close();
			this._picker = new Sprite();
			this._picker.buttonMode = true;
			this._picker.addEventListener(MouseEvent.CLICK, this.clickEvent);
			this.flexible = 1;
			this.minWidth = 50;
			this.maxWidth = 50;
			this.minHeight = 18;
			this.maxHeight = 18;
			this.color = color;
			this.alpha = alpha;
			this._mode = mode;
			this.drawCheckered();
			this.draw();
			this.view.addChild(this._picker);

			if (this.view.stage != null) {
				this.view.stage.addChild(this._colorWindow.view);
			} else {
				this.view.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			}
		}

		protected function onAddToStage(event : Event) : void {
			this.view.stage.addChild(this._colorWindow.view);
			this.view.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
		}

		private function drawCheckered() : void {
			h = 0;

			while (h < 16) {
				v = 0;

				while (v < 16) {
					nullBitmapData.fillRect(new Rectangle(h * 8, v * 8, 8, 8), ((((h % 2 + v % 2) % 2) == 0) ? 0xFFFFFF : 0xB0B0B0));
					v++;
				}
				h++;
			}
		}

		private function clickEvent(e : MouseEvent) : void {
			this._colorWindow.open();
			this._colorPanel.targetControl = this;
			this._colorPanel.addEventListener(ControlEvent.CHANGE, this.changeControlEvent, false, 0, true);
			this._colorPanel.addEventListener(ControlEvent.UNDO, dispatchEvent, false, 0, true);
		}

		private function undoControlEvent(e : ControlEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
		}

		private function changeControlEvent(e : ControlEvent) : void {
			this._alpha = this._colorPanel.alpha;
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}
		
		override public function draw() : void {
			this._picker.graphics.clear();
			this._picker.graphics.lineStyle(1, Style.borderColor2, 1, true);
			this._picker.graphics.beginBitmapFill(nullBitmapData);
			this._picker.graphics.drawRect(0, 0, width, height);
			this._picker.graphics.endFill();
			this._picker.graphics.beginFill(this._color, this._alpha);
			this._picker.graphics.drawRect(0, 0, width, height);
			this._picker.graphics.endFill();
		}

		public function set color(value : int) : void {
			this._color = value;
			this.draw();
		}

		public function get color() : int {
			return this._color;
		}

		public function set alpha(value : Number) : void {
			this._alpha = value;
			this.draw();
		}

		public function get alpha() : Number {
			return this._alpha;
		}

		public function get red() : int {
			return (this._color >> 16) & 0xFF;
		}

		public function get green() : int {
			return (this._color >> 8) & 0xFF;
		}

		public function get blue() : int {
			return this._color & 0xFF;
		}

		public function fromRGB(r : int, g : int, b : int) : void {
			this._color = (((r << 16) ^ (g << 8)) ^ b);
			this.draw();
		}

		public function fromVector(value : Vector.<Number>) : void {
			this._color = 0;

			if (value.length >= 4) {
				this._color = (this._color | (int((value[3] * 0xFF)) << 24));
			}

			if (value.length >= 1) {
				this._color = (this._color | (int((value[0] * 0xFF)) << 16));
			}

			if (value.length >= 2) {
				this._color = (this._color | (int((value[1] * 0xFF)) << 8));
			}

			if (value.length >= 3) {
				this._color = (this._color | int((value[2] * 0xFF)));
			}
			this.draw();
		}

		public function get mode() : int {
			return this._mode;
		}

	}
}
