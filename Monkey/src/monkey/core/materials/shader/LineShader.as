package monkey.core.materials.shader {

	import monkey.core.base.Surface3D;
	import monkey.core.scene.Scene3D;
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
				
		override public function draw(scene3d:Scene3D, surface:Surface3D, firstIdx:int=0, count:int=-1):void {
			this.filter.update();
			super.draw(scene3d, surface, firstIdx, count);
		}
		
		public static function get instance() : LineShader {
			if (!_instance) {
				_instance = new LineShader();
			}
			return _instance;
		}
		
	}
}