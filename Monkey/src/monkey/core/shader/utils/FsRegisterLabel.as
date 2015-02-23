package monkey.core.shader.utils {
	
	import monkey.core.textures.Texture3D;

	public class FsRegisterLabel {
		
		public var fs 		: ShaderRegisterElement;
		public var texture 	: Texture3D;
		
		public function FsRegisterLabel(fs : ShaderRegisterElement, texture : Texture3D) {
			this.fs 		= fs;
			this.texture	= texture;
		}
	}
}
