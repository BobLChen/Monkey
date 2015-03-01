package monkey.core.utils {

	import flash.geom.Vector3D;
	
	
	/**
	 * vector3d工具类，避免原生操作对w值的修改 
	 * @author neil
	 * 
	 */	
	public class Vector3DUtils {
		
		public static const vec0 	: Vector3D = new Vector3D();
		public static const vec1 	: Vector3D = new Vector3D();
		public static const vec2 	: Vector3D = new Vector3D();
		public static const UP 		: Vector3D = new Vector3D(0, 1, 0);
		public static const DOWN 	: Vector3D = new Vector3D(0, -1, 0);
		public static const RIGHT 	: Vector3D = new Vector3D(1, 0, 0);
		public static const LEFT 	: Vector3D = new Vector3D(-1, 0, 0);
		public static const FORWARD : Vector3D = new Vector3D(0, 0, 1);
		public static const BACK 	: Vector3D = new Vector3D(0, 0, -1);
		public static const ZERO 	: Vector3D = new Vector3D(0, 0, 0);
		public static const ONE 	: Vector3D = new Vector3D(1, 1, 1);
		
		public static function lengthSquared(a : Vector3D, b : Vector3D) : Number {
			var dx : Number = a.x - b.x;
			var dy : Number = a.y - b.y;
			var dz : Number = a.z - b.z;
			return dx * dx + dy * dy + dz * dz;
		}

		public static function length(a : Vector3D, b : Vector3D) : Number {
			var dx : Number = a.x - b.x;
			var dy : Number = a.y - b.y;
			var dz : Number = a.z - b.z;
			return Math.sqrt(dx * dx + dy * dy + dz * dz);
		}

		public static function setLength(a : Vector3D, length : Number) : void {
			var l : Number = a.length;
			if (l > 0) {
				l = l / length;
				a.x = a.x / l;
				a.y = a.y / l;
				a.z = a.z / l;
			} else {
				a.x = a.y = a.z = 0;
			}
		}

		public static function cross(a : Vector3D, b : Vector3D, out : Vector3D = null) : Vector3D {
			if (!out) {
				out = new Vector3D();
			}
			out.x = a.y * b.z - a.z * b.y;
			out.y = a.z * b.x - a.x * b.z;
			out.z = a.x * b.y - a.y * b.x;
			return out;
		}
		
		public static function sub(a : Vector3D, b : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.x = a.x - b.x;
			out.y = a.y - b.y;
			out.z = a.z - b.z;
			return out;
		}

		public static function add(a : Vector3D, b : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.x = a.x + b.x;
			out.y = a.y + b.y;
			out.z = a.z + b.z;
			return out;
		}

		public static function set(a : Vector3D, x : Number = 0, y : Number = 0, z : Number = 0, w : Number = 0) : void {
			a.x = x;
			a.y = y;
			a.z = z;
			a.w = w;
		}

		public static function negate(a : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.x = -a.x;
			out.y = -a.y;
			out.z = -a.z;
			return out;
		}

		public static function interpolate(a : Vector3D, b : Vector3D, value : Number, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.x = a.x + (b.x - a.x) * value;
			out.y = a.y + (b.y - a.y) * value;
			out.z = a.z + (b.z - a.z) * value;
			return out;
		}

		public static function random(min : Number, max : Number, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.x = Math.random() * (max - min) + min;
			out.y = Math.random() * (max - min) + min;
			out.z = Math.random() * (max - min) + min;
			return out;
		}

		public static function mirror(vector : Vector3D, normal : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			var dot : Number = vector.dotProduct(normal);
			out.x = vector.x - (2 * normal.x) * dot;
			out.y = vector.y - (2 * normal.y) * dot;
			out.z = vector.z - (2 * normal.z) * dot;
			return out;
		}

		public static function min(a : Vector3D, b : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.x = (a.x < b.x) ? a.x : b.x;
			out.y = (a.y < b.y) ? a.y : b.y;
			out.z = (a.z < b.z) ? a.z : b.z;
			return out;
		}

		public static function max(a : Vector3D, b : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.x = (a.x > b.x) ? a.x : b.x;
			out.y = (a.y > b.y) ? a.y : b.y;
			out.z = (a.z > b.z) ? a.z : b.z;
			return out;
		}

		public static function abs(a : Vector3D) : void {
			if (a.x < 0) {
				a.x = -a.x;
			}
			if (a.y < 0) {
				a.y = -a.y;
			}
			if (a.z < 0) {
				a.z = -a.z;
			}
		}
		
		public static function mul(a:Vector3D, b:Vector3D, out:Vector3D) : void {
			out.x = a.x * b.x;
			out.y = a.y * b.y;
			out.z = a.z * b.z;
		}
	}
}
