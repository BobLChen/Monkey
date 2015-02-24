package monkey.core.entities {

	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.components.Component3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;

	/**
	 * mesh3D
	 * @author Neil
	 *
	 */
	public class Mesh3D extends Component3D implements IComponent {

		/** 网格数据 */
		public var surfaces : Vector.<Surface3D>;

		private var _bounds : Bounds3D;
		
		public function Mesh3D(surfaces : Array) {
			super();
			this.surfaces = Vector.<Surface3D>(surfaces);
		}

		/**
		 * 卸载
		 * @param force
		 *
		 */
		public function download(force : Boolean = false) : void {
			for each (var surf : Surface3D in surfaces) {
				surf.download(force);
			}
		}

		/**
		 * bounds
		 * @return
		 *
		 */
		public function get bounds() : Bounds3D {
			return _bounds;
		}

		/**
		 * bounds
		 * @param value
		 *
		 */
		public function set bounds(value : Bounds3D) : void {
			_bounds = value;
		}

		/**
		 * 克隆mesh
		 * @return
		 *
		 */
		override public function clone() : IComponent {
			var c : Mesh3D = new Mesh3D([]);
			c.copyfrom(this);
			for each (var surf : Surface3D in surfaces) {
				c.surfaces.push(surf.clone());
			}
			return c;
		}
		
		/**
		 *
		 *
		 */
		override public function dispose() : void {
			super.dispose();
			for each (var surf : Surface3D in surfaces) {
				surf.dispose();
			}
			this.surfaces = new Vector.<Surface3D>();
		}
		
		public function draw(scene : Scene3D, material : Material3D) : void {
			for each (var surf : Surface3D in surfaces) {
				material.shader.draw(scene, surf, 0, surf.numTriangles);
			}
		}
	}
}
