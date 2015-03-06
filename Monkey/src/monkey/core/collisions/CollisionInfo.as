package monkey.core.collisions {
	
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.base.Triangle3D;
	import monkey.core.entities.Mesh3D;

	public class CollisionInfo {
		
		/** object */
		public var object   : Object3D;
		/** mesh */
		public var mesh 	: Mesh3D;
		/** geometry */
		public var surface  : Surface3D;
		/** tri */
		public var tri 		: Triangle3D;
		/** 全局点 */
		public var point 	: Vector3D;
				
		public function CollisionInfo() {
			this.point = new Vector3D();
		}
	}
}
