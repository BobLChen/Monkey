package monkey.navmesh {

	import flash.geom.Point;
	import flash.geom.Vector3D;

	/**
	 * 将3d线段2d化，用于做线段穿擦检测，线段方位检测。
	 * @author neil
	 *
	 */
	public class Line2D {

		/** 在线段上 */
		public static const ON_LINE 	: int = 0;
		/** 在线段左边,线段方位为：A->B */
		public static const LEFT_SIDE 	: int = 1;
		/** 线段右边,线段方位为：A->B */
		public static const RIGHT_SIDE	: int = 2;
		
		private static const temp : Point = new Point();
		
		private var _pa : Point;
		private var _pb : Point;
		// normal为线段射线,用于检测点在线段左边还是右边
		private var _normal : Point;
		
		public function Line2D(pa : Point, pb : Point) {
			this._pa = pa.clone();
			this._pb = pb.clone();
			this._normal = new Point();
			this.initNormal();
		}
		
		public function initNormal() : void {
			this._normal.x = _pb.x - _pa.x;
			this._normal.y = _pb.y - _pa.y;
		}
		
		public function get normal() : Point {
			return _normal;
		}

		public function get pb() : Point {
			return _pb;
		}
		
		public function set pb(value : Point) : void {
			this._pb.x = value.x;
			this._pb.y = value.y;
			this.initNormal();
		}
		
		public function set pa(value : Point) : void {
			this._pa.x = value.x;
			this._pa.y = value.y;
			this.initNormal();
		}
		
		public function get pa() : Point {
			return _pa;
		}

		/**
		 * 点到线的投影距离
		 * @param p
		 * @return
		 *
		 */
		public function crossProduct(p : Point) : Number {
			temp.x = p.x - _pa.x;
			temp.y = p.y - _pa.y;
			return temp.x * _normal.y - temp.y * _normal.x;
		}
		
		/**
		 * 对点进行分类
		 * @param p
		 * @param epsilon
		 * @return
		 *
		 */
		public function classifyPoint(p : Point, epsilon : Number = 0) : int {
			// 一个点，不是直线
			if (normal.length == 0) {
				if (p.y > pa.y) {
					return LEFT_SIDE;
				} else if (p.y < pa.y) {
					return RIGHT_SIDE;
				} else {
					return ON_LINE;
				}
			}
			var distance : Number = this.crossProduct(p);
			if (distance > epsilon) {
				return RIGHT_SIDE;
			} else if (distance < -epsilon) {
				return LEFT_SIDE;
			}
			return ON_LINE;
		}
		
		public function initByVec3(a : Vector3D, b : Vector3D) : void {
			this._pa.x = a.x;
			this._pb.y = a.z;
			this._pb.x = b.x;
			this._pb.y = b.z;
			this.initNormal();
		}
		
		/**
		 * 判断两线段是否相交
		 * 相交检测算法:
		 *  +---------------------------+
		 |           PB              |
		 |           ^               |
		 |           |               |
		 |           |               |
		 |           |               |
		 |PC+--------------------->PD|
		 |           |               |
		 |           |               |
		 |           +               |
		 |           PA              |
		 |                           |
		 +---------------------------+
		 * 如果PA,PB边和PC,PD边相交。那么PA,PB一定是在PC,PD两侧。PC,PD一定是在PA,PB两侧。
		 * @param	a
		 * @param	b
		 */
		public function interact(line : Line2D) : Boolean {
			var la : int = this.classifyPoint(line.pa);
			var lb : int = this.classifyPoint(line.pb);
			// 检测直线的端点是否和当前线段同侧。
			if (la == ON_LINE || lb == ON_LINE) {
				return true;
			}
			if (la == lb) {
				return false;
			}
			// 检测当前线段端点是在line直线同侧。
			var sa : int = line.classifyPoint(pa);
			var sb : int = line.classifyPoint(pb);
			if (sa == ON_LINE || sb == ON_LINE) {
				return true;
			}
			if (sa == sb) {
				return false;
			}
			return true;
		}
		
		public function toString() : String {
			return "[pa:" + pa + ";pb:" + pb + "]" ;
		}
		
	}
}
