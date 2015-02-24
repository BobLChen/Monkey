package monkey.core.entities.particles.prop.value {
	
	import monkey.core.utils.Curves;
	
	/**
	 * 曲线 
	 * @author Neil
	 * 
	 */	
	public class PropCurves extends PropData {
		
		public var curve : Curves;
		
		public function PropCurves() {
			super();
			this.curve = new Curves();
		}
		
		override public function getValue(x : Number) : Number {
			return curve.getY(x);
		}
	}
}
