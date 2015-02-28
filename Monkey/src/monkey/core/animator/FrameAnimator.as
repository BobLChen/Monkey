package monkey.core.animator {
	
	import flash.geom.Matrix3D;
	
	public class FrameAnimator extends Animator {
		
		public var frames : Vector.<Matrix3D>;
		
		public function FrameAnimator() {
			super();
			this.frames = new Vector.<Matrix3D>();
		}
	}
}
