package monkey.core.animator {
	
	import monkey.core.base.Object3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.utils.Time3D;

	/**
	 * 粒子系统动画控制器 
	 * @author Neil
	 * 
	 */	
	public class ParticleAnimator extends Animator {
		
		private var _time : Number = 0;
		
		public function ParticleAnimator() {
			super();
		}
		
		override public function clone():IComponent {
			var c : ParticleAnimator = new ParticleAnimator();
			c.copyFrom(this);
			c._time = this._time;
			return c;
		}
		
		override public function gotoAndPlay(frame:Object, animationMode:int=ANIMATION_LOOP_MODE, includeChildren:Boolean=true):void {
			this._time = frame as Number;
			this._playing = true;
			if (includeChildren && object3D) {
				for each (var child : Object3D in object3D) {
					if (child.animator) {
						child.animator.gotoAndPlay(frame, animationMode, includeChildren);
					}
				}
			}
		}
		
		override public function gotoAndStop(frame:Object, includeChildren:Boolean=true):void {
			this._time = frame as Number;
			this._playing = false;
			if (includeChildren && object3D) {
				for each (var child : Object3D in object3D.children) {
					if (child.animator) {
						child.animator.gotoAndStop(frame, includeChildren);
					}
				}
			}
		}
		
		override public function play(animationMode:int=ANIMATION_LOOP_MODE, includeChildren:Boolean=true):void {
			this._playing = true;
			this._animationMode = animationMode;
			if (includeChildren && object3D) {
				for each (var child : Object3D in object3D) {
					if (child.animator) {
						child.animator.play(animationMode, includeChildren);
					}
				}
			}
		}
		
		override public function onUpdate():void {
			if (!playing) {
				return;
			}
			this._time += Time3D.deltaTime;
			if (this._time >= totalFrames) {
				this.stop(false);
				this.dispatchEvent(animCompleteEvent);
			}
		}
		
		override public function get currentFrame():Number {
			return this._time;
		}
		
		override public function set currentFrame(value:Number):void {
			this._time = value;
		}
				
	}
}
