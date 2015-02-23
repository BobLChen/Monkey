package monkey.core.utils {

	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;

	public class Matrix3DUtils {
		
		/** rawData */
		public static const RAW_DATA: Vector.<Number> = new Vector.<Number>(16);
		
		private static var _raw 	: Vector.<Number> = new Vector.<Number>(16, true);
		private static var _toRad 	: Number = 0.0174532925199433;
		private static var _toAng 	: Number = 57.2957795130823;
		private static var _vector 	: Vector3D = new Vector3D();
		private static var _right 	: Vector3D = new Vector3D();
		private static var _up 		: Vector3D = new Vector3D();
		private static var _dir 	: Vector3D = new Vector3D();
		private static var _scale 	: Vector3D = new Vector3D();
		private static var _pos 	: Vector3D = new Vector3D();
		private static var _x 		: Number;
		private static var _y 		: Number;
		private static var _z 		: Number;

		public static function getRight(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(0, out);
			return out;
		}

		public static function getUp(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(1, out);
			return out;
		}

		public static function getDir(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(2, out);
			return out;
		}

		public static function getLeft(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(0, out);
			out.negate();
			return out;
		}

		public static function getDown(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(1, out);
			out.negate();
			return out;
		}

		public static function getBackward(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(2, out);
			out.negate();
			return out;
		}

		public static function getPosition(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(3, out);
			return out;
		}

		public static function getScale(m : Matrix3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			m.copyColumnTo(0, _right);
			m.copyColumnTo(1, _up);
			m.copyColumnTo(2, _dir);
			out.x = _right.length;
			out.y = _up.length;
			out.z = _dir.length;
			return out;
		}

		public static function setPosition(m : Matrix3D, x : Number, y : Number, z : Number, smooth : Number = 1) : void {
			if (smooth == 1) {
				_vector.setTo(x, y, z);
				_vector.w = 1;
				m.copyColumnFrom(3, _vector);
			} else {
				m.copyColumnTo(3, _pos);
				_pos.x = (_pos.x + ((x - _pos.x) * smooth));
				_pos.y = (_pos.y + ((y - _pos.y) * smooth));
				_pos.z = (_pos.z + ((z - _pos.z) * smooth));
				m.copyColumnFrom(3, _pos);
			}
		}

		public static function setOrientation(m : Matrix3D, dir : Vector3D, up : Vector3D = null, smooth : Number = 1) : void {
			getScale(m, _scale);

			if (up == null) {
				if ((((((dir.x == 0)) && ((Math.abs(dir.y) == 1)))) && ((dir.z == 0)))) {
					up = Vector3D.Z_AXIS;
				} else {
					up = Vector3D.Y_AXIS;
				}
			}

			if (smooth != 1) {
				getDir(m, _dir);
				_dir.x = (_dir.x + ((dir.x - _dir.x) * smooth));
				_dir.y = (_dir.y + ((dir.y - _dir.y) * smooth));
				_dir.z = (_dir.z + ((dir.z - _dir.z) * smooth));
				dir = _dir;
				getUp(m, _up);
				_up.x = (_up.x + ((up.x - _up.x) * smooth));
				_up.y = (_up.y + ((up.y - _up.y) * smooth));
				_up.z = (_up.z + ((up.z - _up.z) * smooth));
				up = _up;
			}
			dir.normalize();
			var rVec : Vector3D = up.crossProduct(dir);
			rVec.normalize();
			var uVec : Vector3D = dir.crossProduct(rVec);
			rVec.scaleBy(_scale.x);
			uVec.scaleBy(_scale.y);
			dir.scaleBy(_scale.z);
			setVectors(m, rVec, uVec, dir);
		}

		public static function setNormalOrientation(m : Matrix3D, normal : Vector3D, smooth : Number = 1) : void {
			if (((normal.x == 0) && (normal.y == 0)) && (normal.z == 0)) {
				return;
			}
			getScale(m, _scale);
			getDir(m, _dir);

			if (smooth != 1) {
				getUp(m, _up);
				_up.x = (_up.x + ((normal.x - _up.x) * smooth));
				_up.y = (_up.y + ((normal.y - _up.y) * smooth));
				_up.z = (_up.z + ((normal.z - _up.z) * smooth));
				normal = _up;
			}
			normal.normalize();
			var dir : Vector3D = ((Math.abs(_dir.dotProduct(normal)) == 1)) ? getRight(m, _right) : _dir;
			var rVec : Vector3D = normal.crossProduct(dir);
			rVec.normalize();
			var dVec : Vector3D = rVec.crossProduct(normal);
			rVec.scaleBy(_scale.x);
			normal.scaleBy(_scale.y);
			dVec.scaleBy(_scale.z);
			setVectors(m, rVec, normal, dVec);
		}

		private static function setVectors(m : Matrix3D, right : Vector3D, up : Vector3D, dir : Vector3D) : void {
			right.w = 0;
			up.w = 0;
			dir.w = 0;
			m.copyColumnFrom(0, right);
			m.copyColumnFrom(1, up);
			m.copyColumnFrom(2, dir);
		}

		public static function lookAt(m : Matrix3D, x : Number, y : Number, z : Number, up : Vector3D = null, smooth : Number = 1) : void {
			m.copyColumnTo(3, _pos);
			_vector.x = (x - _pos.x);
			_vector.y = (y - _pos.y);
			_vector.z = (z - _pos.z);
			setOrientation(m, _vector, up, smooth);
		}

		public static function setTranslation(m : Matrix3D, x : Number = 0, y : Number = 0, z : Number = 0, local : Boolean = true) : void {
			if (local) {
				m.prependTranslation(x, y, z);
			} else {
				m.appendTranslation(x, y, z);
			}
		}

		public static function translateX(m : Matrix3D, distance : Number, local : Boolean = true) : void {
			m.copyColumnTo(3, _pos);
			m.copyColumnTo(0, _right);

			if (local) {
				_pos.x = (_pos.x + (distance * _right.x));
				_pos.y = (_pos.y + (distance * _right.y));
				_pos.z = (_pos.z + (distance * _right.z));
			} else {
				_pos.x = (_pos.x + distance);
			}
			m.copyColumnFrom(3, _pos);
		}

		public static function translateY(m : Matrix3D, distance : Number, local : Boolean = true) : void {
			m.copyColumnTo(3, _pos);
			m.copyColumnTo(1, _up);

			if (local) {
				_pos.x = (_pos.x + (distance * _up.x));
				_pos.y = (_pos.y + (distance * _up.y));
				_pos.z = (_pos.z + (distance * _up.z));
			} else {
				_pos.y = (_pos.y + distance);
			}
			m.copyColumnFrom(3, _pos);
		}

		public static function translateZ(m : Matrix3D, distance : Number, local : Boolean = true) : void {
			m.copyColumnTo(3, _pos);
			m.copyColumnTo(2, _dir);

			if (local) {
				_pos.x = (_pos.x + (distance * _dir.x));
				_pos.y = (_pos.y + (distance * _dir.y));
				_pos.z = (_pos.z + (distance * _dir.z));
			} else {
				_pos.z = (_pos.z + distance);
			}
			m.copyColumnFrom(3, _pos);
		}

		public static function translateAxis(m : Matrix3D, distance : Number, axis : Vector3D) : void {
			m.copyColumnTo(3, _pos);
			_pos.x = (_pos.x + (distance * axis.x));
			_pos.y = (_pos.y + (distance * axis.y));
			_pos.z = (_pos.z + (distance * axis.z));
			m.copyColumnFrom(3, _pos);
		}

		public static function setScale(m : Matrix3D, x : Number, y : Number, z : Number, smooth : Number = 1) : void {
			getScale(m, _scale);
			_x = _scale.x;
			_y = _scale.y;
			_z = _scale.z;
			_scale.x = (_scale.x + ((x - _scale.x) * smooth));
			_scale.y = (_scale.y + ((y - _scale.y) * smooth));
			_scale.z = (_scale.z + ((z - _scale.z) * smooth));
			_right.scaleBy((_scale.x / _x));
			_up.scaleBy((_scale.y / _y));
			_dir.scaleBy((_scale.z / _z));
			setVectors(m, _right, _up, _dir);
		}

		public static function scaleX(m : Matrix3D, scale : Number) : void {
			m.copyColumnTo(0, _right);
			_right.normalize();
			_right.x = (_right.x * scale);
			_right.y = (_right.y * scale);
			_right.z = (_right.z * scale);
			m.copyColumnFrom(0, _right);
		}

		public static function scaleY(m : Matrix3D, scale : Number) : void {
			m.copyColumnTo(1, _up);
			_up.normalize();
			_up.x = (_up.x * scale);
			_up.y = (_up.y * scale);
			_up.z = (_up.z * scale);
			m.copyColumnFrom(1, _up);
		}

		public static function scaleZ(m : Matrix3D, scale : Number) : void {
			m.copyColumnTo(2, _dir);
			_dir.normalize();
			_dir.x = (_dir.x * scale);
			_dir.y = (_dir.y * scale);
			_dir.z = (_dir.z * scale);
			m.copyColumnFrom(2, _dir);
		}

		public static function getRotation(m : Matrix3D, out : Vector3D = null) : Vector3D {
			out = ((out) || (new Vector3D()));
			_vector = m.decompose(Orientation3D.EULER_ANGLES)[1];
			out.x = _vector.x * _toAng;
			out.y = _vector.y * _toAng;
			out.z = _vector.z * _toAng;
			return out;
		}

		public static function setRotation(m : Matrix3D, x : Number, y : Number, z : Number) : void {
			var v : Vector.<Vector3D> = m.decompose(Orientation3D.EULER_ANGLES);
			v[1].x = (x * _toRad);
			v[1].y = (y * _toRad);
			v[1].z = (z * _toRad);
			m.recompose(v, Orientation3D.EULER_ANGLES);
		}

		public static function rotateX(m : Matrix3D, angle : Number, local : Boolean = true, pivotPoint : Vector3D = null) : void {
			rotateAxis(m, angle, (local) ? getRight(m, _vector) : Vector3D.X_AXIS, pivotPoint);
		}

		public static function rotateY(m : Matrix3D, angle : Number, local : Boolean = true, pivotPoint : Vector3D = null) : void {
			rotateAxis(m, angle, (local) ? getUp(m, _vector) : Vector3D.Y_AXIS, pivotPoint);
		}

		public static function rotateZ(m : Matrix3D, angle : Number, local : Boolean = true, pivotPoint : Vector3D = null) : void {
			rotateAxis(m, angle, (local) ? getDir(m, _vector) : Vector3D.Z_AXIS, pivotPoint);
		}

		public static function rotateAxis(m : Matrix3D, angle : Number, axis : Vector3D, pivotPoint : Vector3D = null) : void {
			_vector.x = axis.x;
			_vector.y = axis.y;
			_vector.z = axis.z;
			_vector.normalize();
			m.copyColumnTo(3, _pos);
			m.appendRotation(angle, _vector, ((pivotPoint) || (_pos)));
		}

		public static function transformVector(m : Matrix3D, vector : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			_vector.copyFrom(vector);

			m.copyRowTo(0, _right);
			m.copyRowTo(1, _up);
			m.copyRowTo(2, _dir);
			m.copyColumnTo(3, out);

			out.x = out.x + (_vector.x * _right.x) + (_vector.y * _right.y) + (_vector.z * _right.z);
			out.y = out.y + (_vector.x * _up.x) + (_vector.y * _up.y) + (_vector.z * _up.z);
			out.z = out.z + (_vector.x * _dir.x) + (_vector.y * _dir.y) + (_vector.z * _dir.z);

			return out;
		}

		public static function deltaTransformVector(m : Matrix3D, vector : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			_vector.copyFrom(vector);
			m.copyRowTo(0, _right);
			m.copyRowTo(1, _up);
			m.copyRowTo(2, _dir);
			out.x = (((_vector.x * _right.x) + (_vector.y * _right.y)) + (_vector.z * _right.z));
			out.y = (((_vector.x * _up.x) + (_vector.y * _up.y)) + (_vector.z * _up.z));
			out.z = (((_vector.x * _dir.x) + (_vector.y * _dir.y)) + (_vector.z * _dir.z));
			return out;
		}

		public static function invert(m : Matrix3D, out : Matrix3D = null) : Matrix3D {
			if (out == null) {
				out = new Matrix3D();
			}
			out.copyFrom(m);
			out.invert();
			return out;
		}

		public static function equal(a : Matrix3D, b : Matrix3D) : Boolean {
			var v0 : Vector.<Number> = a.rawData;
			var v1 : Vector.<Number> = b.rawData;
			var i : int;

			while (i < 16) {
				if (v0[i] != v1[i]) {
					return (false);
				}
				i++;
			}
			return true;
		}

		public static function interpolateTo(src : Matrix3D, dest : Matrix3D, percent : Number) : void {
			Matrix3DUtils.getScale(src, _scale);
			Matrix3DUtils.getScale(dest, _vector);
			_scale.x = (_scale.x + ((_vector.x - _scale.x) * percent));
			_scale.y = (_scale.y + ((_vector.y - _scale.y) * percent));
			_scale.z = (_scale.z + ((_vector.z - _scale.z) * percent));
			src.interpolateTo(dest, percent);
			src.prependScale(_scale.x, _scale.y, _scale.z);
		}

		public static function resetPosition(m : Matrix3D) : void {
			setPosition(m, 0, 0, 0);
		}

		public static function resetRotation(m : Matrix3D) : void {
			setRotation(m, 0, 0, 0);
		}

		public static function resetScale(m : Matrix3D) : void {
			setScale(m, 1, 1, 1);
		}

		public static function buildOrthoProjection(left : Number, right : Number, bottom : Number, top : Number, near : Number, far : Number, out : Matrix3D = null) : Matrix3D {

			var scaleX : Number = 0;
			var scaleY : Number = 0;
			var scaleZ : Number = 0;
			var offsX : Number = 0;
			var offsY : Number = 0;
			var offsZ : Number = 0;

			if (out == null) {
				out = new Matrix3D();
			}
			scaleX = 2 / (right - left);
			scaleY = 2 / (top - bottom);
			scaleZ = 1 / (far - near);
			offsX = (-0.5 * (right + left)) * scaleX;
			offsY = (-0.5 * (top + bottom)) * scaleY;
			offsZ = -near * scaleZ;
			_raw[0] = scaleX;
			_raw[5] = scaleY;
			_raw[10] = scaleZ;
			_raw[12] = offsX;
			_raw[13] = offsY;
			_raw[14] = offsZ;
			_raw[1] = _raw[2] = _raw[4] = _raw[6] = _raw[8] = _raw[9] = _raw[3] = _raw[7] = _raw[11] = 0;
			_raw[15] = 1;
			out.copyRawDataFrom(_raw);
			return out;
		}

	}
}
