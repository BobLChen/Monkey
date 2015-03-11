package monkey.core.utils {

	public class MathUtils {
		
		public function MathUtils() {
			
		}
				
		public static function clamp(min : Number, max : Number, smooth : Number) : Number {
			return min + (max - min) * smooth;
		}
		
		public static function isInRange(rot : Number, range : Number, target : Number) : Boolean {
			var l : Number = 0;
			var r : Number = 0;
			rot    = AngleUtils.to360(rot);
			range  = AngleUtils.to360(range);
			target = AngleUtils.to360(target);
			if (rot - range < 0) {
				l = AngleUtils.to360(rot - range);
				r = rot + range;
				if (target >= l) {
					return true;
				} else if (target <= r) {
					return true;
				} else {
					return false;
				}
			} else if (rot + range > 360) {
				r = AngleUtils.to360(rot + range);
				l = rot - range;
				if (target <= r) {
					return true;
				} else if (target >= l) {
					return true;
				} else {
					return false;
				}
			} else if (target >= (rot - range) && target <= (rot + range)) {
				return true;
			} else {
				return false;
			}
			return false;
		}
		
	}
}
