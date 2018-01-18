package monkey.core.utils {

	public class AngleUtils {

		public function AngleUtils() {

		}

		/**
		 * 弧度转角度
		 * @param	rad
		 * @return
		 */
		public static function rad2deg(rad : Number) : Number {
			return rad / Math.PI * 180.0;
		}

		/**
		 * 角度转弧度
		 * @param	deg
		 * @return
		 */
		public static function deg2rad(deg : Number) : Number {
			return deg / 180.0 * Math.PI;
		}
		
		/**
		 * 角度转360°
		 * @param	deg
		 * @return
		 */
		public static function to360(deg : Number) : Number {
			if (deg < 0)
				deg += 360;
			return deg % 360;
		}

		/**
		 * 角度A和角度B之间最小差值
		 * @param	startDeg			起始角度
		 * @param	endDeg				结束角度
		 * @return
		 */
		public static function nearestDeltaAngle(startDeg : Number, endDeg : Number) : Number {
			startDeg = to360(startDeg);
			endDeg = to360(endDeg);
			var dir : Number = 1;

			if (startDeg > endDeg) {
				dir = startDeg;
				startDeg = endDeg;
				endDeg = dir;
				dir = -1;
			}
			var dt : Number = 360 - endDeg;
			var ll : Number = dt + startDeg;
			var rl : Number = endDeg - startDeg;

			if (ll < rl)
				return ll * dir * (-1);
			else
				return rl * dir;
		}

	}
}
