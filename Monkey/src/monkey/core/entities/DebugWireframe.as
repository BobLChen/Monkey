package monkey.core.entities {
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;

	/**
	 * 线框 
	 * @author Neil
	 * 
	 */	
	public class DebugWireframe extends Lines3D {
		
		private var _mesh 	: Mesh3D;
		private var _color 	: uint;
		private var _alpha 	: Number;
		
		public function DebugWireframe(obj : Object3D, color : uint = 0xFFFFFF, alpha : Number = 1) {
			super();
			this._alpha = alpha;
			this._mesh 	= obj.getComponent(Mesh3D) as Mesh3D;
			this._color = color;
			this.config();
		}
		
		public function config() : void {
			if (!_mesh) {
				return;
			}
			this._mesh.download(true);
			this.clear();
			this.lineStyle(1, _color, _alpha);
			
			for each (var surf : Surface3D in this._mesh.surfaces) {
				var vertices : Vector.<Number> = surf.getVertexVector(Surface3D.POSITION);
				var indices  : Vector.<uint> = surf.indexVector;
				var len	: int = indices.length;
				var i : int = 0;
				while (i < len) {
					var px : int = indices[i++] * 3;
					var py : int = indices[i++] * 3;
					var pz : int = indices[i++] * 3;
					moveTo(vertices[px], vertices[px + 1], vertices[px + 2]);
					lineTo(vertices[py], vertices[py + 1], vertices[py + 2]);
					lineTo(vertices[pz], vertices[pz + 1], vertices[pz + 2]);
					lineTo(vertices[px], vertices[px + 1], vertices[px + 2]);
				}
			}
		}
		
		public function get color() : uint {
			return this._color;
		}
		
		public function get mesh() : Mesh3D {
			return this._mesh;
		}
		
	}
}
