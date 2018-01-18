package monkey.core.utils {

	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;

	public class Object3DUtils {

		private static var _tmp : Vector3D = new Vector3D();
		
		public static function setPositionWithReference(pivot : Object3D, x : Number, y : Number, z : Number, reference : Object3D, smooth : Number = 1) : void {
			_tmp.x = x;
			_tmp.y = y;
			_tmp.z = z;
			_tmp = reference.transform.localToGlobal(_tmp, _tmp);
			if (pivot.parent) {
				_tmp = pivot.parent.transform.globalToLocal(_tmp, _tmp);
			}
			pivot.transform.setPosition(_tmp.x, _tmp.y, _tmp.z, smooth);
		}
		
		public static function lookAtWithReference(pivot : Object3D, x : Number, y : Number, z : Number, reference : Object3D, up : Vector3D = null, smooth : Number = 1) : void {
			_tmp.x = x;
			_tmp.y = y;
			_tmp.z = z;
			_tmp = reference.transform.localToGlobal(_tmp, _tmp);
			if (pivot.parent) {
				_tmp = pivot.parent.transform.globalToLocal(_tmp, _tmp);
			}
			pivot.transform.lookAt(_tmp.x, _tmp.y, _tmp.z, up, smooth);
		}
		
		/**
		 * 获取bounds在2d屏幕的区域 
		 * @param bounds		包围盒
		 * @param transform		空间
		 * @param out			输出
		 * @param camera		相机
		 * @param viewPort		viewport
		 * @return 
		 * 
		 */		
		public static function getScreenRect(bounds : Bounds3D, transform : Matrix3D, out : Rectangle = null, camera : Camera3D = null, viewPort : Rectangle = null) : Rectangle {
			if (!out) {
				out = new Rectangle();
			}
			if (!out) {
				out = new Rectangle();
			}
			if (!viewPort) {
				viewPort = Device3D.scene.viewPort;
			}
			if (!camera) {
				camera = Device3D.camera;
			}
			Matrix3DUtils.MATRIX3D.copyFrom(transform);
			Matrix3DUtils.MATRIX3D.append(camera.viewProjection);
			var inFront : Boolean = false;
			var vec 	: Vector3D = projectCorner(0, Matrix3DUtils.MATRIX3D, bounds);
			if (vec.w > 0) {
				inFront = true;
			}
			out.setTo(vec.x, vec.y, vec.x, vec.y);
			var i : int = 1;
			while (i < 8) {
				vec = projectCorner(i, Matrix3DUtils.MATRIX3D, bounds);
				if (vec.w > 0) {
					inFront = true;
				}
				if (vec.x < out.x) {
					out.x = vec.x;
				}
				if (vec.y > out.y) {
					out.y = vec.y;
				}
				if (vec.x > out.width) {
					out.width = vec.x;
				}
				if (vec.y < out.height) {
					out.height = vec.y;
				}
				i++;
			}
			if (inFront == false) {
				return null;
			}
			// 转换屏幕坐标
			out.y 	   = -out.y;
			out.width  =  out.width  - out.x;
			out.height = -out.height - out.y;
			
			var w2 : Number = viewPort.width  * 0.5;
			var h2 : Number = viewPort.height * 0.5;
			
			out.x = out.x * w2 + w2 + viewPort.x;
			out.y = out.y * h2 + h2 + viewPort.y;
			
			out.width  = out.width  * w2;
			out.height = out.height * h2;
			
			if (out.x < 0) {
				out.width = out.width + out.x;
				out.x = 0;
			}
			if (out.y < 0) {
				out.height = out.height + out.y;
				out.y = 0;
			}
			if (out.right > viewPort.width) {
				out.right = viewPort.width;
			}
			if (out.bottom > viewPort.height) {
				out.bottom = viewPort.height;
			}
			return out;
		}
		
		private static function projectCorner(i : int, m : Matrix3D, bounds : Bounds3D) : Vector3D {
			switch (i) {
				case 0:
					Vector3DUtils.vec1.setTo(bounds.min.x, bounds.min.y, bounds.min.z);
					break;
				case 1:
					Vector3DUtils.vec1.setTo(bounds.max.x, bounds.min.y, bounds.min.z);
					break;
				case 2:
					Vector3DUtils.vec1.setTo(bounds.min.x, bounds.max.y, bounds.min.z);
					break;
				case 3:
					Vector3DUtils.vec1.setTo(bounds.max.x, bounds.max.y, bounds.min.z);
					break;
				case 4:
					Vector3DUtils.vec1.setTo(bounds.min.x, bounds.min.y, bounds.max.z);
					break;
				case 5:
					Vector3DUtils.vec1.setTo(bounds.max.x, bounds.min.y, bounds.max.z);
					break;
				case 6:
					Vector3DUtils.vec1.setTo(bounds.min.x, bounds.max.y, bounds.max.z);
					break;
				case 7:
					Vector3DUtils.vec1.setTo(bounds.max.x, bounds.max.y, bounds.max.z);
					break;
			}
			return Utils3D.projectVector(m, Vector3DUtils.vec1);
		}
		
	}
}
