package monkey.core.shader.filters {
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;
	
	/**
	 * lightmap 
	 * @author Neil
	 * 
	 */	
	public class LightMapfilter extends Filter3D {
		
		public static const ADD : String = "ADD";
		public static const MUL : String = "MUL";
		public static const SUB : String = "SUB";
		
		private var _label  : FsRegisterLabel;
		private var _mode	: String = MUL;
		private var _bias   : Vector.<Number>;
		
		/**
		 *  
		 * @param texture	lightmap贴图
		 * @param mode		模式
		 * 
		 */		
		public function LightMapfilter(texture : Texture3D, mode : String = MUL) {
			super("LightMapfilter");
			this._mode = mode;
			this._bias  = Vector.<Number>([1, 0, 0, 0]);
			this._label = new FsRegisterLabel(texture);
		}
		
		public function get intensity() : Number {
			return this._bias[0];
		}
		
		public function get mode():String {
			return _mode;
		}
		
		public function get texture():Texture3D {
			return _label.texture;
		}
		
		public function set texture(value:Texture3D):void {
			_label.texture = value;
		}
		
		public function set intensity(value : Number) : void {
			this._bias[0] = value;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var fs0 : ShaderRegisterElement = regCache.getFs(_label);
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(this._bias));
			var code : String = "";
			if (agal) {
				code += "tex " + ft0 + ", " + regCache.getV(Surface3D.UV1) + fs0 + description(_label.texture) + " \n";
				code += "mul " + ft0 + ".xyz, " + ft0 + ".xyz, " + fc0 + ".x \n";
				if (mode == MUL) {
					code += "mul " + regCache.oc + ", " + regCache.oc + ", " + ft0 + " \n";
				} else if (mode == ADD) {
					code += "add " + regCache.oc + ", " + regCache.oc + ", " + ft0 + " \n";
				} else if (mode == SUB) {
					code += "sub " + regCache.oc + ", " + regCache.oc + ", " + ft0 + " \n";
				}
			}
			regCache.removeFt(ft0);
			return code;
		}
		
	}
}
