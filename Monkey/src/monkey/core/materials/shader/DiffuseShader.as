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
		
		public function set texture(texture : Texture3D) : void {
			this.filter.texture = texture;
		}
		
		public function tillingOffset(repeatX:Number, repeatY:Number, offsetX:Number, offsetY:Number) : void {
			this.filter.offsetX = offsetX;
			this.filter.offsetY = offsetY;
			this.filter.repeatX = repeatX;
			this.filter.repeatY = repeatY;
		}
		
		public static function get instance() : DiffuseShader {
			if (!_instance) {
				_instance = new DiffuseShader();
			}
			return _instance;
		}
		
	}
}
