package monkey.core.textures {

	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	

	public class Bitmap2DTexture extends Texture3D {
		
		private var _bitmapData  : BitmapData;
		private var _transparent : Boolean;
		
		/**
		 * 必须为2的幂 
		 * @param bitmapdata
		 * 
		 */		
		public function Bitmap2DTexture(bitmapdata : BitmapData) {
			super();
			this.bitmapData 	= bitmapdata;
			this.typeMode 			= TYPE_2D;
			this.magMode 	= MAG_LINEAR;
			this.wrapMode   	= WRAP_REPEAT;
			this.mipMode		= MIP_LINEAR;
			this._width			= bitmapdata.width;
			this._height		= bitmapdata.height;
			this._transparent 	= bitmapdata.transparent;
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		override public function clone():Texture3D {
			var c : Bitmap2DTexture = new Bitmap2DTexture(null);
			c.texture		= texture;
			c.scene			= scene;
			c.magMode	= magMode;
			c.wrapMode		= wrapMode;
			c.mipMode		= mipMode;
			c.typeMode			= typeMode;
			c.name			= name;
			c.ref			= ref;
			c._disposed		= _disposed;
			c._width		= _width;
			c._height		= _height;
			c._bitmapData	= _bitmapData;
			c._transparent	= _transparent;
			ref.ref++;
			return c;
		}
		
		/**
		 * 上传 
		 * @param e
		 * 
		 */		
		override protected function contextEvent(e:Event=null):void {
			super.contextEvent(e);
			this.uploadWithMips();
		}
		
		/**
		 * 销毁 
		 * 
		 */		
		override public function dispose(force : Boolean = false):void {
			if (disposed) {
				return;
			}
			this._disposed = true;
			if (ref.ref > 0 && !force) {
				ref.ref--;
				return;
			}
			this.download(true);
			if (this._bitmapData) {
				this._bitmapData.dispose();
			}
		}
								
		private function uploadWithMips() : void {
			this.texture = scene.context.createTexture(width, height, Context3DTextureFormat.BGRA, false);
			if (mipMode == MIP_NONE) {
				Texture(texture).uploadFromBitmapData(bitmapData);
				return;
			} 
			// 上传mips
			var w 		: int = width;
			var h 		: int = height;
			var miplevel: int = 0;
			var mat		: Matrix 	 = new Matrix();
			var mipRect : Rectangle  = new Rectangle();
			var oldMips : BitmapData = null;
			var levels	: BitmapData = null;
			while (w >= 1 || h >= 1) {
				if (w == width && h === height) {
					levels = bitmapData;
				} else {
					levels = new BitmapData(w || 1, h || 1, _transparent, 0);
					levels.draw(oldMips, mat, null, null, mipRect, true);
				}
				Texture(texture).uploadFromBitmapData(levels, miplevel);
				oldMips = levels;
				mat.a = 0.5;
				mat.d = 0.5;
				w = w >> 1;
				h = h >> 1;
				mipRect.width  = w;
				mipRect.height = h;
				miplevel++;
			}
			levels.dispose();
			oldMips.dispose();
		}
		
		public function get bitmapData() : BitmapData {
			return _bitmapData;
		}

		public function set bitmapData(value : BitmapData) : void {
			_bitmapData = value;
		}
				
	}
}