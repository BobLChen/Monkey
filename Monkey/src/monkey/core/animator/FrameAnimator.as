package monkey.core.animator {
	
	import flash.geom.Matrix3D;
	
	import monkey.core.interfaces.IComponent;
	
	public class FrameAnimator extends Animator {
		
		public var frames : Vector.<Matrix3D>;
		
		public function FrameAnimator() {
			super();
			this.frames = new Vector.<Matrix3D>();
		}
		
		override public function clone():IComponent {
			var c : FrameAnimator = new FrameAnimator();
			c.copyFrom(this);
			return c;
		}
		
		override public function copyFrom(animator:Animator):void {
			super.copyFrom(animator);
			if (animator is FrameAnimator) {
				this.frames = (animator as FrameAnimator).frames.concat();
			}
		}
		
	}
}
