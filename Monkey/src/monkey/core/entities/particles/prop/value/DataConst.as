package monkey.core.entities.particles.prop.value {
	
	/**
	 * 常量 
	 * @author Neil
	 * 
	 */	
	public class DataConst extends PropData {
		
		public var value : Number = 0;
		
		public function DataConst(value : Number = 5) {
			super();
			this.value = value;
		}
		
		override public function getValue(x : Number) : Number {
			return value;
		}
		
	}
}
