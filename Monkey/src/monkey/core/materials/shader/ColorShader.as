package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.ColorFilter;
	import monkey.core.utils.Color;
	
	/**
	 * 单例模式 
	 * 纯色shader
	 * @author Neil
	 * 
	 */	
	public class ColorShader extends Shader3D {
		
		private static var _instance : ColorShader;
		
		private var filter : ColorFilter;
		
		public function ColorShader() {
			super([]);
			if (_instance) {
				throw new Error("单例...");
			}
			this.filter = new ColorFilter(Color.WHITE);
			this.addFilter(filter);
		}
		
		public static function get instance() : ColorShader {
			if (!_instance) {
				_instance = new ColorShader();
			}
			return _instance;
		}
		
		public function set color(color : Color) : void {
			this.filter.color = color;
		}
		
	}
}
