package monkey.core.entities.particles.prop.color {
	
	import flash.geom.Vector3D;
	
	import monkey.core.utils.GridientColor;
		
	/**
	 * 渐变色 
	 * @author Neil
	 * 
	 */	
	public class PropGridientColor extends PropColor {
		
		public var color : GridientColor;
		
		public function PropGridientColor() {
			super();
			this.color = new GridientColor();
		}
		
		override public function getRGBA(x : Number) : Vector3D {
			return color.getRGBA(x);
		}
		
	}
}
