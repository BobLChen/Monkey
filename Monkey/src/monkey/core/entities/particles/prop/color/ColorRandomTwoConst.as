package monkey.core.entities.particles.prop.color {
	
	import flash.geom.Vector3D;
	
	import monkey.core.utils.MathUtils;
	
	/**
	 * 两个常量颜色之间随机
	 * @author Neil
	 *
	 */
	public class ColorRandomTwoConst extends PropColor {

		private var _minColor : uint;
		private var _maxColor : uint;

		private var _minRGB : Vector3D = new Vector3D();
		private var _maxRGB : Vector3D = new Vector3D();

		public function ColorRandomTwoConst(minColor : uint = 0xFFFFFF, minAlpha : Number = 1, maxColor : uint = 0xFFFFFF, maxAlpha : Number = 1) {
			super();
			this.maxColor = minColor;
			this.minColor = maxColor;
			this.maxAlpha = maxAlpha;
			this.minAlpha = minAlpha;
		}
		
		public function get maxAlpha() : Number {
			return _maxRGB.w;
		}
		
		public function set maxAlpha(value : Number) : void {
			this._maxRGB.w = value;
		}
		
		public function get minAlpha() : Number {
			return _minRGB.w;
		}
		
		public function set minAlpha(value : Number) : void {
			this._minRGB.w = value;
		}
		
		public function get maxColor() : uint {
			return _maxColor;
		}

		public function set maxColor(color : uint) : void {
			if (color == _maxColor) {
				return;
			}
			this._maxColor = color;
			this._maxRGB.z = (color & 0xFF) / 0xFF;
			this._maxRGB.y = ((color >> 8)  & 0xFF) / 0xFF;
			this._maxRGB.x = ((color >> 16) & 0xFF) / 0xFF;
		}
		
		public function get minColor() : uint {
			return _minColor;
		}
		
		public function set minColor(color : uint) : void {
			if (color == _minColor) {
				return;
			}
			this._minColor = color;
			this._minRGB.z = (color & 0xFF) / 0xFF;
			this._minRGB.y = ((color >> 8)  & 0xFF) / 0xFF;
			this._minRGB.x = ((color >> 16) & 0xFF) / 0xFF;
		}
				
		override public function getRGBA(x : Number) : Vector3D {
			this._rgba.x = MathUtils.clamp(_minRGB.x, _maxRGB.x, Math.random());
			this._rgba.y = MathUtils.clamp(_minRGB.y, _maxRGB.y, Math.random());
			this._rgba.z = MathUtils.clamp(_minRGB.z, _maxRGB.z, Math.random());
			this._rgba.w = MathUtils.clamp(_minRGB.w, _maxRGB.w, Math.random());
			return _rgba;
		}
		
	}
}
