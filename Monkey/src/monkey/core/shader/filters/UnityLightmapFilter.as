package monkey.core.shader.filters {

	import flash.geom.Vector3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;

	public class UnityLightmapFilter extends Filter3D {

		private var _bias  : Vector.<Number>;
		private var _data  : Vector.<Number>;
		private var _label : FsRegisterLabel;

		public function UnityLightmapFilter() {
			super("UnityLightmapFilter");
			this.priority = 14;
			this._data  = Vector.<Number>([1, 1, 0, 0]);
			this._bias  = Vector.<Number>([2, 0, 0, 0]);
			this._label = new FsRegisterLabel(null);
		}
		
		public function set texture(value : Texture3D) : void {
			this._label.texture = value;
		}

		public function set tilingOffset(value : Vector3D) : void {
			this._data[0] = value.x;
			this._data[1] = value.y;
			this._data[2] = value.z;
			this._data[3] = value.w;
		}
		
		public function set intensity(value : Number) : void {
			this._bias[0] = value;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(this._data));
			var fc1 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(this._bias));
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var fs0 : ShaderRegisterElement = regCache.getFs(this._label);
			var code : String = "";
			if (agal) {
				// scale
				code += "mul " + ft0 + ".xy, " + regCache.getV(Surface3D.UV1) + ".xy, " + fc0 + ".xy\n";
				// offset
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + fc0 + ".zw \n";
				// opengl vs dx=> 1-uv.y
				code += "sub " + ft0 + ".y, " + regCache.fc0123 + ".y, " + ft0 + ".y \n";
				code += "tex " + ft0 + ", " + ft0 + ".xy, " + fs0 + description(this._label.texture);
				code += "mul " + ft0 + ", " + ft0 + ", " + fc1 + ".x \n";
				code += "mul " + regCache.oc + ", " + ft0 + ", " + regCache.oc + " \n";
			}
			regCache.removeFt(ft0);
			return code;
		}

	}
}
