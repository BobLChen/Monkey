package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.TextureMapFilter;
	import monkey.core.textures.Texture3D;

	/**
	 * 天空盒shader 
	 * @author Neil
	 * 
	 */	
	public class SkyboxShader3D extends Shader3D {
		
		private static var _instance : SkyboxShader3D;
		
		private var filter : TextureMapFilter;
		
		public function SkyboxShader3D() {
			super([]);
			this.filter = new TextureMapFilter(new Texture3D());
			this.filter.texture.mipMode = Texture3D.MIP_NONE;
			this.filter.texture.wrapMode= Texture3D.WRAP_CLAMP;
			this.addFilter(filter);
		}
		
		public function set texture(value : Texture3D) : void {
			this.filter.texture = value;
		}
		
		public static function get instance() : SkyboxShader3D {
			if (!_instance) {
				_instance = new SkyboxShader3D();
			}
			return _instance;
		}
		
	}
}
