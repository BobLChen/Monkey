package monkey.core.animator {
	
	import flash.geom.Matrix3D;
	
	import monkey.core.interfaces.IComponent;
	
	public class FrameAnimator extends Animator {
		
		private var _frames : Vector.<Matrix3D>;
		
		public function FrameAnimator() {
			super();
			this._frames = new Vector.<Matrix3D>();
		}
		
		public function get frames():Vector.<Matrix3D> {
			return _frames;
		}

		override public function append(anim:Animator):void {
			super.append(anim);
			var list : Vector.<Matrix3D> = (anim as FrameAnimator).frames;
			for each (var frame : Matrix3D in list) {
				this.frames.push(frame);
			}
		}
		
		override public function clone():IComponent {
			var c : FrameAnimator = new FrameAnimator();
			c.copyFrom(this);
			return c;
		}
		
		override public function copyFrom(animator:Animator):void {
			super.copyFrom(animator);
			if (animator is FrameAnimator) {
				this._frames = (animator as FrameAnimator).frames.concat();
			}
		}
		
	}
}
