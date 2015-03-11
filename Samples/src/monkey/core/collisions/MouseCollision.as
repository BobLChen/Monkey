package monkey.core.collisions {
	
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Matrix3DUtils;
	
	/**
	 * 鼠标拾取器 
	 * @author Neil
	 * 
	 */	
	public class MouseCollision {
		
		private static const FROM : Vector3D = new Vector3D();
		private static const DIR  : Vector3D = new Vector3D();
		
		private var _cam : Camera3D;
		private var _ray : RayCollision;
		
		public function MouseCollision(camera : Camera3D = null) {
			this._ray = new RayCollision();
			this._cam = camera;
		}
		
		public function test(x : Number, y : Number, info : CollisionInfo) : Boolean {
			var camera   : Camera3D  = this._cam ? this._cam : Device3D.camera;
			var viewport : Rectangle = Device3D.scene.viewPort;
			if (!camera || !viewport) {
				return false;
			}
			camera.transform.getPosition(false, FROM);
			// 获取viewport上面的点击点
			x = x - viewport.x;
			y = y - viewport.y;
			// 将点击点转换到ndc空间
			DIR.x = ((x  / viewport.width)  - 0.5) * 2;
			DIR.y = ((-y / viewport.height) + 0.5) * 2;
			DIR.z = 1;
			// 逆向投影转换到投影之前的坐标
			Matrix3DUtils.transformVector(camera.lens.invProjection, DIR, DIR);
			DIR.x = DIR.x * DIR.z;
			DIR.y = DIR.y * DIR.z;
			// 转换到相机空间			
			Matrix3DUtils.deltaTransformVector(camera.transform.world, DIR, DIR);
			return this._ray.test(FROM, DIR, camera.far, info);
		}
				
		public function dispose() : void {
			this._ray.dispose();
			this._cam = null;
		}
		
		public function addCollisionWith(object : Object3D, includeChildren : Boolean = true) : void {
			this._ray.addCollisionWith(object, includeChildren);
		}
		
		public function removeCollisionWith(object : Object3D, includeChildren : Boolean = true) : void {
			this._ray.removeCollisionWith(object, includeChildren);
		}
		
		public function get ray() : RayCollision {
			return _ray;
		}
		
		public function get camera():Camera3D {
			return _cam;
		}
		
		public function set camera(value:Camera3D):void {
			_cam = value;
		}
		
	}
}
