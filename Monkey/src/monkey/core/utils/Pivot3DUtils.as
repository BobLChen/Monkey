package monkey.core.utils {

	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;

	public class Pivot3DUtils {

		private static var _tmp : Vector3D = new Vector3D();
		
		public static function setPositionWithReference(pivot : Object3D, x : Number, y : Number, z : Number, reference : Pivot3D, smooth : Number = 1) : void {
			_tmp.x = x;
			_tmp.y = y;
			_tmp.z = z;
			_tmp = reference.localToGlobal(_tmp, _tmp);
			if (pivot.parent) {
				_tmp = pivot.parent.transform.globalToLocal(_tmp, _tmp);
			}
			pivot.transform.setPosition(_tmp.x, _tmp.y, _tmp.z, smooth);
		}
		
		public static function lookAtWithReference(pivot : Object3D, x : Number, y : Number, z : Number, reference : Pivot3D, up : Vector3D = null, smooth : Number = 1) : void {
			_tmp.x = x;
			_tmp.y = y;
			_tmp.z = z;
			_tmp = reference.localToGlobal(_tmp, _tmp);
			if (pivot.parent) {
				_tmp = pivot.parent.transform.globalToLocal(_tmp, _tmp);
			}
			pivot.transform.lookAt(_tmp.x, _tmp.y, _tmp.z, up, smooth);
		}
	}
}
