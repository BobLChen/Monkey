package monkey.core.entities.particles.prop.value {
	
	import flash.geom.Point;
	
	import monkey.core.utils.Linears;
	
	/**
	 * 线性插值
	 * @author Neil
	 * 
	 */	
	public class DataLinear extends PropData {
		
		public var curve  : Linears;
		public var yValue : Number;
		
		public function DataLinear(value : Number = 5) {
			super();
			this.yValue = value;
			this.curve  = new Linears();
			this.curve.datas.push(new Point(0, value));
		}
		
		override public function getValue(x : Number) : Number {
			return curve.getY(x);
		}
	}
}
