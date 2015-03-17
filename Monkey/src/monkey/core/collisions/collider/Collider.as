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
		public var mesh : Mesh3D;
		
		/**
		 *  
		 * @param mesh	碰撞模型
		 * 
		 */		
		public function Collider(mesh : Mesh3D) {
			this.mesh = mesh;
		}
		
		override public function clone():IComponent {
			var c : Collider = new Collider(mesh.clone());
			return c;
		}
		
		override public function dispose(force : Boolean = false):void {
			if (this.disposed) {
				return;
			}
			super.dispose(force);
			if (this.mesh) {
				this.mesh.dispose(force);
				this.mesh = null;
			}
		}
		
	}
}
