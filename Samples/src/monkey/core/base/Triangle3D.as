package monkey.core.base {
	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class Triangle3D {
		
		private static var _a  : Vector3D = new Vector3D();
		private static var _b  : Vector3D = new Vector3D();
		private static var c   : Vector3D = new Vector3D();
		private static var V   : Vector3D = new Vector3D();
		private static var Rab : Vector3D = new Vector3D();
		private static var Rbc : Vector3D = new Vector3D();
		private static var Rca : Vector3D = new Vector3D();
		private static var sub : Vector3D = new Vector3D();
		
		/**
		 * 原点 
		 */		
		public var v0 : Vector3D;
		/**
		 * 点1 
		 */		
		public var v1 : Vector3D;
		/**
		 * 点2 
		 */		
		public var v2 : Vector3D;
		/**
		 * uv点0 
		 */		
		public var uv0 : Point;
		/**
		 * uv点1 
		 */		
		public var uv1 : Point;
		/**
		 * uv点2 
		 */		
		public var uv2 : Point;
		/**
		 * 法线 
		 */		
		public var normal : Vector3D;
		
		public var plane  : Number;
		
		private var _axis : Number;
		private var _tu1  : Number;
		private var _tv1  : Number;
		private var _tu2  : Number;
		private var _tv2  : Number;
		private var _tu0  : Number;
		private var _tv0  : Number;
		private var _beta : Number;
		private var _alpha: Number;
		
		/**
		 *  
		 * @param v0		v0
		 * @param v1 	v1
		 * @param v2 	v2
		 * @param uv0	uv0
		 * @param uv1	uv1
		 * @param uv2	uv2
		 * 
		 */		
		public function Triangle3D(v0 : Vector3D, v1 : Vector3D, v2 : Vector3D, uv0 : Point = null, uv1 : Point = null, uv2 : Point = null) {
			this.v0 = v0;
			this.v1 = v1;
			this.v2 = v2;
			this.uv0 = uv0;
			this.uv1 = uv1;
			this.uv2 = uv2;
			this.normal = new Vector3D();
			this.update();
		}
		
		public function update() : void {
			_a.x = this.v1.x - this.v0.x;
			_a.y = this.v1.y - this.v0.y;
			_a.z = this.v1.z - this.v0.z;
			
			_b.x = this.v2.x - this.v0.x;
			_b.y = this.v2.y - this.v0.y;
			_b.z = this.v2.z - this.v0.z;
			// 计算法线
			this.normal.x = _b.y * _a.z - _b.z * _a.y;
			this.normal.y = _b.z * _a.x - _b.x * _a.z;
			this.normal.z = _b.x * _a.y - _b.y * _a.x;
			this.normal.normalize();
			this.normal.w = -(this.normal.dotProduct(this.v0));
			// 法线点乘p0 http://www.cnblogs.com/graphics/archive/2009/10/17/1585281.html
			this.plane = this.normal.w;
			// 方便计算uv值
			var nx : Number = this.normal.x > 0 ? this.normal.x : -this.normal.x;
			var ny : Number = this.normal.y > 0 ? this.normal.y : -this.normal.y;
			var nz : Number = this.normal.z > 0 ? this.normal.z : -this.normal.z;
			
			var max : Number = nx > ny ? nx > nz ? nx : nz : ny > nz ? ny : nz;
			
			if (nx == max) {
				this._tu1 = this.v1.y - this.v0.y;
				this._tv1 = this.v1.z - this.v0.z;
				this._tu2 = this.v2.y - this.v0.y;
				this._tv2 = this.v2.z - this.v0.z;
				this._axis = 0;
			} else if (ny == max) {
				this._tu1 = this.v1.x - this.v0.x;
				this._tv1 = this.v1.z - this.v0.z;
				this._tu2 = this.v2.x - this.v0.x;
				this._tv2 = this.v2.z - this.v0.z;
				this._axis = 1;
			} else {
				this._tu1 = this.v1.x - this.v0.x;
				this._tv1 = this.v1.y - this.v0.y;
				this._tu2 = this.v2.x - this.v0.x;
				this._tv2 = this.v2.y - this.v0.y;
				this._axis = 2;
			}
			
		}
		
		/**
		 * 
		 * http://www.cnblogs.com/graphics/archive/2010/08/05/1793393.html
		 * contain point，检测点是否在三角形内
		 * @param x
		 * @param y
		 * @param z
		 * @return
		 *
		 */
		public function isPoint(x : Number, y : Number, z : Number) : Boolean {
			
			if (this._axis == 0) {
				this._tu0 = y - this.v0.y;
				this._tv0 = z - this.v0.z;
			} else if (this._axis == 1) {
				this._tu0 = x - this.v0.x;
				this._tv0 = z - this.v0.z;
			} else {
				this._tu0 = x - this.v0.x;
				this._tv0 = y - this.v0.y;
			}
			
			if (this._tu1 != 0) {
				this._beta = ((this._tv0 * this._tu1) - (this._tu0 * this._tv1)) / ((this._tv2 * this._tu1) - (this._tu2 * this._tv1));
				if (this._beta >= 0 && this._beta <= 1) {
					this._alpha = (this._tu0 - this._beta * this._tu2) / this._tu1;
				}
			} else {
				this._beta = (this._tu0 / this._tu2);
				if (this._beta >= 0 && this._beta <= 1) {
					this._alpha = (this._tv0 - this._beta * this._tv2) / this._tv1;
				}
			}
			if (this._alpha >= 0 && this._beta >= 0 && this._alpha + this._beta <= 1) {
				return true;
			}
			return false;
		}
		
		public function closetLineOnPoint(p : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null)
				out = new Vector3D();
			
			this.closetPointOnLine(this.v0, this.v1, p, Rab);
			this.closetPointOnLine(this.v1, this.v2, p, Rbc);
			this.closetPointOnLine(this.v2, this.v0, p, Rca);
			
			sub.x = p.x - Rab.x;
			sub.y = p.y - Rab.y;
			sub.z = p.z - Rab.z;
			var dAB : Number = sub.length;
			
			sub.x = p.x - Rbc.x;
			sub.y = p.y - Rbc.y;
			sub.z = p.z - Rbc.z;
			var dBC : Number = sub.length;
			
			sub.x = p.x - Rca.x;
			sub.y = p.y - Rca.y;
			sub.z = p.z - Rca.z;
			var dCA : Number = sub.length;
			
			var min : Number = dAB;
			out.x = v0.x - v1.x;
			out.y = v0.y - v1.y;
			out.z = v0.z - v1.z;
			
			if (dBC <= min) {
				min = dBC;
				out.x = v1.x - v2.x;
				out.y = v1.y - v2.y;
				out.z = v1.z - v2.z;
			}
			
			if (dCA < min) {
				out.x = v2.x - v0.x;
				out.y = v2.y - v0.y;
				out.z = v2.z - v0.z;
			}
			
			return out;
		}
		
		/**
		 * 计算距离最近的边 
		 * @param a
		 * @param b
		 * @param p
		 * @param out
		 * 
		 */		
		public function closetPointOnLine(a : Vector3D, b : Vector3D, p : Vector3D, out : Vector3D) : void {
			// p到a的向量
			c.x = p.x - a.x;
			c.y = p.y - a.y;
			c.z = p.z - a.z;
			// b到a的向量
			V.x = b.x - a.x;
			V.y = b.y - a.y;
			V.z = b.z - a.z;
			
			var d : Number = V.length;
			V.normalize();
			var t : Number = V.dotProduct(c);
			
			if (t < 0) {
				out.x = a.x;
				out.y = a.y;
				out.z = a.z;
				return;
			}
			if (t > d) {
				out.x = b.x;
				out.y = b.y;
				out.z = b.z;
				return;
			}
			
			V.x = V.x * t;
			V.y = V.y * t;
			V.z = V.z * t;
			
			out.x = a.x + V.x;
			out.y = a.y + V.y;
			out.z = a.z + V.z;
		}
		
		/**
		 * 计算距离最近的点 
		 * @param p
		 * @param out
		 * 
		 */		
		public function closetPoint(p : Vector3D, out : Vector3D = null) : Vector3D {
			
			if (out == null)
				out = new Vector3D();
			
			this.closetPointOnLine(this.v0, this.v1, p, Rab);
			this.closetPointOnLine(this.v1, this.v2, p, Rbc);
			this.closetPointOnLine(this.v2, this.v0, p, Rca);
			
			sub.x = p.x - Rab.x;
			sub.y = p.y - Rab.y;
			sub.z = p.z - Rab.z;
			var dAB : Number = sub.length;
			
			sub.x = p.x - Rbc.x;
			sub.y = p.y - Rbc.y;
			sub.z = p.z - Rbc.z;
			var dBC : Number = sub.length;
			
			sub.x = p.x - Rca.x;
			sub.y = p.y - Rca.y;
			sub.z = p.z - Rca.z;
			var dCA : Number = sub.length;
			
			var min : Number = dAB;
			out.x = Rab.x;
			out.y = Rab.y;
			out.z = Rab.z;
			
			if (dBC <= min) {
				min = dBC;
				out.x = Rbc.x;
				out.y = Rbc.y;
				out.z = Rbc.z;
			}
			
			if (dCA < min) {
				out.x = Rca.x;
				out.y = Rca.y;
				out.z = Rca.z;
			}
			
			return out;
		}
		
		public function getPointU() : Number {
			if (this.uv0 == null) {
				return 0;
			}
			var v : Number = ((this.uv1.x - this.uv0.x) * this._alpha) + ((this.uv2.x - this.uv0.x) * this._beta) + this.uv0.x;
			return v > 0 ? v - int(v) : v - int(v) + 1;
		}
		
		public function getPointV() : Number {
			if (this.uv0 == null) {
				return 0;
			}
			var v : Number = ((this.uv1.y - this.uv0.y) * this._alpha) + ((this.uv2.y - this.uv0.y) * this._beta) + this.uv0.y;
			return v > 0 ? v - int(v) : v - int(v) + 1;
		}
		
	}
}
