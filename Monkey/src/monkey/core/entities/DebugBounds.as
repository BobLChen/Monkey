package monkey.core.entities {
	import monkey.core.base.Bounds3D;
		
	public class DebugBounds extends Lines3D {
		
		public function DebugBounds() {
			super();
			this.init();
		}
				
		private function init() : void {
			
			var aabb : Bounds3D = new Bounds3D();
			aabb.min.setTo(-0.5, -0.5, -0.5);
			aabb.max.setTo(0.5, 0.5, 0.5);
			
			this.lineStyle(1, 0xFFCB00);
			this.moveTo(aabb.min.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.min.z);
			this.moveTo(aabb.max.x, aabb.min.y, aabb.min.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.min.z);
			this.moveTo(aabb.max.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.max.x, aabb.max.y, aabb.max.z);
			this.moveTo(aabb.min.x, aabb.min.y, aabb.max.z);
			this.lineTo(aabb.min.x, aabb.max.y, aabb.max.z);
		}
		
	}
}
