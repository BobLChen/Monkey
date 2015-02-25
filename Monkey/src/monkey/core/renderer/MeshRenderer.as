package monkey.core.renderer {

	import monkey.core.components.Component3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	
	/**
	 * 模型渲染器 
	 * @author Neil
	 * 
	 */	
	public class MeshRenderer extends Component3D {
		
		private var _mesh : Mesh3D;
		private var _mat  : Material3D;
		
		public function MeshRenderer(mesh : Mesh3D, material : Material3D) {
			super();
			this._mesh = mesh;
			this._mat  = material;
		}
		
		override public function clone():IComponent {
			var c : MeshRenderer = new MeshRenderer(mesh.clone(), material.clone());
			c.copyfrom(this);
			return c;
		}
		
		override public function dispose():void {
			if (disposed) {
				return;
			}
			super.dispose();
			if (mesh) {
				mesh.dispose();
			}
			if (material) {
				material.dispose();
			}
			mesh = null;
			material = null;
		}
		
		override public function onDraw(scene:Scene3D):void {
			if (material && mesh) {
				Device3D.world.copyFrom(object3D.transform.world);
				Device3D.mvp.copyFrom(object3D.transform.world);
				Device3D.mvp.append(scene.camera.viewProjection);
				Device3D.drawOBJNum++;
				material.draw(scene, mesh);
			}
		}
		
		public function get material():Material3D {
			return _mat;
		}

		public function set material(value:Material3D):void {
			_mat = value;
		}

		public function get mesh():Mesh3D {
			return _mesh;
		}

		public function set mesh(value:Mesh3D):void {
			_mesh = value;
		}

	}
}
