package monkey.core.shader.filters {
	
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.textures.Texture3D;
	
	public class Filter3D {
		
		public var name 	: String;
		/** 权重，决定filter的组织顺序，权重越大，越靠前组装 */
		public var priority : int = 0;
		
		public function Filter3D(name : String = "Filter3D") {
			this.name = name;
		}
		
		/**
		 * 获取片段程序代码
		 * @param regCache		寄存器管理器
		 * @param agal			是否拼接agal
		 * @return 				code
		 * 
		 */		
		public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			return '';
		}
		
		/**
		 * 获取顶点程序代码 
		 * @param regCache		寄存器管理器
		 * @param agal			是否拼接agal
		 * @return 				code
		 * 
		 */		
		public function getVertexCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			return '';
		}
		
		/**
		 * 纹理描述 
		 * @param texture
		 * @return 
		 * 
		 */		
		public function description(texture : Texture3D) : String {
			return ' <' + texture.typeMode + ', ' + texture.magMode + ', ' + texture.mipMode + ', ' + texture.wrapMode + '> \n';
		}
		
	}
}
