package monkey.core.collisions.collider {

	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.interfaces.IComponent;

	public class BoxCollider extends Collider {
		
		private var _bounds : Bounds3D;
		
		public function BoxCollider(bounds : Bounds3D) {
			super(null);
			this.bounds = bounds;
		}
		
		override public function clone():IComponent {
			var c : BoxCollider = new BoxCollider(null);
			c._bounds = _bounds.clone();
			c.mesh	  = mesh.clone();
			return c;
		}
		
		public function get bounds():Bounds3D {
			return _bounds;
		}

		public function set bounds(value:Bounds3D):void {
			if (_bounds == value) {
				return;
			}
			_bounds = value;
			if (_bounds) {
				this.initBoxMesh(value);
			}
		}
		
		private function initBoxMesh(bounds : Bounds3D) : void {
			
			if (this.mesh) {
				this.mesh.dispose();
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
			this.mesh = new Mesh3D([surf]);
		}
		
	}
}
