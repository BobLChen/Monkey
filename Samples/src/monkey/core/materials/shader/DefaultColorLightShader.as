package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.ColorFilter;
		
	/**
	 * 默认的太阳光纯色shader 
	 * @author Neil
	 * 
	 */	
	public class DefaultColorLightShader extends Shader3D {
		
		private static var _instance : ColorShader;
		
		private var filter : ColorFilter;
				
		public function DefaultColorLightShader() {
			super(filters);
		}
	}
}
