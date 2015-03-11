package monkey.core.utils {

	import flash.geom.Vector3D;

	public class ColorUtils {

		private static const rgb : Vector3D = new Vector3D();

		public function ColorUtils() {

		}
		
		/**
		 * 获取rgb值,rbg值区间:[0, 1]
		 * @param color
		 * @return 
		 * 
		 */		
		public static function getFloatRGB(color : uint) : Vector3D {
			rgb.z = (color & 0xFF) / 0xFF;
			rgb.y = ((color >> 8) & 0xFF) / 0xFF;
			rgb.x = ((color >> 16) & 0xFF) / 0xFF;
			return rgb;
		}
		
		/**
		 * 获取255色rgb 
		 * @param color
		 * @return 
		 * 
		 */		
		public static function get255RGB(color : uint) : Vector3D {
			rgb.z = (color & 0xFF);
			rgb.y = ((color >> 8) & 0xFF);
			rgb.x = ((color >> 16) & 0xFF);
			return rgb;
		}
				
	}
}
