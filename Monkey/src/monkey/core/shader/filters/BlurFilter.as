package monkey.core.shader.filters {
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;
	
	/**
	 * 高斯模糊 
	 * @author Neil
	 * 
	 */	
	public class BlurFilter extends Filter3D {
		
		private var offsets : Vector.<Number>;
		private var _texLabel : FsRegisterLabel;
		
		public function BlurFilter(texture : Texture3D, offsetX : Number, offsetY : Number) {
			super("BlurFilter");
			this.offsets = Vector.<Number>([offsetX, offsetY, 21, 5.0]);
			this._texLabel = new FsRegisterLabel(texture);
			texture.wrapMode = Texture3D.WRAP_REPEAT;
		}
		
		public function set texture(texture : Texture3D) : void {
			texture.wrapMode = Texture3D.WRAP_REPEAT;
			this._texLabel.texture = texture;
		}
		
		public function get texture() : Texture3D {
			return _texLabel.texture;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(offsets));
			var fs0 : ShaderRegisterElement = regCache.getFs(_texLabel);
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();
						
			var code : String = "";
			
			if (agal) {
				code += "mov " + regCache.oc + ", " + regCache.fc0123 + ".xxxx \n";
				
				code += "mov " + ft0 + ".xy, " + regCache.getV(Surface3D.UV0) + ".xy \n";	// xy = uv
				code += "mov " + ft1 + ".xy, " + fc0 + ".xy \n";
				code += "mul " + ft1 + ".xy, " + ft1 + ".xy, " + fc0 + ".ww \n";			
				// uv = uv - offset x 5			-5
				code += "sub " + ft0 + ".xy, " + ft0 + ".xy, " + ft1 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 1								-4
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 2								-3
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + regCache.fc0123 + ".z \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 2								-2
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + regCache.fc0123 + ".z \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 3								-1
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + regCache.fc0123 + ".w \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 3								0
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + regCache.fc0123 + ".w \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 3								1
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + regCache.fc0123 + ".w \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 2								2
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + regCache.fc0123 + ".z \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 2								3
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + regCache.fc0123 + ".z \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 1								4
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				// 1								5
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".xy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(_texLabel.texture) + " \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				
				code += "div " + regCache.oc + ", " + regCache.oc + ", " + fc0 + ".z \n";
			}
			
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			
			return code;
		}
		
		
	}
}
