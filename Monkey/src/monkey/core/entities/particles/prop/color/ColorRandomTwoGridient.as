package monkey.core.entities.particles.prop.color {
	
	import flash.geom.Vector3D;
	
	import monkey.core.utils.GradientColor;
	import monkey.core.utils.MathUtils;

	/**
	 * 在两个渐变色之间随机
	 * @author Neil
	 * 
	 */	
	public class ColorRandomTwoGridient extends PropColor {
		
		public var minColor : GradientColor;
		public var maxColor : GradientColor;
		
		public function ColorRandomTwoGridient() {
			super();
			this.minColor = new GradientColor();
			this.maxColor = new GradientColor();
		}
		
		override public function getRGBA(x : Number) : Vector3D {
			var min : Vector3D = minColor.getRGBA(x);
			var max : Vector3D = maxColor.getRGBA(x);
			this._rgba.x = MathUtils.lerp(min.x, max.x, Math.random());
			this._rgba.y = MathUtils.lerp(min.y, max.y, Math.random());
			this._rgba.z = MathUtils.lerp(min.z, max.z, Math.random());
			this._rgba.w = MathUtils.lerp(min.w, max.w, Math.random());
			return max;
		}
		
	}
}
