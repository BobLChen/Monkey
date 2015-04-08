package monkey.core.shader.filters {
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;

	/**
	 * 提取亮色 
	 * @author Neil
	 * 
	 */	
	public class BloomExtractFilter extends Filter3D {
		
		private var bias 	: Vector.<Number>;
		private var offsets : Vector.<Number>;
		private var _fsLabel : FsRegisterLabel;
		
		/**
		 * 提取亮色filter 
		 * @param texture	带提取贴图
		 * @param offsetX	贴图宽度偏移量:例如1/width
		 * @param offsetY	贴图高度偏移量:例如1/height
		 * 
		 */		
		public function BloomExtractFilter(texture : Texture3D, offsetX : Number, offsetY : Number, intensity : Number = 0.75) {
			super("BloomExtractFilter");
			this._fsLabel = new FsRegisterLabel(texture);
			this.offsets  = Vector.<Number>([offsetX, offsetY, -offsetX, -offsetY]);
			this.bias	  = Vector.<Number>([0.2126,0.7152,0.0722, intensity]);
		}
		
		public function set intensity(value : Number) : void {
			this.bias[3] = value;
		}
		
		public function get texture():Texture3D {
			return _fsLabel.texture;
		}

		public function set texture(value:Texture3D):void {
			_fsLabel.texture = value;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(bias));
			var fc1 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(offsets));
			var fs0 : ShaderRegisterElement = regCache.getFs(_fsLabel);
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();
						
			var uv  : ShaderRegisterElement = regCache.getV(Surface3D.UV0);
			
			var code : String = "";
			
			if (agal) {
				code += "add " + ft0 + ".xy, " + uv + ".xy, " + fc1 + ".xy \n";
				code += "tex " + regCache.oc + ", " + ft0 + ".xy, " + fs0 + description(texture) + " \n";
				
				code += "add " + ft0 + ".xy, " + uv + ".xy, " + fc1 + ".xw \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(texture) + " \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				
				code += "add " + ft0 + ".xy, " + uv + ".xy, " + fc1 + ".zy \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(texture) + " \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				
				code += "add " + ft0 + ".xy, " + uv + ".xy, " + fc1 + ".zw \n";
				code += "tex " + ft1 + ", " + ft0 + ".xy, " + fs0 + description(texture) + " \n";
				code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft1 + " \n";
				
				code += "div " + regCache.oc + ", " + regCache.oc + ", " + regCache.fc0123 + ".z \n";
				code += "div " + regCache.oc + ", " + regCache.oc + ", " + regCache.fc0123 + ".z \n";
				
				code += "dp3 " + ft0 + ".z, " + regCache.oc + ".xyz, " + fc0 + ".xyz \n";
				code += "sub " + ft0 + ".z, " + ft0 + ".z, " + fc0 + ".w \n";
				code += "mul " + regCache.oc + ", " + regCache.oc + ", " + ft0 + ".z \n";
			}
			
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			
			return code;
		}
				
	}
}
