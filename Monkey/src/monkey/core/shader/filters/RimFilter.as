package monkey.core.shader.filters {
	
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.utils.Color;
	import monkey.core.utils.Device3D;

	/**
	 * 边缘光shader 
	 * @author Neil
	 * 
	 */	
	public class RimFilter extends Filter3D {
		
		private var _color : Color;
		private var _power : Number;
		private var _data  : Vector.<Number>;
		private var _dir   : Vector.<Number>;
		
		/**
		 * 边缘光filter 
		 * @param color	 光颜色
		 * @param power	 强度
		 * 
		 */		
		public function RimFilter(color : Color, power : Number = 5) {
			super(name);
			this._data = Vector.<Number>([0, 0, 0, 0]);
			this._dir  = Vector.<Number>([0, 0, 0, 0]);
			this.color = color;
			this.power = power;
		}
		
		override public function update():void {
			this._dir[0] = -Device3D.cameraDir.x;
			this._dir[1] = -Device3D.cameraDir.y;
			this._dir[2] = -Device3D.cameraDir.z;
		}
		
		public function get power():Number {
			return _power;
		}
		
		public function set power(value:Number):void {
			this._power = value;
			this._data[3] = _power;
		}
		
		public function get color():Color {
			return _color;
		}
		
		public function set color(value:Color):void {
			this._data[0] = value.r;
			this._data[1] = value.g;
			this._data[2] = value.b;
			this._color = value;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var fc0  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_dir));
			var fc1  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_data));
			var ft0  : ShaderRegisterElement = regCache.getFt();
			var code : String = '';
			if (agal) {
				code += 'dp3 ' + ft0 + '.w, ' + regCache.normalFt + '.xyz, ' + fc0 + '.xyz \n';
				code += 'sat ' + ft0 + '.w, ' + ft0 + '.w \n';
				code += 'sub ' + ft0 + '.w, ' + regCache.fc0123 + '.y, ' + ft0 + '.w \n';
				code += 'pow ' + ft0 + '.w, ' + ft0 + '.w, ' + fc1 + '.w \n';
				code += 'mul ' + ft0 + '.xyz, ' + fc1 + '.xyz, ' + ft0 + '.w \n';
				code += 'add ' + regCache.oc + '.xyz, ' + regCache.oc + '.xyz, ' + ft0 + '.xyz \n';
			}
			regCache.removeFt(ft0);
			return code;
		}
		
	}
}
