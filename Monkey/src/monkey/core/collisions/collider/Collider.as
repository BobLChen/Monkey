package monkey.core.collisions.collider {

	import monkey.core.components.Component3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.interfaces.IComponent;
	
	/**
	 * collider 
	 * @author Neil
	 * 
	 */	
	public class Collider extends Component3D {
		
		/** 碰撞体mesh */
		public var colliderMesh : Mesh3D;
		
		/**
		 *  
		 * @param mesh	碰撞模型
		 * 
		 */		
		public function Collider(mesh : Mesh3D) {
			this.colliderMesh = mesh;
		}
		
		override public function clone():IComponent {
			var c : Collider = new Collider(colliderMesh);
			return c;
		}
		
		override public function dispose():void {
			if (disposed) {
				return;
			}
			super.dispose();
			if (colliderMesh) {
				colliderMesh.dispose();
			}
		}
		
	}
}
