package monkey.core.entities.primitives {
	import monkey.core.entities.Cone;

	public class Cylinder extends Cone {
		
		private var _radius   : Number;
		private var _height   : Number;
		private var _segments : int;
		
		public function Cylinder(radius : Number = 5, height : Number = 10, segments : int = 12) {
			super(radius, radius, height, segments);
			this._segments= segments;
			this._height  = height;
			this._radius  = radius;
		}
		
		override public function get segments() : int {
			return this._segments;
		}
		
		override public function get height() : Number {
			return this._height;
		}
		
		public function get radius() : Number {
			return this._radius;
		}
		
	}
}
