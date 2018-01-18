package monkey.core.materials.shader {
		
	import monkey.core.shader.filters.TextureMapFilter;
	import monkey.core.textures.Texture3D;

	public class SkeDifQuatShader extends SkeQuatShader {
		
		private static var _instance : SkeDifQuatShader;
		
		private var filter : TextureMapFilter;
		
		public function SkeDifQuatShader() {
			super();
			this.filter = new TextureMapFilter(new Texture3D());
			this.addFilter(filter);
		}
		
		public function set texture(value : Texture3D) : void {
			this.filter.texture = value;
		}
		
		public static function get instance():SkeDifQuatShader {
			if (!_instance) {
				_instance = new SkeDifQuatShader();
			}
			return _instance;
		}
		
	}
}
