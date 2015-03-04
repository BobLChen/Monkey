package monkey.core.shader.filters {
	
	import monkey.core.utils.Color;
	
	/**
	 * 灯光filter 
	 * @author Neil
	 * 
	 */	
	public class LightFilter extends Filter3D {
		
		protected var _ambient 		: Color;				// 环境光
		protected var _ambientData 	: Vector.<Number>;		// 
		protected var _lightColor 	: Color;				// 灯光颜色
		protected var _lightData 	: Vector.<Number>;
		
		public function LightFilter() {
			super("LightFilter");
			this.priority = 13;
			this._ambientData 	= Vector.<Number>([0.2, 0.2, 0.2, 1]);
			this._lightData 	= Vector.<Number>([1, 1, 1, 1.2]);
			this.ambient 		= new Color(0xc8c8c8);
			this.lightColor 	= new Color(0xffffff);
		}
		
		public function get lightColor() : Color {
			return _lightColor;
		}
		
		/**
		 * 灯光颜色 
		 * @param value
		 * 
		 */		
		public function set lightColor(value : Color) : void {
			this._lightColor = value;
			this._lightData[0] = value.r;
			this._lightData[1] = value.g;
			this._lightData[2] = value.b;
		}
		
		/**
		 * 灯光强度 
		 * @param value
		 * 
		 */		
		public function set intensity(value : Number) : void {
			this._lightData[3] = value;	
		}
		
		public function get intensity() : Number {
			return this._lightData[3];
		}
		
		public function get ambient() : Color {
			return _ambient;
		}
		
		/**
		 * 环境光
		 * @param value
		 *
		 */
		public function set ambient(value : Color) : void {
			this._ambient = value;
			this._ambientData[0] = value.r;
			this._ambientData[1] = value.g;
			this._ambientData[2] = value.b;
		}
		
	}
}
