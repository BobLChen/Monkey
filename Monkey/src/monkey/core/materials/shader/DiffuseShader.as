package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.TextureMapFilter;
	import monkey.core.textures.Texture3D;

	public class DiffuseShader extends Shader3D {
		
		private static var _instance : DiffuseShader;
		
		private var filter : TextureMapFilter;
		
		public function DiffuseShader() {
			super([]);
			this.filter = new TextureMapFilter(new Texture3D());
			this.addFilter(filter);
		}
		
		public function set texture(value : Texture3D) : void {
			this.filter.texture = value;
		}
		
		public static function get instance() : DiffuseShader {
			if (!_instance) {
				_instance = new DiffuseShader();
			}
			return _instance;
		}
		
	}
}
