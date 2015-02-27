package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.Line3DFilter;

	/**
	 * 单例模式
	 * 线框shader 
	 * @author Neil
	 * 
	 */	
	public class LineShader extends Shader3D {
		
		private static var _instance : LineShader;
		
		private var filter : Line3DFilter;
		
		public function LineShader() {
			super([]);
			if (_instance) {
				throw new Error("单例");
			}
			this.filter = new Line3DFilter();
			this.addFilter(filter);
		}
		
		public static function get instance() : LineShader {
			if (!_instance) {
				_instance = new LineShader();
			}
			return _instance;
		}
		
	}
}