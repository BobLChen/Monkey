package monkey.core.materials.shader {
	
	import monkey.core.textures.Texture3D;
	
	/**
	 * 条带shader 
	 * @author Neil
	 * 
	 */	
	public class TrailShader extends DiffuseShader {
		
		private static var _instance : TrailShader;
		
		public function TrailShader() {
			super();
			this.texture = new Texture3D(Texture3D.TYPE_2D, Texture3D.MAG_LINEAR, Texture3D.WRAP_CLAMP, Texture3D.MIP_LINEAR);
		}
		
		public static function get instance():TrailShader {
			if (_instance == null) {
				_instance = new TrailShader();
			}
			return _instance;
		}

	}
}
