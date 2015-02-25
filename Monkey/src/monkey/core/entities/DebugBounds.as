package monkey.core.entities {
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Object3D;
	import monkey.core.renderer.MeshRenderer;

	public class DebugBounds extends Lines3D {
		
		private var aabb : Bounds3D;
		
		public function DebugBounds(obj : Object3D) {
			super();
			this.aabb = (obj.getComponent(MeshRenderer) as MeshRenderer).mesh.bounds;
			(this.getComponent(MeshRenderer) as MeshRenderer).material.depthWrite = false;
			this.init();
		}
		
		private function init() : void {
			if (!aabb) {
				return;
			}
			this.lineStyle(1, 0xFFCB00);
			this.moveTo(aabb.min.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.min.z);
			this.moveTo(aabb.max.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.min.z);
			this.moveTo(aabb.max.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.max.z);
			this.moveTo(aabb.min.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.max.z);
		}
		
	}
}
