package monkey.core.shader.filters {

	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;

	/**
	 * 普通贴图 
	 * @author Neil
	 * 
	 */	
	public class TextureMapFilter extends Filter3D {

		private var label : FsRegisterLabel;
		private var data  : Vector.<Number>;
		
		/**
		 * 贴图 
		 * @param texture
		 * 
		 */		
		public function TextureMapFilter(texture : Texture3D) {
			super("TextureMapFilter");
			this.priority = 15;
			this.data  = Vector.<Number>([1, 1, 0, 0]);
			this.label = new FsRegisterLabel(texture);
		}
		
		public function get repeatX() : Number {
			return data[0];
		}
		
		public function set repeatX(value : Number) : void {
			data[0] = value;
		}
		
		public function get repeatY() : Number {
			return data[1];
		}
		
		public function set repeatY(value : Number) : void {
			data[1] = value;
		}
		
		public function get offsetX() : Number {
			return data[2];
		}
		
		public function set offsetX(value : Number) : void {
			data[2] = value;
		}
		
		public function get offsetY() : Number {
			return data[3];
		}
		
		public function set offsetY(value : Number) : void {
			data[3] = value;
		}
		
		public function get texture() : Texture3D {
			return this.label.texture;
		}
		
		public function set texture(value : Texture3D) : void {
			this.label.texture = value;
		}
		
		/**
		 * 片段程序 
		 * @param regCache		regCache
		 * @param agal			是否创建agal字符串，为优化做准备
		 * @return 
		 * 
		 */		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			var fs0 : ShaderRegisterElement = regCache.getFs(label);
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(data));
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var code : String = "";
			if (agal) {
				// 复制uv数据到ft0
				code += "mov " + ft0 + ", " + regCache.getV(Surface3D.UV0) + " \n";
				// uv * repeat
				code += "mul " + ft0 + ".xy, " + ft0 + ".xyxy, " + fc0 + ".xyxy \n";
				// uv * repeat + offset
				code += "add " + ft0 + ".xy, " + ft0 + ".xyxy, " + fc0 + ".zwzw \n";
				// sample
				code += "tex " + regCache.oc + ", " + ft0 + ".xy, " + fs0 + description(label.texture);
			}
			regCache.removeFt(ft0);
			return code;
		}
		
	}
}
