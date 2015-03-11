package monkey.core.shader.filters {

	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.utils.Color;
	
	/**
	 * 纯色 
	 * @author Neil
	 * 
	 */	
	public class ColorFilter extends Filter3D {

		private var data 	: Vector.<Number>;
		private var _color 	: Color;
		
		/**
		 * 
		 * @param r		红
		 * @param g		绿
		 * @param b		蓝
		 * @param a		alpha
		 *
		 */
		public function ColorFilter(color : Color) {
			super("ColorFilter");
			this.data = Vector.<Number>([1, 1, 1, 1]);
			this.priority = 100;
		}
		
		public function get color():Color {
			return _color;
		}

		public function set color(value:Color):void {
			_color = value;
			this.data[0] = value.r;
			this.data[1] = value.g;
			this.data[2] = value.b;
			this.data[3] = value.alpha;
		}
		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			var fc0  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(data));
			var code : String = "";
			if (agal) {
				code += "mov " + regCache.oc + ".xyzw, " + fc0 + ".xyzw \n";
			}
			return code;
		}
		
	}
}
