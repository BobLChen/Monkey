package monkey.core.entities.primitives.particles.prop.color {
	
	import flash.geom.Vector3D;
	
	import monkey.core.utils.GridientColor;
	import monkey.core.utils.MathUtils;

	/**
	 * 在两个渐变色之间随机
	 * @author Neil
	 * 
	 */	
	public class PropRandomTwoGridient extends PropColor {
		
		public var minColor : GridientColor;
		public var maxColor : GridientColor;
		
		public function PropRandomTwoGridient() {
			super();
			this.minColor = new GridientColor();
			this.maxColor = new GridientColor();
		}
		
		override public function getRGBA(x : Number) : Vector3D {
			var min : Vector3D = minColor.getRGBA(x);
			var max : Vector3D = maxColor.getRGBA(x);
			this._rgba.x = MathUtils.clamp(min.x, max.x, Math.random());
			this._rgba.y = MathUtils.clamp(min.y, max.y, Math.random());
			this._rgba.z = MathUtils.clamp(min.z, max.z, Math.random());
			this._rgba.w = MathUtils.clamp(min.w, max.w, Math.random());
			return max;
		}
		
	}
}
