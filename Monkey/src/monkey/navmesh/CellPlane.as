package monkey.navmesh {
	
	import flash.geom.Vector3D;
	
	/**
	 * 单元所在平面
	 * 平面可以通过点A和法线定义： (A,B,C)为法线，D为distance,(X,Y,Z)为点
	 * 						(Ax + By + Cz + D = 0)
	 * 						D = -(A, B, C) dot (X, Y, Z)
	 * http://www.cnblogs.com/graphics/archive/2009/10/17/1585281.html
	 * @author neil
	 * 
	 */	
	public class CellPlane {
		
		private var _normal   : Vector3D; // 法线
		private var _point    : Vector3D; // 点
		private var _distance : Number; // 点到平面距离
		
		public function CellPlane(p0 : Vector3D, p1 : Vector3D, p2 : Vector3D) {
			var t0 : Vector3D = p1.subtract(p0);
			var t1 : Vector3D = p2.subtract(p0);
			this._normal = t0.crossProduct(t1);
			this._normal.normalize();
			this._point = p0;
			this._distance = -(_point.dotProduct(_normal));
		}
		
		public function get distance():Number {
			return _distance;
		}

		public function get point():Vector3D {
			return _point;
		}

		public function get normal():Vector3D {
			return _normal;
		}
		
		/**
		 * 获取平面的y值。
		 * 因为:
		 * 		Ax + By + Cz + D = 0
		 * 所以:
		 * 		By = -(Ax + Cz + D)
		 * 		y = -(Ax + Cz + D)/B
		 *  
		 * @param x
		 * @param z
		 * @return 
		 * 
		 */		
		public function getY(x : Number, z : Number) : Number {
			if (_normal != null) {
				return (-(normal.x * x + normal.z * z + distance) / normal.y);
			}
			return 0;
		}
		
		/**
		 * 获取平面z值
		 * 		Ax + By + Cz + D = 0
		 * 		Cz = -(Ax + By + D)
		 * 		z = -(Ax + By + D)/C 
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */		
		public function getZ(x : Number, y : Number) : Number {
			if (_normal != null) {
				return (-(normal.x * x + normal.y * y + distance) / normal.z);
			}
			return 0;
		}
		
		/**
		 * 获取x值
		 * 		Ax + By + Cz + D = 0 
		 * 		Ax = -(By + Cz + D)
		 * 		x = -(By + Cz + D)/A
		 * @param y
		 * @param z
		 * @return 
		 * 
		 */		
		public function getX(y : Number, z : Number) : Number {
			if (_normal != null) {
				return (-(normal.y * y + normal.z * z + distance) / normal.x);
			}
			return 0;
		}
		
	}
}
