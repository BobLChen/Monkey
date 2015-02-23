package monkey.core.base {
	
	import flash.geom.Vector3D;
	
	/**
	 * 包围盒
	 * @author neil
	 */
	public class Bounds3D {
		
		private var _length : Vector3D;
		private var _min 	: Vector3D;
		private var _max 	: Vector3D;
		private var _center : Vector3D;
		private var _radius : Number;
		
		public function Bounds3D() {
			this.reset();
		}
		
		/**
		 * 半径 
		 * @return 
		 * 
		 */		
		public function get radius():Number {
			return _radius;
		}
		
		/**
		 * 半径 
		 * @param value
		 * 
		 */		
		public function set radius(value:Number):void {
			_radius = value;
		}

		/**
		 * 长度 
		 * @return 
		 * 
		 */		
		public function get length() : Vector3D {
			return _length;
		}
		
		/**
		 * 长度 
		 * @return 
		 * 
		 */		
		public function set length(value : Vector3D) : void {
			_length = value;
		}
		
		/**
		 * max 
		 * @return 
		 * 
		 */		
		public function get max() : Vector3D {
			return _max;
		}
		
		/**
		 * max 
		 * @return 
		 * 
		 */		
		public function set max(value : Vector3D) : void {
			_max = value;
		}
		
		/**
		 * 中心 
		 * @return 
		 * 
		 */		
		public function get center() : Vector3D {
			return _center;
		}
		
		/**
		 * 中心 
		 * @return 
		 * 
		 */	
		public function set center(value : Vector3D) : void {
			_center = value;
		}
		
		/**
		 * min 
		 * @return 
		 * 
		 */		
		public function get min() : Vector3D {
			return _min;
		}
		
		/**
		 * min 
		 * @return 
		 * 
		 */	
		public function set min(value : Vector3D) : void {
			_min = value;
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		public function clone() : Bounds3D {
			var bounds : Bounds3D = new Bounds3D();
			bounds.min    = this.min.clone();
			bounds.max    = this.max.clone();
			bounds.length = this.length.clone();
			bounds.center = this.center.clone();
			return bounds;
		}
		
		public function toString() : String {
			return '[object Boundings3D min=' + min + ', max=' + max + ', center=' + center + ', length=' + length + ']';
		}
		
		/**
		 * 重置 
		 */		
		public function reset() : void {
			this.min    = new Vector3D();
			this.max    = new Vector3D();
			this.center = new Vector3D();
			this.length = new Vector3D();
			this.radius = 0;
		}
				
		/**
		 * 复制 
		 * @param bounds
		 * 
		 */		
		public function copyFrom(bounds : Bounds3D) : void {
			this.min.copyFrom(bounds.min);
			this.max.copyFrom(bounds.max);
			this.center.copyFrom(bounds.center);
			this.length.copyFrom(bounds.length);
			this.radius = bounds.radius;
		}
	}
}
