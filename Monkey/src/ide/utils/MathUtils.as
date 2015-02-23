package ide.utils {

	import flash.geom.Vector3D;
	
	import ide.App;
	
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Matrix3DUtils;

	public class MathUtils {

		public static function pointPlane(dir : Vector3D, pos : Vector3D, pos1 : Vector3D) : Number {
			return dir.dotProduct(pos) - dir.dotProduct(pos1);
		}

		public static function mousePlane(x : Number, y : Number, pos : Vector3D, dir : Vector3D) : Vector3D {
			var posOut : Vector3D = new Vector3D();
			var dirOut : Vector3D = new Vector3D();
			var out : Vector3D = new Vector3D();
			App.core.scene.camera.transform.getPosition(false, posOut);
			App.core.scene.camera.getPointDir(x, y, dirOut);
			rayPlane(dir, pos, posOut, dirOut, out);
			return out;
		}
		
		public static function rayPlane(dir : Vector3D, pos1 : Vector3D, pos2 : Vector3D, axis : Vector3D, point : Vector3D = null) : Number {
			var dist : Number = (-dir.dotProduct(pos2) + dir.dotProduct(pos1)) / dir.dotProduct(axis);
			if (point) {
				point.x = pos2.x + axis.x * dist;
				point.y = pos2.y + axis.y * dist;
				point.z = pos2.z + axis.z * dist;
			}
			return dist;
		}

		public static function project2DPoint(point : Vector3D, out : Vector3D = null) : Vector3D {
			if (out == null) {
				out = new Vector3D();
			}
			out.w = 1;
			var scene : Scene3D = App.core.scene;
			if (scene.viewPort == null) {
				return out;
			}
			Matrix3DUtils.transformVector(scene.camera.view, point, out);
			var dist : Number = (scene.viewPort.width / Device3D.camera.zoom) / out.z;
			out.x = out.x * dist + scene.viewPort.width * 0.5 + scene.viewPort.x;
			out.y = -out.y * dist + scene.viewPort.height * 0.5 + scene.viewPort.y;
			out.z = 0;
			out.w = dist;
			return out;
		}
	}
}
