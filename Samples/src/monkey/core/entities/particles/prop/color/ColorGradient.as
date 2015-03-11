package monkey.core.entities.particles.prop.color {
	
	import flash.geom.Vector3D;
	
	import monkey.core.utils.GradientColor;
		
	/**
	 * 渐变色 
	 * @author Neil
	 * 
	 */	
	public class ColorGradient extends PropColor {
		
		public var color : GradientColor;
		
		public function ColorGradient() {
			super();
			this.color = new GradientColor();
			this.color.setColors([0xFFFFFF], [1]);
			this.color.setAlphas([1], [1]);
		}
		
		override public function getRGBA(x : Number) : Vector3D {
			return color.getRGBA(x);
		}
		
	}
}
