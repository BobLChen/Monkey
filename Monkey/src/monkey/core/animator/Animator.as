package monkey.core.animator {
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import monkey.core.components.Component3D;
	import monkey.core.utils.Time3D;

	/**
	 * 动画控制器 
	 * @author Neil
	 * 
	 */	
	public class Animator extends Component3D {
		
		public static const ANIMATION_COMPLETE		: String = "Animator:ANIMATION_COMPLETE";
		
		protected static const animCompleteEvent 	: Event = new Event(ANIMATION_COMPLETE);
		
		/** 循环动画 */
		public static const ANIMATION_LOOP_MODE 	: int = 0;
		/** 非循环动画 */
		public static const ANIMATION_STOP_MODE 	: int = 1;
		/** ping pong */
		public static const ANIMATION_PINT_PONG		: int = 2;
		
		/** 动画标签 */
		public var labels 			: Dictionary;
		/** 总帧数 */
		public var totalFrames 		: int = 0;
		
		private var _fps 			: Number;			// 帧频
		private var _hz  	 		: Number;			// 播放速度
		private var _from	 		: Number;			// 起始帧
		private var _to		 		: Number;			// 结束帧
		private var _playing 		: Boolean;			// 是否正在播放
		private var _currentFrame 	: Number = 0;		// 当前帧
		private var _currentLabel 	: Label3D;			// 当前动画标签
		private var _frameSpeed   	: Number;			// 速度
		private var _animationMode	: int;
		
		public function Animator() {
			super();
			this.fps = 60;
			this.labels = new Dictionary();
			this.frameSpeed = 1.0;
		}
		
		/**
		 * 动画模式 
		 * @return 
		 * 
		 */		
		public function get animationMode():int {
			return _animationMode;
		}
		
		/**
		 * 动画模式 
		 * @return 
		 * 
		 */		
		public function set animationMode(value:int):void {
			_animationMode = value;
		}
		
		/**
		 * 目的帧 
		 * @return 
		 * 
		 */		
		public function get to():Number {
			return _to;
		}
		
		/**
		 * 起始帧 
		 * @return 
		 * 
		 */		
		public function get from():Number {
			return _from;
		}

		/**
		 * goto and stop 
		 * @param frame
		 * 
		 */		
		public function gotoAndStop(frame : Object) : void {
			var idx : Number = 0;
			// 动画标签
			if (frame is Label3D) {
				this.addLabel(frame as Label3D);
				this._from = (frame as Label3D).from;
				this._to   = (frame as Label3D).to;
				this.currentFrame = from;
			// 动画名称
			} else if (frame is String && labels[frame]) {
				this._from = (labels[frame] as Label3D).from;
				this._to   = (labels[frame] as Label3D).to;
				this.currentFrame = from;
			// 动画帧位置
			} else if (frame as Number) {
				this._from = 0;
				this._to   = totalFrames - 1;
				this.currentFrame = frame as Number;
			} else {
				return;
			}
			this._playing = false;
		}
		
		/**
		 * goto and play 
		 * @param frame				frame
		 * @param animationMode		动画模式
		 * 
		 */		
		public function gotoAndPlay(frame : Object, animationMode : int = ANIMATION_LOOP_MODE) : void {
			// 动画标签
			if (frame is Label3D) {
				this._currentLabel = frame as Label3D;
				this._from = currentLabel.from;
				this._to   = currentLabel.to;
				this._frameSpeed  = currentLabel.speed;
				this.currentFrame = from; 
			} else if (frame is String && labels[frame]) {
				this._currentLabel = labels[frame];
				this._from = currentLabel.from;
				this._to   = currentLabel.to;
				this._frameSpeed  = currentLabel.speed;
				this.currentFrame = from;
			} else if (frame as Number) {
				this._currentLabel = null;
				this._from = frame as Number;
				this._to   = totalFrames - 1;
				this.currentFrame = frame as Number;
			} else {
				return;
			}
			this._playing = true;
			this._animationMode = animationMode;
		}
		
		public function stop() : void {
			this._playing = false;
		}
				
		public function play(animationMode : int = ANIMATION_LOOP_MODE) : void {
			this._from = 0;
			this._to   = totalFrames - 1;
			this._playing = true;
			this._animationMode = animationMode;
		}
		
		/**
		 * 更新 
		 * 
		 */		
		override public function onUpdate():void {
			if (!playing) {
				return;
			}
			this.nextFrame();
		}
						
		/**
		 * 下一帧 
		 */		
		private function nextFrame() : void {
			if (frameSpeed < 0) {
				this.preFrame();
				return;
			}
			this._currentFrame += _frameSpeed * Time3D.deltaTime / _hz;
			var complete : Boolean = false;
			if (_currentFrame >= _to) {
				// 循环模式
				if (_animationMode == ANIMATION_LOOP_MODE) {
					this._currentFrame = _from;
				// stop模式
				} else if (_animationMode == ANIMATION_STOP_MODE) {
					this._currentFrame = _to;
					complete = true;
				// ping pong模式
				} else if (_animationMode == ANIMATION_PINT_PONG) {
					this._currentFrame = _to;
					this._frameSpeed  *= -1;
				}
			}
			this.currentFrame = this._currentFrame;
			if (complete) {
				this.dispatchEvent(animCompleteEvent);
			}
		}
		
		/**
		 * 前一帧 
		 */		
		private function preFrame() : void {
			if (this._frameSpeed > 0) {
				this.nextFrame();
				return;
			}
			this._currentFrame += _frameSpeed * Time3D.deltaTime / _hz;
			var complete : Boolean = false;
			if (this._currentFrame <= _from) {
				// 循环模式
				if (_animationMode == ANIMATION_LOOP_MODE) {
					this._currentFrame = _to;
				} else if (_animationMode == ANIMATION_STOP_MODE) {
					this._currentFrame = _from;
					complete = true;
				} else if (_animationMode == ANIMATION_PINT_PONG) {
					this._currentFrame = _from;
					this._frameSpeed  *= -1;
				}
			}
			this.currentFrame = this._currentFrame;
			if (complete) {
				this.dispatchEvent(animCompleteEvent);
			}
		}
						
		/**
		 * 播放速度 
		 * @return 
		 * 
		 */		
		public function get frameSpeed():Number {
			return _frameSpeed;
		}

		/**
		 * 播放速度 
		 * @return 
		 * 
		 */		
		public function set frameSpeed(value:Number):void {
			_frameSpeed = value;
		}

		/**
		 * 当前正在播放的动画 
		 * @return 
		 * 
		 */		
		public function get currentLabel():Label3D {
			return _currentLabel;
		}
		
		/**
		 * current frame 
		 * @return 
		 * 
		 */		
		public function get currentFrame():Number {
			return _currentFrame;
		}
		
		public function set currentFrame(value:Number):void {
			_currentFrame = value;
		}
		
		/**
		 * 是否正在播放 
		 * @return 
		 * 
		 */		
		public function get playing():Boolean {
			return _playing;
		}
		
		/**
		 * 动画帧频 
		 * @return 
		 * 
		 */		
		public function get fps():Number {
			return _fps;
		}
		
		/**
		 * 设置动画帧频 
		 * @param value
		 * 
		 */		
		public function set fps(value:Number):void {
			_fps = value;
			_hz  = 1.0 / _fps;
		}
		
		/**
		 * 添加动画标签 
		 * @param label
		 * 
		 */		
		public function addLabel(label : Label3D) : void {
			this.labels[label.name] = label;
		}
			
		/**
		 * 移除动画标签 
		 * @param label
		 * 
		 */		
 		public function removeLabel(label : Label3D) : void {
			delete labels[label.name];
		}
				
	}
}
