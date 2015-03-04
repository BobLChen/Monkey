package monkey.core.shader.filters {
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;

	/**
	 * bloom组合shader
	 * @author Neil
	 */	
	public class CombineFilter extends Filter3D {
		
		private var _bias	   : Vector.<Number>;
		private var _baseLabel : FsRegisterLabel;
		private var _blurLbael : FsRegisterLabel;
		
		/**
		 * 全屏泛光bloom
		 * @param originTexture		原始texture
		 * @param bloomTexture		叠加texture
		 * @param intensity			模糊强度
		 */
		public function CombineFilter(originTexture : Texture3D, bloomTexture : Texture3D, intensity : Number = 0.7) {
			super(name);
			this._bias		= Vector.<Number>([intensity, 0, 0, 0]);
			this._baseLabel	= new FsRegisterLabel(originTexture);
			this._blurLbael = new FsRegisterLabel(bloomTexture);
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			var fs0 : ShaderRegisterElement = regCache.getFs(_baseLabel);
			var fs1 : ShaderRegisterElement = regCache.getFs(_blurLbael);
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_bias));
					
			var code : String = "";
			
			if (agal) {
				code += "tex " + ft0 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs0 + description(_baseLabel.texture) + " \n";
				code += "tex " + ft1 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs1 + description(_blurLbael.texture) + " \n";
				code += "mul " + ft1 + ", " + ft1 + ", " + fc0 + ".x \n";
				code += "add " + ft0 + ", " + ft0 + ", " + ft1 + "\n";
				code += "mov " + regCache.oc + ", " + ft0 + " \n";
			}
						
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			
			return code;
		}
		
	}
}
