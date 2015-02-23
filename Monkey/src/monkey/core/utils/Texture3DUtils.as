package monkey.core.utils {

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Texture3DUtils {

		public static const HORIZONTAL_CROSS : String = "HORIZONTAL_CROSS";
		public static const VERTICAL_CROSS   : String = "VERTICAL_CROSS";
		
		/**
		 * 将cubeMap解析成6张texture
		 * @param bitmapData
		 * @format horizontalCross|verticalCross
		 * @return
		 */
		public static function extractCubeMap(bitmapData : BitmapData, format : String = "horizontalCross") : Array {
			var data : Array;
			var b : BitmapData;
			var images : Array = [];
			var m : Matrix = new Matrix();
			var bmp : BitmapData = bitmapData;
			var size : int = (((bmp.width > bmp.height)) ? (bmp.width / 4) : (bmp.width / 3));
			if (bmp.width > bmp.height) {
				data = [2, 1, 0, 0, 1, 0, 1, 0, 0, 1, 2, 0, 1, 1, 0, 3, 1, 0];
			} else {
				data = [2, 1, 0, 0, 1, 0, 1, 0, 0, 1, 2, 0, 1, 1, 0, 2, 4, Math.PI];
			}
			var i : int;
			while (i < 6) {
				if (bmp.width == bmp.height) {
					b = bmp;
				} else {
					b = new BitmapData(size, size, bmp.transparent, 0);
					m.identity();
					m.translate((-(size) * data[(i * 3)]), (-(size) * data[((i * 3) + 1)]));
					m.rotate(data[((i * 3) + 2)]);
					b.fillRect(b.rect, 0);
					b.draw(bmp, m);
				}
				images.push(b);
				i++;
			}
			var temps : Array = [];
			temps[0] = images[0];
			temps[1] = images[1];
			temps[2] = images[2];
			temps[3] = images[3];
			temps[4] = images[4];
			temps[5] = images[5];
			return temps;
		}

		public static function extractCubeMap2(bmp : BitmapData, format : String = "HORIZONTAL_CROSS") : Array {
			var w : int = int(bmp.width / (format == HORIZONTAL_CROSS ? 4 : 3));
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
