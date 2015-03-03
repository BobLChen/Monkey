package monkey.core.shader.filters {

	public class LightFilter extends Filter3D {
		
		protected var _ambient 		: uint;					// 环境光
		protected var _ambientData 	: Vector.<Number>;		// 
		protected var _lightColor 	: uint;					// 灯光颜色
		protected var _lightData 	: Vector.<Number>;
		
		public function LightFilter() {
			super("LightFilter");
			this.priority = 13;
			this._ambientData 	= Vector.<Number>([0.2, 0.2, 0.2, 1]);
			this._lightData 	= Vector.<Number>([1, 1, 1, 1]);
			this.ambient 		= 0xc8c8c8;
			this.lightColor 	= 0xffffff;
		}
		
		public function get lightColor() : uint {
			return _lightColor;
		}
		
		/**
		 * 灯光颜色 
		 * @param value
		 * 
		 */		
		public function set lightColor(value : uint) : void {
			this._lightColor = value;
			this._lightData[0] = (int(value >> 16) & 0xFF) / 0xFF;
			this._lightData[1] = (int(value >> 8) & 0xFF) / 0xFF;
			this._lightData[2] = (int(value >> 0) & 0xFF) / 0xFF;
		}
		
		public function get ambient() : uint {
			return _ambient;
		}
		
		/**
		 * 环境光
		 * @param value
		 *
		 */
		public function set ambient(value : uint) : void {
			this._ambient = value;
			this._ambientData[0] = (int(value >> 16) & 0xFF) / 0xFF;
			this._ambientData[1] = (int(value >> 8) & 0xFF) / 0xFF;
			this._ambientData[2] = (int(value >> 0) & 0xFF) / 0xFF;
			this._ambientData[3] = 1;
		}
		
	}
}
