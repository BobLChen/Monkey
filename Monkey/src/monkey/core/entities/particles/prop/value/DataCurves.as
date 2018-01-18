package monkey.core.entities.particles.prop.value {
	
	import flash.geom.Point;
	
	import monkey.core.utils.Curves;
	
	/**
	 * 曲线 
	 * @author Neil
	 * 
	 */	
	public class DataCurves extends PropData {
		
		public var curve  : Curves;
		public var yValue : Number;
		
		public function DataCurves(value : Number = 5) {
			super();
			this.yValue = value;
			this.curve  = new Curves();
			this.curve.datas.push(new Point(0, value));
		}
		
		override public function getValue(x : Number) : Number {
			return curve.getY(x);
		}
	}
}
