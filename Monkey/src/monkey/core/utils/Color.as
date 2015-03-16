package monkey.core.utils {
	
	import flash.geom.Vector3D;

	public class Color {
		
		private var _color : uint;
		private var _rgba  : Vector3D;
				
		public function Color(color : uint = 0xFFFFFF, alpha : Number = 1) {
			this._rgba = new Vector3D();
			this.color = color;
			this.alpha = alpha;
		}
					
		public function get color():uint {
			return this._color;
		}

		public function set color(value:uint):void {
			this._color = value;
			this._rgba.x = (int(value >> 16) & 0xFF) / 0xFF;
			this._rgba.y = (int(value >> 8) & 0xFF) / 0xFF;
			this._rgba.z = (int(value >> 0) & 0xFF) / 0xFF;
		}
		
		public function get r() : Number {
			return this._rgba.x;
		}
				
		public function get g() : Number {
			return this._rgba.y;
		}
		
		public function get b() : Number {
			return this._rgba.z;
		}
		
		public function set alpha(value : Number) : void {
			this._rgba.w = value;	
		}
		
		public function get alpha() : Number {
			return this._rgba.w;
		}
		
		public static function get WHITE() : Color {
			return new Color(0xFFFFFF);
		}
		
		public static function get GRAY() : Color {
			return new Color(0x777777);
		}

	}
}
