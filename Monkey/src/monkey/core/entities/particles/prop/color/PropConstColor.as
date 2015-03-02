package monkey.core.entities.particles.prop.color {
	
	import flash.geom.Vector3D;

	/**
	 * 常量颜色
	 * @author Neil
	 *
	 */
	public class PropConstColor extends PropColor {
		
		private var _color : uint;	// 颜色

		public function PropConstColor(color : uint = 0xFFFFFF, alpha : Number = 1) {
			super();
			this.color = color;
			this.alpha = alpha;
		}
		
		public function get alpha() : Number {
			return this._rgba.w;
		}
		
		public function set alpha(value : Number) : void {
			this._rgba.w = value;
		}
		
		public function get color() : uint {
			return _color;
		}

		public function set color(value : uint) : void {
			if (value == _color) {
				return;
			}
			this._color  = value;
			this._rgba.z = (color & 0xFF) / 0xFF;
			this._rgba.y = ((color >> 8) & 0xFF) / 0xFF;
			this._rgba.x = ((color >> 16) & 0xFF) / 0xFF;
		}
		
		override public function getRGBA(x : Number) : Vector3D {
			return _rgba;
		}
		
	}
}
