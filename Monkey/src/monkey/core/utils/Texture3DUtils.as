package monkey.core.utils {

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Texture3DUtils {
		
		public static const HORIZONTAL_CROSS : String = "HORIZONTAL_CROSS";
		public static const VERTICAL_CROSS   : String = "VERTICAL_CROSS";
		
		/**
		 * 获取一个格子bitmapData
		 * @return 
		 * 
		 */		
		public static function get nullBitmapData() : BitmapData {
			var bmp : BitmapData = new BitmapData(64, 64, false, 0xFF0000);
			var h : int = 0;
			var v : int = 0;
			while (h < 8) {
				v = 0;
				while (v < 8) {
					bmp.fillRect(new Rectangle(h * 8, v * 8, 8, 8), (((h % 2 + v % 2) % 2) == 0) ? 0xFFFFFF : 0xB0B0B0);
					v++;
				}
				h++;
			}
			return bmp;
		}
				
		/**
		 * 将cubeMap解析成6张texture
		 * @param bitmapData
		 * @format horizontalCross|verticalCross
		 * @return
		 */
		public static function extractCubeMap(bmp : BitmapData, format : String = "horizontalCross") : Array {
			var data : Array;
			var size : int = bmp.width > bmp.height ? bmp.width / 4 : bmp.width / 3;
			if (bmp.width > bmp.height) {
				data = [2, 1, 0, 0, 1, 0, 1, 0, 0, 1, 2, 0, 1, 1, 0, 3, 1, 0];
			} else {
				data = [2, 1, 0, 0, 1, 0, 1, 0, 0, 1, 2, 0, 1, 1, 0, 2, 4, Math.PI];
			}
			var mat 	: Matrix = new Matrix();
			var images 	: Array = [];
			var b 		: BitmapData;
			var i 		: int = 0;
			while (i < 6) {
				if (bmp.width == bmp.height) {
					b = bmp;
				} else {
					b = new BitmapData(size, size, bmp.transparent, 0);
					mat.identity();
					mat.translate(-size * data[i * 3], -size * data[i * 3 + 1]);
					mat.rotate(data[i * 3 + 2]);
					b.fillRect(b.rect, 0);
					b.draw(bmp, mat);
				}
				images.push(b);
				i++;
			}
			return images;
		}

		public static function extractCubeMap2(bmp : BitmapData, format : String = "HORIZONTAL_CROSS") : Array {
			var w : int = int(bmp.width  / (format == HORIZONTAL_CROSS ? 4 : 3));
			var h : int = int(bmp.height / (format == HORIZONTAL_CROSS ? 3 : 4));
			var imges : Array = new Array();
			var point : Point = new Point();
			
			for (var i : int = 0; i < 6; i++) {
				imges[i] = new BitmapData(w, h, false);
			}
			
			if (format == HORIZONTAL_CROSS) {
				imges[0].copyPixels(bmp, new Rectangle(w, h, w, h), point);
				imges[1].copyPixels(bmp, new Rectangle((w * 2), h, w, h), point);
				imges[2].copyPixels(bmp, new Rectangle((w * 3), h, w, h), point);
				imges[3].copyPixels(bmp, new Rectangle(0, h, w, h), point);
				imges[4].copyPixels(bmp, new Rectangle(w, 0, w, h), point);
				imges[5].copyPixels(bmp, new Rectangle(w, (h * 2), w, h), point);
			} else {
				imges[0].copyPixels(bmp, new Rectangle(w, h, w, h), point);
				imges[1].copyPixels(bmp, new Rectangle((w * 2), h, w, h), point);
				imges[2].draw(bmp, new Matrix(-1, 0, 0, -1, (w * 2), bmp.height));
				imges[3].copyPixels(bmp, new Rectangle(0, h, w, h), point);
				imges[4].copyPixels(bmp, new Rectangle(w, 0, w, h), point);
				imges[5].copyPixels(bmp, new Rectangle(w, (h * 2), w, h), point);
			}
			return imges;
		}
	}
}
