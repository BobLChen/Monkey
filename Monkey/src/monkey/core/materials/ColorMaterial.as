package monkey.core.materials {

	import monkey.core.materials.shader.ColorShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Color;

	/**
	 * 纯色材质 
	 * @author Neil
	 * 
	 */	
	public class ColorMaterial extends Material3D {

		private var _color 	: Color;
				
		/**
		 *  
		 * @param color	颜色
		 * 
		 */		
		public function ColorMaterial(color : Color) {
			super();
			this._shader = ColorShader.instance; 
			this.color   = color;
		}
		
		public function get color() : Color {
			return _color;
		}
		
		public function set color(value : Color) : void {
			_color 	= value;
		}
		
		override public function clone() : Material3D {
			var c : ColorMaterial = new ColorMaterial(color);
			c.copyFrom(this);
			return c;
		}
		
		override public function updateMaterial(scene : Scene3D) : void {
			ColorShader(shader).color = _color;
		}
		
	}
}
