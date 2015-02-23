package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.ColorFilter;
	
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
			this.filter = new ColorFilter(1.0, 1.0, 1.0, 1.0);
			this.addFilter(filter);
		}
		
		public static function get instance() : ColorShader {
			if (!_instance) {
				_instance = new ColorShader();
			}
			return _instance;
		}
		
		public function setColor(r : Number, g : Number, b : Number) : void {
			this.filter.setColor(r, g, b);
		}
		
		public function set red(value : Number) : void {
			this.filter.red = value;
		}
		
		public function set green(value : Number) : void {
			this.filter.green = value;
		}
		
		public function set blue(value : Number) : void {
			this.filter.blue = value;
		}
		
	}
}
