package monkey.core.animator {
	
	import monkey.core.interfaces.IComponent;
	import monkey.core.utils.Time3D;

	/**
	 * 粒子系统动画控制器 
	 * @author Neil
	 * 
	 */	
	public class ParticleAnimator extends Animator {
		
		private var _playLoops : int = 1;
		private var _loops     : int = 1;
		
		/**
		 * 粒子动画无其它行为，只根据时间播放。 
		 * 
		 */		
		public function ParticleAnimator() {
			super();
			this.playLoops = 1;
		}
		
		/**
		 * 当前循环次数 
		 * @return 
		 * 
		 */		
		public function get loops():int {
			return _loops;
		}

		/**
		 * 播放次数 
		 * @return 
		 * 
		 */		
		public function get playLoops():int {
			return _playLoops;
		}
		
		/**
		 * 播放次数 
		 * @param value
		 * 
		 */		
		public function set playLoops(value:int):void {
			this._playLoops = value;
			this._loops = value;
		}
		
		/**
		 * 拼接动画 
		 * @param anim
		 * 
		 */		
		override public function append(anim:Animator):void {
			// ......
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		override public function clone():IComponent {
			var c : ParticleAnimator = new ParticleAnimator();
			c.copyFrom(this);
			return c;
		}
		
		/**
		 * 当前帧 
		 * @param value
		 * 
		 */		
		override public function set currentFrame(value:Number):void {
			this._currentFrame = value;
		}
		
		override public function play(animationMode:int=ANIMATION_STOP_MODE):void {
			super.play(animationMode);
			this._loops = this.playLoops;
		}
		
		/**
		 * goto and play 
		 * @param frame
		 * @param animationMode
		 * 
		 */		
		override public function gotoAndPlay(frame:Object, animationMode:int=ANIMATION_LOOP_MODE):void {
			this._currentFrame  = frame as Number;
			this._currentFrame *= _hz;
			this._playing = true;
			this._completed = false;
			this._loops = this.playLoops;
		}
		
		/**
		 * goto and stop 
		 * @param frame
		 * 
		 */		
		override public function gotoAndStop(frame:Object):void {
			this._currentFrame  = frame as Number;
			this._currentFrame *= _hz;
			this._playing = false;
			this._completed = false;
			this._loops = this.playLoops;
			if (this._currentFrame >= this._totalFrames * this.playLoops) {
				this._completed = true;
			}
		}
		
		/**
		 *  update
		 */		
		override public function onUpdate():void {
			if (!this._playing) {
				return;
			}
			this._currentFrame += Time3D.deltaTime;
			// 拥有循环次数
			if (this._currentFrame >= this._totalFrames && this.loops > 1) {
				this._currentFrame = 0;
				this._loops--;
			} else if (this._currentFrame >= this._totalFrames && this.loops <= 1) {
				this._playing = false;
				if (this.hasEventListener(ANIMATION_COMPLETE_EVENT)) {
					this._completed = true;
					this.dispatchEvent(animCompleteEvent);
				}
			}
		}
		
	}
}
