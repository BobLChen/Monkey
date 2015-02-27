package monkey.core.shader.filters {

	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	
	/**
	 * 纯色 
	 * @author Neil
	 * 
	 */	
	public class ColorFilter extends Filter3D {

		private var data : Vector.<Number>;
		
		/**
		 * 
		 * @param r		红
		 * @param g		绿
		 * @param b		蓝
		 * @param a		alpha
		 *
		 */
		public function ColorFilter(r : Number, g : Number, b : Number, a : Number = 1.0) {
			super("ColorFilter");
			this.priority = 100;
			this.data = Vector.<Number>([r, g, b, a]);
		}
		
		public function setColor(r : Number, g : Number, b : Number) : void {
			data[0] = r;
			data[1] = g;
			data[2] = b;
		}
		
		public function get red() : Number {
			return data[0];
		}
		
		public function set red(value : Number) : void {
			data[0] = value;
		}
		
		public function get green() : Number {
			return data[1];
		}
		
		public function set green(value : Number) : void {
			data[1] = value;
		}
		
		public function get blue() : Number {
			return data[2];
		}
		
		public function set blue(value : Number) : void {
			data[2] = value;
		}
		
		public function get alpha() : Number {
			return data[3];
		}
		
		public function set alpha(value : Number) : void {
			data[3] = value;
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
