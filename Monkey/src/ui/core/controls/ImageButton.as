package ui.core.controls {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;
	
	/**
	 * 图片按钮
	 * @author neil
	 * 
	 */	
	public class ImageButton extends Control {
		
		/** toggle */
		public var toggle : Boolean;
		/** 是否拉伸 */
		public var strech : Boolean = false;
		
		private var _source : Object;
		private var _bitmap : Bitmap;
		private var _state 	: String;
		private var _border : Shape;
		private var _array 	: Array;
		private var _index 	: int;
		
		/**
		 * image button 
		 * @param source	图片源
		 * @param toggle	toggle
		 * 
		 */		
		public function ImageButton(source : Object = null, toggle : Boolean = false) {
			super("image");
			this._array = [];
			this._border = new Shape();
			this.source = source;
			this.toggle = toggle;
			this.view.buttonMode = true;
			this.view.addEventListener(MouseEvent.CLICK, 		this.mouseClickEvent);
			this.view.addEventListener(MouseEvent.MOUSE_OVER, 	this.handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_OUT, 	this.handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, 	this.handleEvents);
			this.view.addEventListener(MouseEvent.MOUSE_UP, 	this.handleEvents);
			this.draw();
		}
				
		/**
		 * 图片源 
		 * @param value
		 * 
		 */		
		public function set source(value : Object) : void {
			if (this._bitmap != null) {
				while (view.numChildren > 0) {
					view.removeChildAt(0);
				}
			}
			if (value is Array) {
				for each (var src : Object in value) {
					this._array.push(this.addSource(src));
				}
			} else {
				this._array = [this.addSource(value)];
			}
			this._bitmap = this._array[0];
			if (this._bitmap) {
				this.view.addChild(this._bitmap);
				this.view.addChild(this._border);
				this.width = this._bitmap.width;
				this.height = this._bitmap.height;
				if (this.strech) {
					this._bitmap.smoothing = true;
					this._bitmap.width = width;
					this._bitmap.height = height;
				}
			}
		}

		public function get index() : int {
			return (this._index);
		}

		public function set index(idx : int) : void {
			this._index = idx;
			if (this._array.length > 1) {
				if (this._index >= this._array.length) {
					this._index = 0;
				}
				if (view.contains(this._bitmap)) {
					view.removeChild(this._bitmap);
					this._bitmap = this._array[this._index];
					view.addChild(this._bitmap);
					view.addChild(this._border);
				}
			}
			this.draw();
		}
		
		public function addSource(value : Object) : Bitmap {
			if (value is BitmapData) {
				this._bitmap = new Bitmap(value as BitmapData);
			} else if (value is Bitmap) {
				this._bitmap = value as Bitmap;
			} else if (value is String) {
				var loader : Loader = new Loader();
				loader.contentLoaderInfo.addEventListener("complete", this.completeLoaderEvent);
				loader.load(new URLRequest(value as String));
			}
			this.draw();
			return this._bitmap;
		}

		private function completeLoaderEvent(e : Event) : void {
			this._bitmap = (e.target.content as Bitmap);
			var i : int = 0;
			while (i < this._array.length) {
				if (this._array[i] == null) {
					this._array[i] = this._bitmap;
					break;
				}
				i++;
			}
			this._bitmap = this._array[0];
			if (!view.contains(this._bitmap)) {
				view.addChild(this._bitmap);
				view.addChild(this._border);
			}
			this.draw();
		}

		private function handleEvents(e : MouseEvent) : void {
			this._state = e.type;
			this.draw();
		}
		
		private function mouseClickEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.UNDO, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
			if (this.toggle) {
				if (this._array.length > 1) {
					this._index++;
					if (this._index >= this._array.length) {
						this._index = 0;
					}
					if (view.contains(this._bitmap)) {
						view.removeChild(this._bitmap);
						this._bitmap = this._array[this._index];
						view.addChild(this._bitmap);
						view.addChild(this._border);
					}
				} else {
					this._index = (1 - this._index);
					this.draw();
				}
			}
			dispatchEvent(new ControlEvent(ControlEvent.CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		override public function draw() : void {
			if (this._bitmap == null)
				return;
			this.view.graphics.clear();
			this._border.graphics.clear();
			var w : Number = this._bitmap.width;
			var h : Number = this._bitmap.height;
			switch (this._state) {
				case MouseEvent.MOUSE_OVER:
					this._border.graphics.lineStyle(1, Style.borderColor2, 1, true);
					this._border.graphics.drawRect(0, 0, w, h);
				case MouseEvent.MOUSE_UP:
					view.graphics.beginFill(Style.backgroundColor);
					view.graphics.drawRect(0, 0, w, h);
					this._border.graphics.lineStyle(1, Style.borderColor2, 1, true);
					this._border.graphics.drawRect(0, 0, w, h);
					break;
				case MouseEvent.MOUSE_DOWN:
					view.graphics.beginFill(Style.backgroundColor2);
					view.graphics.drawRect(0, 0, w, h);
					this._border.graphics.lineStyle(1, Style.borderColor, 1, true);
					this._border.graphics.drawRect(0, 0, w, h);
					break;
			}
			if (this.toggle && (this._array.length == 1)) {
				if (this._index == 1) {
					view.graphics.beginFill(Style.backgroundColor2);
					view.graphics.drawRect(0, 0, w, h);
				}
			}
		}

	}
}
