package monkey.core.materials.shader {
	
	import monkey.core.shader.filters.TextureMapFilter;
	import monkey.core.textures.Texture3D;

	public class SkeDifMatShader extends SkeMatShader {
		
		private static var _instance : SkeDifMatShader;
		
		private var filter : TextureMapFilter;
		
		public function SkeDifMatShader() {
			super();
			this.filter = new TextureMapFilter(new Texture3D());
			this.addFilter(filter);
		}
		
		public static function get instance():SkeDifMatShader {
			if (!_instance) {
				_instance = new SkeDifMatShader();
			}
			return _instance;
		}

		public function set texture(value : Texture3D) : void {
			this.filter.texture = value;
		}
		
	}
}
