package monkey.core.renderer {

	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.components.Component3D;
	import monkey.core.components.Transform3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Matrix3DUtils;
	import monkey.core.utils.Vector3DUtils;
	
	/**
	 * 模型渲染器 
	 * @author Neil
	 * 
	 */	
	public class MeshRenderer extends Component3D {
		
		private var _mesh 			: Mesh3D;					// mesh
		private var _mat  			: Material3D;				// 材质
		private var _boundsCenter 	: Vector3D;					// 包围盒中心点
		private var _boundsRadius 	: Number = 1;				// 包围盒半径
		private var _boundsScaled 	: Boolean = true;			// 包围盒
				
		public function MeshRenderer(mesh : Mesh3D, material : Material3D) {
			super();
			this._mesh 			= mesh;
			this._mat  			= material;
			this._boundsCenter 	= new Vector3D();
			this._boundsRadius	= 1;
			this._boundsScaled	= true;
		}
		
		override public function onAdd(master : Object3D):void {
			if (object3D) {
				object3D.transform.removeEventListener(Transform3D.UPDATE_TRANSFORM_EVENT, onUpdateTransforms);
			}
			super.onAdd(master);
			if (object3D) {
				object3D.transform.addEventListener(Transform3D.UPDATE_TRANSFORM_EVENT, onUpdateTransforms);
			}
		}
		
		private function onUpdateTransforms(event:Event) : void {
			this._boundsScaled = true;
		}
		
		override public function clone():IComponent {
			var c : MeshRenderer = new MeshRenderer(mesh.clone(), material.clone());
			return c;
		}
		
		override public function dispose(force : Boolean = false):void {
			if (this.disposed) {
				return;
			}
			super.dispose(force);
			if (this.mesh) {
				this.mesh.dispose(force);
			}
			if (this.material) {
				this.material.dispose(force);
			}
			this.mesh = null;
			this.material = null;
		}
		
		public function get inView() : Boolean {
			if (!mesh) {
				return false;
			}
			var vec3 : Vector3D = Vector3DUtils.vec0;
			if (this._boundsScaled) {
				// 获取最新的中心点以及半径
				Matrix3DUtils.transformVector(object3D.transform.world, mesh.bounds.center, _boundsCenter);
				Matrix3DUtils.getScale(object3D.transform.world, vec3);
				this._boundsRadius = mesh.bounds.radius * Math.max(vec3.x, vec3.y, vec3.z);
				this._boundsScaled = false;
			}
			// 将中心点转换到view空间
			Matrix3DUtils.transformVector(Device3D.view, _boundsCenter, vec3);
			if (_boundsCenter.length >= this._boundsRadius) {
				// 检测是否在near-far之间
				if ((vec3.z - _boundsRadius) > Device3D.camera.far) {
					return false;
				}
				if ((vec3.z + _boundsRadius) < Device3D.camera.near) {
					return false;
				}
				// 透视投影
				var zom : Number = 1 / Device3D.camera.zoom / vec3.z; 
				var rat : Number = Device3D.camera.aspect;
				if ((vec3.x + _boundsRadius) * zom < -1) {
					return false;
				}
				if ((vec3.x - _boundsRadius) * zom > 1) {
					return false;
				}
				if ((vec3.y + _boundsRadius) * zom * rat < -1) {
					return false;
				}
				if ((vec3.y - _boundsRadius) * zom * rat > 1) {
					return false;
				}
			}
			return true;
		}
				
		override public function onDraw(scene:Scene3D):void {
			if (!material || !mesh) {
				return;
			}
			if (!inView) {
				return;
			}
			material.updateMaterial(scene);
			for (var i:int = 0; i < mesh.surfaces.length; i++) {
				material.draw(scene, mesh.surfaces[i]);
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
