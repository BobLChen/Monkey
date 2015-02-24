package monkey.core.entities.particles.prop.value {
	import monkey.core.utils.Curves;
	import monkey.core.utils.MathUtils;
		
	/**
	 * 在两个曲线之间随机 
	 * @author Neil
	 * 
	 */	
	public class PropRandomTwoCurves extends PropData {
		
		private var minCurves : Curves;
		private var maxCurves : Curves;
				
		public function PropRandomTwoCurves() {
			super();
			this.minCurves = new Curves();
			this.maxCurves = new Curves();
		}
		
		override public function getValue(x : Number) : Number {
			var min : Number = minCurves.getY(x);
			var max : Number = maxCurves.getY(x);
			return MathUtils.clamp(min, max, Math.random());
		}
		
	}
}
