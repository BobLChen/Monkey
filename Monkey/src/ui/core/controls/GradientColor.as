package ui.core.controls {

	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import ui.core.Menu;
	import ui.core.Style;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IColorControl;

	public class GradientColor extends Control implements IColorControl {

		private static var nullBitmapData : BitmapData;
		private static var shape : Shape = new Shape();
		private static var matrix : Matrix = new Matrix();

		private var _current : ColorKey;
		private var _keys : Vector.<ColorKey>;
		private var _colors : Array;
		private var _alphas : Array;
		private var _ratios : Array;
		private var _keyMoved : Boolean;
		private var _mode : int;
		private var _menu : Menu;
		private var _colorPanel : ColorPanel;
		private var _colorWindow : Window;
		private var _gradientView : Sprite;

		public function GradientColor() {
			super();

			if (nullBitmapData == null) {
				nullBitmapData = new BitmapData(64, 64, false, 0xFF0000);
				var w : int = 8;
				var h : int = 0;
				while (h < 8) {
					var v : int = 0;
					while (v < 8) {
						nullBitmapData.fillRect(new Rectangle(h * w, v * w, w, w), ((h % 2 + v % 2) % 2 == 0) ? 0xFFFFFF : 0xB0B0B0);
						v++;
					}
					h++;
				}
			}
			
			this._gradientView = new Sprite();
			this.view.addChild(this._gradientView);
			
			this._keys = new Vector.<ColorKey>();
			this.addKey(0xFFFFFF, 1, 0);
			
			this._colorPanel = new ColorPanel();
			this._colorWindow = new Window(Window.CENTER);
			this._colorWindow.window = this._colorPanel;
			this._colorWindow.close();
			
			this._menu = new Menu();
			this._menu.addMenuItem("Remove Key", removeKeyEvent);
			this._menu.menu.hideBuiltInItems();
			this._gradientView.contextMenu = _menu.menu;

			this.minHeight = 18;
			this.maxHeight = 18;
			this.height = 18;
			this.flexible = 1;
			
			this._gradientView.cacheAsBitmap = true;
			this._gradientView.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownEvent, false, 0, true);
			
			if (this._gradientView.stage != null) {
				onAddToStage(null);
			} else {
				this._gradientView.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			}
		}
		
		private function onAddToStage(event : Event) : void {
			this.view.stage.addChild(_colorWindow.view);
		}

		private function removeKeyEvent(e : Event) : void {
			this.removeKey(this._keys.indexOf(this.current));
		}
		
		private function mouseDownEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
						
			var bmp : BitmapData = new BitmapData(width, 5, true, 0);
			bmp.draw(_gradientView);
			var opcity : Number = (((bmp.getPixel32(_gradientView.mouseX, 2) >> 24) & 0xFF) / 0xFF);
			var color : int = bmp.getPixel(_gradientView.mouseX, 2);
			bmp.dispose();
			
			this.current = this.addKey(color, opcity, ((_gradientView.mouseX / width) * 0xFF));
			this._keyMoved = false;
			
			this._gradientView.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.keyMouseMoveEvent, false, 0, true);
			this._gradientView.stage.addEventListener(MouseEvent.MOUSE_UP, this.keyMouseUpEvent, false, 0, true);
			
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
			
			this._colorWindow.open();
			this._colorPanel.targetControl = this;
			this._colorPanel.addEventListener(ControlEvent.CHANGE, this.changeColorEvent, false, 0, true);
			this._colorPanel.addEventListener(ControlEvent.UNDO, dispatchEvent, false, 0, true);
		}

		public function addKey(color : int, opcity : Number, ratio : Number) : ColorKey {
			while (_gradientView.numChildren) {
				this._gradientView.removeChildAt(0);
			}
			this.current = new ColorKey(color, opcity, ratio);
			this.current.addEventListener(MouseEvent.CLICK, keyClickEvent, false, 0, true);
			this.current.addEventListener(MouseEvent.MOUSE_DOWN, keyMouseDownEvent, false, 0, true);
			this.current.addEventListener(MouseEvent.RIGHT_CLICK, removeKeyEvent, false, 0, true);
			this._keys.push(this.current);
			this.draw();
			return this.current;
		}

		public function removeKey(idx : int) : void {
			while (_gradientView.numChildren) {
				this._gradientView.removeChildAt(0);
			}
			this._keys.splice(idx, 1);
			this.current = null;
			this.draw();
		}

		public function removeAllKeys() : void {
			while (_gradientView.numChildren) {
				this._gradientView.removeChildAt(0);
			}
			this._keys = Vector.<ColorKey>([]);
			this.current = null;
			this.draw();
		}

		private function keyClickEvent(e : MouseEvent) : void {
			if (!this._keyMoved) {
				this._colorWindow.open();
			}
		}

		private function keyMouseDownEvent(e : MouseEvent) : void {
			e.stopPropagation();
			
			this._keyMoved = false;
			this.current = (e.target as ColorKey);
			
			this._colorPanel.targetControl = this;
			this._colorPanel.addEventListener(ControlEvent.CHANGE, this.changeColorEvent, false, 0, true);
			this._colorPanel.addEventListener(ControlEvent.UNDO, dispatchEvent, false, 0, true);
			this._colorWindow.open();
			
			this._gradientView.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.keyMouseMoveEvent);
			this._gradientView.stage.addEventListener(MouseEvent.MOUSE_UP, this.keyMouseUpEvent);
		}
		
		private function keyMouseMoveEvent(e : MouseEvent) : void {
			if (!this._keyMoved) {
				this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
			}
			this._keyMoved = true;
			this.current.ratio = ((_gradientView.mouseX / width) * 0xFF);
			if ((_gradientView.mouseY < -10) || (_gradientView.mouseY > height + 10) && (this._keys.length > 1)) {
				this.current.visible = false;
			} else {
				this.current.visible = true;
			}
			this.draw();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function keyMouseUpEvent(e : MouseEvent) : void {
			if (!this.current.visible) {
				if (!this._keyMoved) {
					this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this));
				}
				this.removeKey(this._keys.indexOf(this.current));
				this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
			}
			this._gradientView.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.keyMouseMoveEvent);
			this._gradientView.stage.removeEventListener(MouseEvent.MOUSE_UP, this.keyMouseUpEvent);
		}

		override public function draw() : void {
			
			matrix.createGradientBox(width, height);
			
			this._keys.sort(this.sortKeys);
			this._colors = [];
			this._alphas = [];
			this._ratios = [];
			
			for each (var colorKey : ColorKey in this._keys) {
				if (colorKey.visible) {
					this._gradientView.addChild(colorKey);
					colorKey.x = ((colorKey.ratio / 0xFF) * width);
					colorKey.y = (height - 5);
					this._colors.push(colorKey.color);
					this._alphas.push(colorKey.opacity);
					this._ratios.push(colorKey.ratio);
				}
			}
			
			this._gradientView.graphics.clear();
			this._gradientView.graphics.beginFill(0, 0);
			this._gradientView.graphics.drawRect(0, 0, width, height);
			this._gradientView.graphics.lineStyle(1, Style.borderColor2, 1, true);
			this._gradientView.graphics.beginBitmapFill(nullBitmapData);
			this._gradientView.graphics.drawRect(0, 0, width, (height - 6));
			this._gradientView.graphics.beginGradientFill(GradientType.LINEAR, this._colors, this._alphas, this._ratios, matrix, "pad", InterpolationMethod.RGB);
			this._gradientView.graphics.drawRect(0, 0, width, (height - 6));
		}

		public function setColors(colors : Array, opcities : Array = null, ratios : Array = null) : void {
			this._keys = new Vector.<ColorKey>();
			this._current = null;

			while (_gradientView.numChildren) {
				this._gradientView.removeChildAt(0);
			}
			var i : int = 0;

			while (i < ratios.length) {
				var color : int = 0xFFFFFF;
				if (colors != null)
					color = colors[i];
				var opcity : Number = 1;
				if (opcities != null)
					opcity = opcities[i];
				var ratio : Number = ratios[i];
				this.current = this.addKey(color, opcity, ratios[i]);
				i++;
			}
			this.draw();
		}

		private function changeColorEvent(e : ControlEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		public function get color() : int {
			return this.current.color;
		}

		public function set color(color : int) : void {
			if (this.current) {
				this.current.color = color;
				this.current.draw();
			}
			this.draw();
		}

		public function get alpha() : Number {
			return this.current.opacity;
		}

		public function set alpha(alpha : Number) : void {
			if (this.current) {
				this.current.opacity = alpha;
				this.current.draw();
			}
			this.draw();
		}

		public function get colors() : Array {
			return this._colors;
		}

		public function get alphas() : Array {
			return this._alphas;
		}

		public function get ratios() : Array {
			return this._ratios;
		}

		private function set current(value : ColorKey) : void {
			this._current = value;
			for each (var key : ColorKey in this._keys) {
				key.selected = false;
			}
			if (this._current) {
				this._current.selected = true;
			}
		}

		private function get current() : ColorKey {
			return this._current;
		}

		public function get mode() : int {
			return this._mode;
		}

		public function set mode(mode : int) : void {
			this._mode = mode;
		}

		private function sortKeys(key0 : ColorKey, key2 : ColorKey) : int {
			if (key0.ratio > key2.ratio) {
				return 1;
			}
			if (key0.ratio < key2.ratio) {
				return -1;
			}
			return 0;
		}

	}
}

import flash.display.Sprite;
import flash.filters.DropShadowFilter;

class ColorKey extends Sprite {

	public var color : int = 0xFFFFFF;
	public var opacity : Number = 1;
	private var _selected : Boolean;
	private var _ratio : Number = 0;

	public function ColorKey(color : int, opacity : Number = 1, ratio : Number = 0) {
		this.color = color;
		this.opacity = opacity;
		this.ratio = ratio;
		this.buttonMode = true;
		this.tabEnabled = false;
		this.draw();
		this.filters = [new DropShadowFilter(4, 45, 0, 0.4)];
	}

	public function get ratio() : Number {
		return this._ratio;
	}

	public function set ratio(ratio : Number) : void {
		if (ratio < 0) {
			ratio = 0;
		}

		if (ratio > 0xFF) {
			ratio = 0xFF;
		}
		this._ratio = ratio;
	}

	public function get selected() : Boolean {
		return this._selected;
	}

	public function set selected(value : Boolean) : void {
		this._selected = value;
		this.draw();
	}

	public function draw() : void {
		this.graphics.clear();
		this.graphics.lineStyle(1, ((this._selected) ? 0xFFCB00 : 0xD6D6D6), 1, true);
		this.graphics.beginFill(this.color);
		this.graphics.moveTo(0, 0);
		this.graphics.lineTo(5, 6);
		this.graphics.lineTo(-5, 6);
	}
}
