package monkey.core.textures {
	
	/**
	 * cube texture 
	 * @author Neil
	 * 
	 */	
	public class CubeTextue3D extends Texture3D {
		
		public function CubeTextue3D() {
			super();
			this.typeMode 		= TYPE_CUBE;
			this.magMode 		= MAG_LINEAR;
			this.wrapMode   	= WRAP_CLAMP;
			this.mipMode		= MIP_LINEAR;
		}
		
	}
}
