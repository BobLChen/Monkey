package monkey.core.entities.primitives.particles.prop.value {
	
	/**
	 * 常量 
	 * @author Neil
	 * 
	 */	
	public class PropConst extends PropData {
		
		public var value : Number = 0;
		
		public function PropConst(value : Number = 5) {
			super();
			this.value = value;
		}
		
		override public function getValue(x : Number) : Number {
			return value;
		}
		
	}
}
