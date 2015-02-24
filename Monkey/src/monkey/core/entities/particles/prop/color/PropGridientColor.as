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
			this.color.setColors([720640,11404711,15871,62975,16711680], [0,53.55,127.5,204,255]);
			this.color.setAlphas([1.0,1.0,1.0], [0,122.39999999999999,255]);
		}
		
		override public function getRGBA(x : Number) : Vector3D {
			return color.getRGBA(x);
		}
		
	}
}
