package monkey.core.utils {

	public class MathUtils {
		
		public function MathUtils() {
			
		}
				
		public static function clamp(min : Number, max : Number, smooth : Number) : Number {
			return min + (max - min) * smooth;
		}
		
	}
}
