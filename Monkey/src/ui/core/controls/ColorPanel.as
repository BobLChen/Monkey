package ui.core.controls {

	import com.greensock.TweenLite;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	import ui.core.Style;
	import ui.core.container.Panel;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IColorControl;
	import ui.core.type.ColorMode;

	public class ColorPanel extends Panel {

		private static var _colorPanel : ColorPanel;
		private static var h : int;
		private static var v : int;
		private static var nullBitmapData : BitmapData = new BitmapData(32, 32, false, 0xFF0000);

		private var _color : int = 0xFFFFFF;
		private var _alpha : Number = 100;
		private var _prevColor : int = 0xFFFFFF;
		private var _prevAlpha : Number = 1;
		private var _brightness : Number = 1;
		private var _saturation : Number = 0;
		private var _hue : Number = 0;
		private var _red : int = 0;
		private var _green : int = 0;
		private var _blue : int = 0;
		private var _colorBar : Control;
		private var _colorTable : Control;
		private var _resultBox : Control;
		private var _gradient : Shape;
		private var _marker : Shape;
		private var _r : Spinner;
		private var _g : Spinner;
		private var _b : Spinner;
		private var _a : Spinner;
		private var _h : InputText;
		private var _targetControl : IColorControl;
		private var _mode : int;
		private var _layout : Layout;
		private var _changed : Boolean;

		public function ColorPanel() {
			super("COLOR", 200, 200, false);
			this._colorBar = new Control("", 0, 0, 150, 15);
			this._colorTable = new Control("", 0, 0, 150, 150);
			this._resultBox = new Control("", 0, 0, 85, 40);
			this._gradient = new Shape();
			this._marker = new Shape();
			this.minWidth = 250;
			this.minHeight = 185;
			this.maxHeight = 185;
			this._r = new Spinner(0xFF, 0, 0xFF, 0, 1);
			this._g = new Spinner(0xFF, 0, 0xFF, 0, 1);
			this._b = new Spinner(0xFF, 0, 0xFF, 0, 1);
			this._a = new Spinner(100, 0, 100, 0, 1);
			this._h = new InputText("FFFFFF");
			this._h.maxWidth = 60;
			this._h.minWidth = 60;
			this._layout = new Layout();
			this.setLayout();
			this.addControl(this._layout);
			this.drawCheckered();
			this._r.addEventListener(ControlEvent.CHANGE, this.changeControlEvent);
			this._g.addEventListener(ControlEvent.CHANGE, this.changeControlEvent);
			this._b.addEventListener(ControlEvent.CHANGE, this.changeControlEvent);
			this._a.addEventListener(ControlEvent.CHANGE, this.changeControlEvent);
			this._h.addEventListener(ControlEvent.CHANGE, this.changeHexEvent);
			this._marker.graphics.clear();
			this._marker.graphics.lineStyle(2, 0xFFFFFF);
			this._marker.graphics.drawCircle(0, 0, 7);
			this._marker.graphics.lineStyle(1, 0x404040);
			this._marker.graphics.drawCircle(0, 0, 6);
			this._colorTable.view.addChild(this._gradient);
			this._colorTable.view.addChild(this._marker);
			this._colorTable.view.addEventListener(MouseEvent.MOUSE_DOWN, this.tableMouseDownEvent);
			this._colorBar.view.addEventListener(MouseEvent.MOUSE_DOWN, this.barMouseDownEvent);
			this.color = this._color;
			this.height = 190;
			this.width = 320;
			this.visible = true;
			this.update();
			this.draw();
			this._colorTable.view.tabEnabled = true;
			this._colorBar.view.tabEnabled = true;
			this._resultBox.view.tabEnabled = true;
			this.view.tabEnabled = true;
			this.view.addEventListener(FocusEvent.FOCUS_OUT, this.focusOutEvent);
		}

		override public function open() : void {
			if (enabled) {
				view.alpha = 0;
				setTimeout(TweenLite.to, 100, view, 0.2, {alpha: 1, onUpdate: function() : void {
					if (!enabled) {
						TweenLite.killTweensOf(view);
						view.alpha = 0.5;
					}
				}});
			}
		}

		public static function get colorPanel() : ColorPanel {
			if (_colorPanel == null) {
				_colorPanel = new ColorPanel();
			}
			return _colorPanel;
		}

		override public function dispatchEvent(e : Event) : Boolean {
			if (e.type == ControlEvent.UNDO) {
				if (!this._changed) {
					super.dispatchEvent(new ControlEvent(ControlEvent.UNDO, (this._targetControl as Control)));
				}
				this._changed = true;
				return true;
			}
			return super.dispatchEvent(e);
		}

		private function undoEvent(e : ControlEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, (this._targetControl as Control)));
			this._changed = true;
		}

		private function focusOutEvent(e : FocusEvent) : void {
			var changed : Boolean;
			var disp : DisplayObject = e.relatedObject;

			while ((disp != null && disp.parent != null) && (disp != view)) {
				disp = disp.parent;
			}
			changed = (disp == view);

			if (!changed) {
				this._changed = false;
			}
		}

		public function get mode() : int {
			return this._mode;
		}

		public function set mode(mode : int) : void {
			this._mode = mode;

			switch (this._mode) {
				case ColorMode.MODE_RGBA:
					break;
				case ColorMode.MODE_RGB:
					this._a.value = 100;
					break;
				case ColorMode.MODE_A:
					this._r.value = 0xFF;
					this._g.value = 0xFF;
					this._b.value = 0xFF;
					break;
			}
			this.setLayout();
		}

		private function setLayout() : void {
			this._layout.removeAllControls();
			this._layout.labelWidth = 20;
			this._layout.addHorizontalGroup();
			this._layout.addVerticalGroup();
			this._layout.addSpace(-1, 3);
			this._layout.addControl(this._colorBar);

			if (this._mode != ColorMode.MODE_A) {
				this._layout.addControl(this._colorTable);
			}
			this._layout.endGroup();
			this._layout.addVerticalGroup();
			this._layout.addSpace(-1, 3);

			if (this._mode != ColorMode.MODE_A) {
				this._layout.addControl(this._r, "R:");
				this._layout.addControl(this._g, "G:");
				this._layout.addControl(this._b, "B:");
			}

			if (this._mode != ColorMode.MODE_RGB) {
				this._layout.addControl(this._a, "A:");
			}

			if (this._mode != ColorMode.MODE_A) {
				this._layout.addControl(this._h, "#:");
			}
			this._layout.addControl(this._resultBox);
			this._layout.endGroup();
			this._layout.endGroup();
		}

		private function changeHexEvent(e : Event) : void {
			e.stopPropagation();
			this._color = int(("0x" + this._h.text));
			this._prevColor = this.color;
			var r : Number = (int((this._color >> 16)) & 0xFF);
			var g : Number = (int((this._color >> 8)) & 0xFF);
			var b : Number = (int((this._color >> 0)) & 0xFF);
			this.updateHsv(r, g, b);
			this._r.value = r;
			this._g.value = g;
			this._b.value = b;
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function changeControlEvent(e : Event) : void {
			e.stopPropagation();
			this._color = (((int(this._r.value) << 16) ^ (int(this._g.value) << 8)) ^ int(this._b.value));
			this._prevColor = this.color;
			this.updateHsv(this._r.value, this._g.value, this._b.value);
			this._alpha = (this._a.value / 100);

			if (this._mode == ColorMode.MODE_A) {
				this._hue = this._alpha;
			}
			this.draw();
			this.dispatchEvent(new ControlEvent(e.type, this));
		}

		private function barMouseDownEvent(e : MouseEvent) : void {
			view.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.barMouseMoveEvent);
			view.stage.addEventListener(MouseEvent.MOUSE_UP, this.barMouseUpEvent);
			this.barMouseMoveEvent(e);
		}

		private function barMouseMoveEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, (this._targetControl as Control)));
			this._hue = this._colorBar.view.globalToLocal(new Point(e.stageX, e.stageY)).x;

			if (this._hue < 0) {
				this._hue = 0;
			}

			if (this._hue > 150) {
				this._hue = 150;
			}

			if (this._mode != ColorMode.MODE_A) {
				this._hue = ((this._hue / 150) * 359.9);
				this._color = this.updateRGB(this._hue, this._saturation, this._brightness);
				this._r.value = this._red;
				this._g.value = this._green;
				this._b.value = this._blue;
			} else {
				this._hue = this._hue / 150;
				this._alpha = this._hue;
				this._a.value = this._alpha * 100;
			}
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function barMouseUpEvent(e : MouseEvent) : void {
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.barMouseMoveEvent);
			view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.barMouseUpEvent);
			this._prevColor = this._color;
			this._prevAlpha = this._alpha;
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function tableMouseDownEvent(e : MouseEvent) : void {
			view.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.tableMouseMoveEvent);
			view.stage.addEventListener(MouseEvent.MOUSE_UP, this.tableMouseUpEvent);
			this.tableMouseMoveEvent(e);
		}

		private function tableMouseMoveEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, (this._targetControl as Control)));
			this._saturation = (this._colorTable.view.globalToLocal(new Point(e.stageX, e.stageY)).x / 150);
			this._brightness = ((150 - this._colorTable.view.globalToLocal(new Point(e.stageX, e.stageY)).y) / 150);
			this._saturation = Math.max(Math.min(1, this._saturation), 0);
			this._brightness = Math.max(Math.min(1, this._brightness), 0);
			this._color = this.updateRGB(this._hue, this._saturation, this._brightness);
			this._r.value = this._red;
			this._g.value = this._green;
			this._b.value = this._blue;
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function tableMouseUpEvent(e : MouseEvent) : void {
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.tableMouseMoveEvent);
			view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.tableMouseUpEvent);
			this._prevColor = this._color;
			this._prevAlpha = this._alpha;
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		public function get color() : int {
			this._red = (int((this._color >> 16)) & 0xFF);
			this._green = (int((this._color >> 8)) & 0xFF);
			this._blue = (int((this._color >> 0)) & 0xFF);
			return this._color;
		}

		public function set color(_arg1 : int) : void {
			this._color = _arg1;
			this._prevColor = _arg1;
			this._r.value = (this._red = (int((this._color >> 16)) & 0xFF));
			this._g.value = (this._green = (int((this._color >> 8)) & 0xFF));
			this._b.value = (this._blue = (int((this._color >> 0)) & 0xFF));
			this.updateHsv(this._red, this._green, this._blue);
			update();
		}

		public function get alpha() : Number {
			return this._alpha;
		}

		public function set alpha(value : Number) : void {
			this._alpha = value;

			if (this._mode == ColorMode.MODE_A) {
				this._hue = value;
			}
			this._a.value = value * 100;
		}

		public function get targetControl() : IColorControl {
			return this._targetControl;
		}

		public function set targetControl(control : IColorControl) : void {
			this._changed = false;
			this._targetControl = control;
			this.mode = control.mode;
			this.color = this._targetControl.color;
			this.alpha = this._targetControl.alpha;
			this._prevColor = this._targetControl.color;
			this._prevAlpha = this._targetControl.alpha;
			this.draw();
		}

		private function drawCheckered() : void {
			h = 0;

			while (h < 16) {
				v = 0;

				while (v < 16) {
					nullBitmapData.fillRect(new Rectangle((h * 8), (v * 8), 8, 8), ((((((h % 2) + (v % 2)) % 2) == 0)) ? 0xFFFFFF : 0xB0B0B0));
					v++;
				}
				h++;
			}
		}

		override public function draw() : void {
			super.draw();
			var mt : Matrix = new Matrix();
			mt.createGradientBox(150, height);
			this._colorBar.view.graphics.clear();
			this._colorBar.view.graphics.lineStyle(1, 0x404040);

			if (this._mode != ColorMode.MODE_A) {
				var colos : Array = [0xFF0000, 0xFFFF00, 0xFF00, 0xFFFF, 0xFF, 0xFF00FF, 0xFF0000];
				this._colorBar.view.graphics.beginGradientFill(GradientType.LINEAR, colos, null, null, mt, SpreadMethod.PAD, InterpolationMethod.RGB);
				this._colorBar.view.graphics.drawRect(0, 0, 150, 15);
			} else {
				this._colorBar.view.graphics.beginBitmapFill(nullBitmapData);
				this._colorBar.view.graphics.drawRect(0, 0, 150, 61);
				this._colorBar.view.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [0, 1], null, mt, SpreadMethod.PAD, InterpolationMethod.RGB);
				this._colorBar.view.graphics.drawRect(0, 0, 150, 61);
			}
			this._colorBar.view.graphics.lineStyle(1, 0x404040);
			this._colorBar.view.graphics.beginFill(Style.backgroundColor);
			this._colorBar.view.graphics.endFill();
			var hue : Number = ((this._hue / 360) * 150);

			if (this._mode == ColorMode.MODE_A) {
				hue = (this._hue * 150);
				this._colorBar.view.graphics.lineStyle(1, 0x404040, 1, true);
				this._colorBar.view.graphics.moveTo(hue, 0);
				this._colorBar.view.graphics.lineTo(hue, 61);
			}
			this._colorBar.view.graphics.lineStyle(1, 0xD6D6D6, 1, true);
			this._colorBar.view.graphics.beginFill(Style.backgroundColor);
			this._colorBar.view.graphics.moveTo(hue, -2);
			this._colorBar.view.graphics.lineTo((hue + 4), -6);
			this._colorBar.view.graphics.lineTo((hue - 4), -6);
			mt.createGradientBox(150, 150);
			colos = [0xFFFFFF, this.updateRGB(this._hue)];
			this._colorTable.view.graphics.clear();
			this._colorTable.view.graphics.lineStyle(1, 0x404040);

			if (this._mode != ColorMode.MODE_A) {
				this._colorTable.view.graphics.beginGradientFill(GradientType.LINEAR, colos, [1, 1], null, mt);
				this._colorTable.view.graphics.drawRect(0, 0, 150, 150);
			}
			this._colorTable.view.scrollRect = new Rectangle(0, 0, 151, 151);
			this.drawGradient();
			mt.setTo(1, 0, 0, 1, 3, 0);
			this._resultBox.view.graphics.clear();
			this._resultBox.view.graphics.beginBitmapFill(nullBitmapData, mt);
			this._resultBox.view.graphics.drawRect(0, 0, 85, 40);
			this._resultBox.view.graphics.beginFill(this._color, this._alpha);
			this._resultBox.view.graphics.drawRect(0, 0, 85, 20);
			this._resultBox.view.graphics.beginFill(this._prevColor, this._alpha);
			this._resultBox.view.graphics.drawRect(0, 20, 85, 20);
			this._resultBox.view.graphics.lineStyle(1, Style.borderColor2);
			this._resultBox.view.graphics.beginFill(0, 0);
			this._resultBox.view.graphics.drawRect(0, 0, 85, 40);
			this._marker.x = (this._saturation * 150);
			this._marker.y = (150 - (this._brightness * 150));
			var colorStr : String = this._color.toString(16);

			while (colorStr.length < 6) {
				colorStr = "0" + colorStr;
			}

			if (this._targetControl != null) {
				this._targetControl.color = this._color;
				this._targetControl.alpha = this._alpha;
			}

			if (this.view.stage != null && this.view.stage.focus != this._h.textField) {
				this._h.text = colorStr.toUpperCase();
			}
		}

		private function drawGradient() : void {
			var mt : Matrix = new Matrix();
			this._gradient.graphics.clear();
			mt.createGradientBox(150, 150, (Math.PI / 2), 0, 0);
			this._gradient.graphics.beginGradientFill(GradientType.LINEAR, [0, 0], [0, 1], null, mt, SpreadMethod.PAD);
			this._gradient.graphics.drawRect(0, 0, 150, 150);
		}

		private function updateRGB(hue : Number = 0, saturation : Number = 1, brightness : Number = 1) : uint {
			var red0 : Number;
			var green0 : Number;
			var blue0 : Number;
			var mode : int;
			var g : Number;
			var b : Number;
			var other : Number;
			hue = hue / 60;
			mode = int(hue);
			var ratio : Number = hue - mode;
			g = brightness * (1 - saturation);
			b = brightness * (1 - saturation * ratio);
			other = brightness * (1 - saturation * (1 - ratio));

			switch (mode) {
				case 0:
					red0 = brightness;
					green0 = other;
					blue0 = g;
					break;
				case 1:
					red0 = b;
					green0 = brightness;
					blue0 = g;
					break;
				case 2:
					red0 = g;
					green0 = brightness;
					blue0 = other;
					break;
				case 3:
					red0 = g;
					green0 = b;
					blue0 = brightness;
					break;
				case 4:
					red0 = other;
					green0 = g;
					blue0 = brightness;
					break;
				default:
					red0 = brightness;
					green0 = g;
					blue0 = b;
			}
			;
			red0 = int(red0 * 0xFF);
			green0 = int(green0 * 0xFF);
			blue0 = int(blue0 * 0xFF);
			this._red = red0;
			this._green = green0;
			this._blue = blue0;
			return ((red0 << 16) ^ (green0 << 8)) ^ blue0;
		}

		private function updateHsv(h : Number, s : Number, v : Number) : void {
			var min : Number;
			var max : Number;
			var delta : Number;
			h = h / 0xFF;
			s = s / 0xFF;
			v = v / 0xFF;
			min = Math.min(h, s, v);
			max = Math.max(h, s, v);
			this._brightness = max;
			delta = max - min;

			if (h + s + v == 3) {
				this._saturation = 0;
				this._brightness = 1;
				return;
			}

			if (max != 0) {
				this._hue = 0;
				this._saturation = delta / max;
			} else {
				this._saturation = 0;
				this._hue = 0;
				return;
			}

			if (delta == 0) {
				this._hue = 0;
			} else if (h == max) {
				this._hue = (s - v) / delta;
			} else if (s == max) {
				this._hue = 2 + ((v - h) / delta);
			} else {
				this._hue = 4 + ((h - s) / delta);
			}
			this._hue = this._hue * 60;

			if (this._hue < 0) {
				this._hue = this._hue + 360;
			}
		}

	}
}
