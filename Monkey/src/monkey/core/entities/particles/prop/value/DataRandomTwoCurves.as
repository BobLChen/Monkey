package monkey.core.entities.particles.prop.value {
	
	import monkey.core.utils.MathUtils;
		
	/**
	 * 在两个曲线之间随机 
	 * @author Neil
	 * 
	 */	
	public class DataRandomTwoCurves extends PropData {
		
		public var minCurves : DataCurves;
		public var maxCurves : DataCurves;
				
		public function DataRandomTwoCurves() {
			super();
			this.minCurves = new DataCurves();
			this.maxCurves = new DataCurves();
		}
		
		override public function getValue(x : Number) : Number {
			var min : Number = minCurves.curve.getY(x);
			var max : Number = maxCurves.curve.getY(x);
			return MathUtils.lerp(min, max, Math.random());
		}
		
	}
}
