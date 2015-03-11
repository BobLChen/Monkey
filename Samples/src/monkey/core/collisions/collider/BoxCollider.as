package monkey.core.collisions.collider {

	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;

	public class BoxCollider extends Collider {
		
		public var bounds : Bounds3D;
		
		public function BoxCollider(bounds : Bounds3D) {
			super(null);
			this.bounds = bounds;
			this.initBoxMesh(bounds);
		}
		
		private function initBoxMesh(bounds : Bounds3D) : void {
			
			if (this.colliderMesh) {
				this.colliderMesh.dispose();
			}
			
			var min : Vector3D = bounds.min;
			var max : Vector3D = bounds.max;
			
			var vertex : Array = [
				min.x, min.y, min.z,
				min.x, max.y, min.z,
				max.x, max.y, min.z,
				
				max.x, min.y, min.z,
				min.x, min.y, min.z,
				max.x, max.y, min.z,
				
				max.x, min.y, max.z,
				max.x, max.y, max.z,
				min.x, max.y, max.z,
				
				min.x, min.y, max.z,
				max.x, min.y, max.z,
				min.x, max.y, max.z,
				
				max.x, min.y, min.z,
				max.x, max.y, min.z,
				max.x, max.y, max.z,
				
				max.x, min.y, max.z,
				max.x, min.y, min.z,
				max.x, max.y, max.z,
				
				min.x, min.y, max.z,
				min.x, max.y, max.z,
				min.x, max.y, min.z,
				
				min.x, min.y, min.z,
				min.x, min.y, max.z,
				min.x, max.y, min.z,
				
				min.x, max.y, min.z,
				min.x, max.y, max.z,
				max.x, max.y, max.z,
				
				max.x, max.y, min.z,
				min.x, max.y, min.z,
				max.x, max.y, max.z,
				
				max.x, min.y, min.z,
				max.x, min.y, max.z,
				min.x, min.y, max.z,
				
				min.x, min.y, min.z,
				max.x, min.y, min.z,
				min.x, min.y, max.z
			];
			var surf : Surface3D = new Surface3D();
			surf.indexVector = new Vector.<uint>();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>(vertex), 3);
			var len : int = int(vertex.length / 3);
			for (var i:int = 0; i < len; i++) {
				surf.indexVector.push(i);
			}
			this.colliderMesh = new Mesh3D([surf]);
		}
		
	}
}
