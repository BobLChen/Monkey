package monkey.core.collisions {
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.base.Triangle3D;
	import monkey.core.collisions.collider.Collider;
	import monkey.core.utils.Vector3DUtils;
		
	/**
	 * 射线碰撞检测
	 * 详细算法参考：http://www.cnblogs.com/graphics/archive/2009/10/17/1585281.html
	 * 算法描述   ：通过在起点引出一条射线，如果与三角形相交，通过平面相交算法可以获取交点以及起点距离平面距离。
	 * @author neil
	 */
	public class RayCollision {
		
		private static var RayDir 	: Vector3D = new Vector3D();		// 射线方向
		private static var RayFrom 	: Vector3D = new Vector3D();		// 射线起点
		private static var RayPoint : Vector3D = new Vector3D();		// point
						
		// 所有需要被检测的模型
		private var list : Vector.<Collider>;
				
		public function RayCollision() {
			this.list = new Vector.<Collider>();
		}
		
		/**
		 * 拾取 
		 * @param from			起点
		 * @param dir			方向
		 * @param distance		距离
		 * @param info			拾取信息
		 * @return 				是否成功拾取
		 * 
		 */		
		public function test(from : Vector3D, dir : Vector3D, distance : Number, info : CollisionInfo) : Boolean {
			
			var collided : Boolean = false;
			var collisionDistance : Number = 0;
			
			for each (var collider : Collider in this.list) {
				if (!collider.colliderMesh || !collider.object3D.visible || !collider.enable) {
					continue;
				}
				// 转换起点和方向到模型local空间
				collider.object3D.transform.globalToLocal(from, RayFrom);
				collider.object3D.transform.globalToLocalVector(dir, RayDir);
				RayDir.normalize();
				// 遍历所有的surface
				for each (var surf : Surface3D in collider.colliderMesh.surfaces) {
					var polys : Vector.<Triangle3D> = surf.ploys;
					var length : int = polys.length;
					var pn : int = 0;
					while (pn < length) {
						var tri  : Triangle3D = polys[pn++];
						var dist : Number = -(((tri.normal.x * RayFrom.x) + (tri.normal.y * RayFrom.y) + (tri.normal.z * RayFrom.z) + tri.plane)) / ((tri.normal.x * RayDir.x) + (tri.normal.y * RayDir.y) + (tri.normal.z * RayDir.z));
						if (dist <= 0) {
							continue;
						}
						// 交点,根据from,dir投影到面
						RayPoint.x = RayFrom.x + RayDir.x * dist;
						RayPoint.y = RayFrom.y + RayDir.y * dist;
						RayPoint.z = RayFrom.z + RayDir.z * dist;
						// 交点未在三角形内
						if (!tri.isPoint(RayPoint.x, RayPoint.y, RayPoint.z)) {
							continue;
						}
						// 将交点转换到全局空间
						collider.object3D.transform.localToGlobal(RayPoint, RayPoint);
						// 计算交点离起点的距离
						collisionDistance = Vector3DUtils.length(from, RayPoint);
						// 距离检测
						if (collisionDistance < distance) {
							collided = true;
							distance = collisionDistance;
							info.mesh = collider.colliderMesh;
							info.tri = tri;
							info.surface = surf;
							info.object = collider.object3D;
						}
					}
				}
				
			}
			return collided;
		}
		
		/**
		 * 添加一个检测对象 
		 * @param object
		 * @param includeChildren
		 * 
		 */		
		public function addCollisionWith(object : Object3D, includeChildren : Boolean = true) : void {
			var collider : Collider = object.getComponent(Collider) as Collider;
			if (collider) {
				if (this.list.indexOf(collider) == -1) {
					this.list.push(collider);
				}
			}
			object.addEventListener(Object3D.REMOVED, unloadEvent, false, 0, true);
			object.addEventListener(Object3D.ADDED,   reloadEvent, false, 0, true);
			if (includeChildren) {
				object.addEventListener(Object3D.ADD_CHILD,    reloadChildEvent, false, 0, true);
				object.addEventListener(Object3D.REMOVE_CHILD, unloadChildEvent, false, 0, true);
				for each (var child : Object3D in object.children) {
					this.addCollisionWith(child, true);
				}
			}
		}
		
		/**
		 * 移除检测对象 
		 * @param object
		 * @param includeChildren
		 * 
		 */		
		public function removeCollisionWith(object : Object3D, includeChildren : Boolean = true) : void {
			var collider : Collider = object.getComponent(Collider) as Collider;
			if (collider) {
				var idx : int = this.list.indexOf(collider);
				if (idx != -1) {
					this.list.splice(idx, 1);
				}
			}
			object.removeEventListener(Object3D.REMOVED, unloadEvent);
			object.removeEventListener(Object3D.ADDED,	 reloadEvent);
			object.removeEventListener(Object3D.ADD_CHILD, 	  reloadChildEvent);
			object.removeEventListener(Object3D.REMOVE_CHILD, unloadChildEvent);
			if (includeChildren) {
				for each (var child : Object3D in object.children) {
					this.removeCollisionWith(child, true);
				}
			}
		}
		
		private function unloadChildEvent(event:Event) : void {
			this.removeCollisionWith(event.target as Object3D, true);
		}
		
		private function reloadChildEvent(event:Event) : void {
			this.addCollisionWith(event.target as Object3D, true);
		}
		
		private function reloadEvent(event:Event) : void {
			this.addCollisionWith(event.target as Object3D, false);
		}
		
		private function unloadEvent(event:Event) : void {
			this.removeCollisionWith(event.target as Object3D, false);
		}
		
		public function dispose() : void {
			this.list.length = 0;
		}
		
	}
}
