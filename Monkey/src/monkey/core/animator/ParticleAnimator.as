package monkey.core.animator {
	
	import monkey.core.interfaces.IComponent;

	/**
	 * 粒子系统动画控制器 
	 * @author Neil
	 * 
	 */	
	public class ParticleAnimator extends Animator {
		
		public function ParticleAnimator() {
			super();
		}
		
		override public function clone():IComponent {
			var c : ParticleAnimator = new ParticleAnimator();
			c.copyFrom(this);
			return c;
		}
		
		override public function set totalFrames(value:Number):void {
			_totalFrames = value / _hz;
		}
		
	}
}
