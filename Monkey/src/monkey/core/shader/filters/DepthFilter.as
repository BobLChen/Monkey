package monkey.core.shader.filters {
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	
	/**
	 * 深度filter 
	 * @author Neil
	 * 
	 */	
	public class DepthFilter extends Filter3D {
		
		private var _toRgbData0 	: Vector.<Number>;
		private var _toRgbData1 	: Vector.<Number>;
		private var posVary 		: ShaderRegisterElement;
		
		public function DepthFilter() {
			super("DepthFilter");
			this.priority 	 = -10000;
			this._toRgbData0 = Vector.<Number>([1.0, 255.0, 65025.0, 16581375.0]);
			this._toRgbData1 = Vector.<Number>([1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0, 0.0]);
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			this.posVary = regCache.getFreeV();
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_toRgbData0));
			var fc1 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_toRgbData1));
			var code : String = '';
			if (agal) {
				code += 'div ' + ft0 + ', ' + posVary + ', ' + posVary + '.w \n';
				code += 'mul ' + ft0 + ', ' + fc0 + ', ' + ft0 + '.z \n';
				code += 'frc ' + ft0 + ', ' + ft0 + ' \n';
				code += 'mul ' + ft1 + ', ' + ft0 + '.yzww, ' + fc1 + ' \n';
				code += 'sub ' + regCache.oc + ', ' + ft0 + ', ' + ft1 + ' \n';
			}
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			return code;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var code : String = "";
			if (agal) {
				code += "m44 " + posVary + ", " + regCache.getVa(Surface3D.POSITION) + ", " + regCache.vcMvp + " \n";
			}
			return "";
		}
		
		
		
	}
}
