package ui.core.controls {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import ui.core.event.ControlEvent;
	
	/**
	 * 
	 * @author neil
	 * 
	 */	
	public class Image extends Control {
		
		/**
		 * 是否拉伸
		 */
		public var stretch  : Boolean = false;
		
		private var _bitmap : Bitmap;
		
		/**
		 *  
		 * @param source	图片源
		 * @param stretch	是否拉伸
		 * @param width		宽度
		 * @param height	高度
		 * 
		 */		
		public function Image(source : Object = null, stretch : Boolean = false, width : Number = NaN, height : Number = NaN) {
			this.stretch   = stretch;
			this.source    = source;
			this.minHeight = 1;
			this.minWidth  = 1;
			if (!(isNaN(width)) && !(isNaN(height))) {
				this.flexible 	= 1;
				this.minWidth 	= width;
				this.maxWidth 	= width;
				this.minHeight 	= height;
				this.maxHeight 	= height;
				this.width 		= width;
				this.height 	= height;
			}
			this.view.addEventListener(MouseEvent.CLICK, onClicked);
		}
		
		protected function onClicked(event:MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.CLICK, this));			
		}
		
		/**
		 * 图片源 
		 * @param value
		 * 
		 */		
		public function set source(value : Object) : void {
			if (this._bitmap != null) {
				this.view.removeChild(this._bitmap);
				this._bitmap = null;
			}
			if (value is Bitmap) {
				this._bitmap = value as Bitmap;
			} else if (value is BitmapData) {
				this._bitmap = new Bitmap(value as BitmapData);
			} else if (value is String) {
				var loader : Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.completeLoaderEvent);
				loader.load(new URLRequest(value as String));
			}
			if (this._bitmap != null) {
				this.view.addChild(this._bitmap);
				if (this.stretch) {
					this._bitmap.smoothing = true;
					this._bitmap.width     = width;
					this._bitmap.height    = height;
				} else {
					this.width  = this._bitmap.width;
					this.height = this._bitmap.height;
				}
			}
			this.draw();
		}
				
		private function completeLoaderEvent(e : Event) : void {
			this._bitmap = (e.target.content as Bitmap);
			if (!this.view.contains(this._bitmap)) {
				this.view.addChild(this._bitmap);
			}
			this.draw();
		}
				
		public function get source() : Object {
			return this._bitmap;
		}
		
		override public function draw() : void {
			if (this._bitmap == null) {
				return;
			}
			if (this.stretch == false) {
				this._bitmap.x = 0;
				this._bitmap.y = 0;
				this._bitmap.scaleX = 1;
				this._bitmap.scaleY = 1;
			} else {
				this._bitmap.width  = width;
				this._bitmap.height = height;
				this._bitmap.x 		= 0;
				this._bitmap.y 		= 0;
			}
		}
	}
}