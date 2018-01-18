package monkey.core.shader.filters {
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;

	/**
	 *　　　　　　　　┏┓　　　┏┓+ +
	 *　　　　　　　┏┛┻━━━┛┻┓ + +
	 *　　　　　　　┃　　　　　　　┃ 　
	 *　　　　　　　┃　　　━　　　┃ ++ + + +
	 *　　　　　　 ████━████ ┃+
	 *　　　　　　　┃　　　　　　　┃ +
	 *　　　　　　　┃　　　┻　　　┃
	 *　　　　　　　┃　　　　　　　┃ + +
	 *　　　　　　　┗━┓　　　┏━┛
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + + + +
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + 　　　　　　
	 *　　　　　　　　　┃　　　┃
	 *　　　　　　　　　┃　　　┃　　+　　　　　　　　　
	 *　　　　　　　　　┃　 　　┗━━━┓ + +
	 *　　　　　　　　　┃ 　　　　　　　┣┓
	 *　　　　　　　　　┃ 　　　　　　　┏┛
	 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
	 *　　　　　　　　　　┃┫┫　┃┫┫
	 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
	 * @author Neil
	 * @date   Jul 9, 2015
	 */
	public class AlphaThreadFilter extends Filter3D {
		
		private var bias : Vector.<Number>;
		
		/**
		 * 透明度 
		 * @param alpha
		 * 
		 */		
		public function AlphaThreadFilter(alpha : Number = 0.5) {
			super(name);
			this.bias = Vector.<Number>([alpha, 0, 0, 0]);
			this.priority = -1000;
		}
		
		public function get alpha() : Number {
			return this.bias[0];
		}
		
		public function set alpha(value : Number) : void {
			this.bias[0] = value;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(bias));
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var code : String = "";
			if (agal) {
				code += "sub "  + ft0 + ".x, " + regCache.oc + ".w, " + fc0 + ".x \n";
				code += "kill " + ft0 + ".x \n";
			}
			regCache.removeFt(ft0);
			return code;
		}
		
		
		
	}
}
