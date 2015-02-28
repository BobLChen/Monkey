package monkey.core.entities {

	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.utils.Vector3DUtils;

	/**
	 * mesh3D
	 * @author Neil
	 *
	 */
	public class Mesh3D {
		
		/** 网格数据 */
		public var surfaces   : Vector.<Surface3D>;
		
		private var _bounds   : Bounds3D;
		
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
			if (_bounds) {
				return _bounds;
			}
			this._bounds = new Bounds3D();
			this._bounds.min.setTo(10000000, 10000000, 10000000);
			this._bounds.max.setTo(-10000000, -10000000, -10000000);
			
			for each (var surf : Surface3D in surfaces) {
				Vector3DUtils.min(surf.bounds.min, this._bounds.min, this._bounds.min);
				Vector3DUtils.max(surf.bounds.max, this._bounds.max, this._bounds.max);
			}
			
			this._bounds.length.x = this._bounds.max.x - this._bounds.min.x;
			this._bounds.length.y = this._bounds.max.y - this._bounds.min.y;
			this._bounds.length.z = this._bounds.max.z - this._bounds.min.z;
			this._bounds.center.x = this._bounds.length.x * 0.5 + this._bounds.min.x;
			this._bounds.center.y = this._bounds.length.y * 0.5 + this._bounds.min.y;
			this._bounds.center.z = this._bounds.length.z * 0.5 + this._bounds.min.z;
			this._bounds.radius = Vector3D.distance(this._bounds.center, this._bounds.max);
			
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
		public function clone() : Mesh3D {
			var c : Mesh3D = new Mesh3D([]);
			for each (var surf : Surface3D in surfaces) {
				c.surfaces.push(surf.clone());
			}
			return c;
		}
		
		/**
		 *
		 *
		 */
		public function dispose() : void {
			for each (var surf : Surface3D in surfaces) {
				surf.dispose();
			}
			this.surfaces = new Vector.<Surface3D>();
		}
		
	}
}
