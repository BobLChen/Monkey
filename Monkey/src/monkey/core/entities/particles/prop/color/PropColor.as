package monkey.core.entities.particles.prop.color {
	
	import flash.geom.Vector3D;

	/**
	 * 颜色属性 
	 * @author Neil
	 * 
	 */	
	public class PropColor {
		
		protected var _rgba : Vector3D;
		
		public function PropColor() {
			super();
			this._rgba = new Vector3D();
		}
		
		/**
		 * 根据延时获取rgba色 
		 * @param x
		 * @return 
		 * 
		 */		
		public function getRGBA(x : Number) : Vector3D {
			return _rgba;
		}
		
	}
}
