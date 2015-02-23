package monkey.core.entities.primitives.particles.prop.value {
	
	import monkey.core.utils.MathUtils;
	
	/**
	 * 在两个常量之间随机 
	 * @author Neil
	 * 
	 */	
	public class PropRandomTwoConst extends PropData {
		
		public var minValue : Number = 0;
		public var maxValue : Number = 0;
		
		public function PropRandomTwoConst() {
			super();
		}
		
		override public function getValue(x : Number) : Number {
			return MathUtils.clamp(minValue, maxValue, Math.random());
		}
		
	}
}
