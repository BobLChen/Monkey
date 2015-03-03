package monkey.core.textures {
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import monkey.core.utils.Texture3DUtils;

	public class BitmapCubeTexture extends CubeTextue3D {
		
		private var _transparent : Boolean;
		private var _bitmapData  : BitmapData;
		
		public function BitmapCubeTexture(bitmapdata : BitmapData) {
			super();
			this.bitmapData 	= bitmapdata;
			this._width			= bitmapdata.width;
			this._height		= bitmapdata.height;
			this._transparent 	= bitmapdata.transparent;
		}
		
		/**
		 * 上传 
		 * @param e
		 * 
		 */		
		override protected function contextEvent(e:Event=null):void {
			super.contextEvent(e);
			var bmps : Array = Texture3DUtils.extractCubeMap(bitmapData);
			var i : int = 0;
			while (i < 6) {
				this.uploadWithMips(bmps[i], i);
				i++;
			}
			for each (var bmp : BitmapData in bmps) {
				bmp.dispose();
			}
		}
				
		/**
		 * 销毁 
		 * 
		 */		
		override public function dispose(force : Boolean = false):void {
			if (disposed) {
				return;
			}
			if (ref > 0 && !force) {
				ref--;
				return;
			}
			this.download(true);
			this._disposed = true;
			if (this._bitmapData) {
				this._bitmapData.dispose();
				this._bitmapData = null;
			}
			this.dispatchEvent(disposeEvent);
		}
		
		private function uploadWithMips(bmp : BitmapData, side : int = 0) : void {
			
			var width 		: int = bmp.width  < 2048 ? bmp.width  : 2048;
			var height 		: int = bmp.height < 2048 ? bmp.height : 2048;
			var w 			: int = 1;
			var h 			: int = 1;
			
			while ((w << 1) <= width) {
				w = w << 1;
			}
			while ((h << 1) <= height) {
				h = h << 1;
			}
			if (!this.texture) {
				this.texture = this.scene.context.createCubeTexture(w, Context3DTextureFormat.BGRA, false);
			}
			
			var matrix : Matrix = new Matrix(w / bmp.width, 0, 0, h / bmp.height);
			var levels : BitmapData = null;
			
			if (this.mipMode == Texture3D.MIP_NONE) {
				if (w != width || h != height) {
					levels = new BitmapData(w, h, this._transparent, 0);
					levels.draw(bmp, matrix, null, null, null, true);
				} else {
					levels = bmp;
				}
				CubeTexture(this.texture).uploadFromBitmapData(levels, side, 0);
				if (levels != bmp) {
					levels.dispose();
				}
				return;
			} 
			
			var mipRect 	: Rectangle = new Rectangle();
			var level 		: int = 0;
			var mips 		: BitmapData = bmp.clone();
			
			while (w >= 1 || h >= 1) {
				if (w == width && h == height) {
					CubeTexture(this.texture).uploadFromBitmapData(bmp, side, level);
				} else {
					mipRect.width  = w;
					mipRect.height = h;
					if (!levels) {
						levels = new BitmapData(w || 1, h || 1, this._transparent, 0);
					} else if (this._transparent) {
						levels.fillRect(mipRect, 0);
					}
					levels.draw(mips, matrix, null, null, mipRect, true);
					CubeTexture(this.texture).uploadFromBitmapData(levels, side, level);
				}
				if (levels) {
					var oldMips : BitmapData = mips;
					mips 	= levels;
					levels 	= oldMips;
				}
				matrix.a = 0.5;
				matrix.d = 0.5;
				w = (w >> 1);
				h = (h >> 1);
				level++;
			}
			if (levels) {
				levels.dispose();
				levels = null;
			}
			if (mips) {
				mips.dispose();
				mips = null;
			}
		}
		
		public function get bitmapData() : BitmapData {
			return _bitmapData;
		}
		
		public function set bitmapData(value : BitmapData) : void {
			_bitmapData = value;
		}
		
	}
}
