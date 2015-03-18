package monkey.core.animator {
	
	import monkey.core.interfaces.IComponent;
	import monkey.core.utils.Time3D;

	/**
	 * 粒子系统动画控制器 
	 * @author Neil
	 * 
	 */	
	public class ParticleAnimator extends Animator {
		
		/**
		 * 粒子动画无其它行为，只根据时间播放。 
		 * 
		 */		
		public function ParticleAnimator() {
			super();
		}
		
		override public function clone():IComponent {
			var c : ParticleAnimator = new ParticleAnimator();
			c.copyFrom(this);
			return c;
		}
		
		override public function gotoAndPlay(frame:Object, animationMode:int=ANIMATION_LOOP_MODE):void {
			this._currentFrame  = frame as Number;
			this._currentFrame *= _hz;
			this._playing = true;
		}
		
		override public function gotoAndStop(frame:Object):void {
			this._currentFrame  = frame as Number;
			this._currentFrame *= _hz;
			this._playing = false;
		}
		
		override public function onUpdate():void {
			if (!this._playing) {
				return;
			}
			this._currentFrame += Time3D.deltaTime;
			if (this._currentFrame > this._totalFrames) {
				if (this.hasEventListener(ANIMATION_COMPLETE_EVENT)) {
					this._playing = false;
					this.dispatchEvent(animCompleteEvent);
				}
			}
		}
				
	}
}
