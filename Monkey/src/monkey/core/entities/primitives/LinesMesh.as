package monkey.core.entities.primitives {

	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;

	public class LinesMesh extends Mesh3D {
		
		private var _thickness 	: Number = 1;
		private var _color 		: uint   = 0xFFFFFF;
		private var _alpha 		: Number = 1;
		private var _lx 		: Number = 0;
		private var _ly 		: Number = 0;
		private var _lz 		: Number = 0;
		private var _r 			: Number = 1;
		private var _g 			: Number = 1;
		private var _b 			: Number = 1;
		private var _lineDirty 	: Boolean = false;
		private var _surface 	: Surface3D;
		
		public function LinesMesh() {
			super([]);
		}
		
		public function clear() : void {
			for each (var geo : Surface3D in surfaces) {
				geo.dispose(true);
			}
			this._lx = 0;
			this._ly = 0;
			this._lz = 0;
			this.surfaces  = new Vector.<Surface3D>();
			this._surface = null;
		}
		
		public function lineStyle(thickness : Number = 1, color : uint = 0xFFFFFF, alpha : Number = 1) : void {
			this._alpha = alpha;
			this._color = color;
			this._thickness = thickness;
			this._r = (((color >> 16) & 0xFF) / 0xFF);
			this._g = (((color >> 8) & 0xFF) / 0xFF);
			this._b = ((color & 0xFF) / 0xFF);
		}
		
		public function moveTo(x : Number, y : Number, z : Number) : void {
			this._lx = x;
			this._ly = y;
			this._lz = z;
		}
		
		public function lineTo(x : Number, y : Number, z : Number) : void {
			this._lineDirty = true;
			var index : uint = 0;
			if (_surface) {
				index = _surface.getVertexVector(Surface3D.POSITION).length / 3;
			} else {
				index = 0;
			}
			if (this._surface == null || index >= (65536 - 6)) {
				this._surface = new Surface3D();
				this._surface.setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
				this._surface.setVertexVector(Surface3D.CUSTOM1,  new Vector.<Number>(), 3);
				this._surface.setVertexVector(Surface3D.CUSTOM2,  new Vector.<Number>(), 2);
				this._surface.setVertexVector(Surface3D.CUSTOM3,  new Vector.<Number>(), 4);
				this._surface.indexVector = new Vector.<uint>();
				this.surfaces.push(this._surface);
				index = 0;
			}
			this._surface.getVertexVector(Surface3D.POSITION).push(
				_lx, _ly, _lz, x, y, z, _lx, _ly, _lz, x, y, z
			);
			this._surface.getVertexVector(Surface3D.CUSTOM1).push(
				x, y, z, _lx, _ly, _lz, x, y, z, _lx, _ly, _lz
			);
			this._surface.getVertexVector(Surface3D.CUSTOM2).push(
				_thickness, _thickness / 1877, -_thickness, _thickness / 1877, -_thickness, _thickness / 1877, _thickness, _thickness / 1877
			);
			this._surface.getVertexVector(Surface3D.CUSTOM3).push(
				_r, _g, _b, _alpha, _r, _g, _b, _alpha, _r, _g, _b, _alpha, _r, _g, _b, _alpha
			);
			this._surface.indexVector.push(index + 2, index + 1, index, index + 1, index + 2, index + 3);
			this._lx = x;
			this._ly = y;
			this._lz = z;
			this.download(true);
		}
		
	}
}
