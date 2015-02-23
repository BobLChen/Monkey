package monkey.core.utils {
	import flash.utils.getTimer;

	public class Time3D {
		
		/** 上一帧时间 */
		private static var lastTime   : int = 0;
		/** 当前时间 */
		private static var currTime   : int = 0;
		// 帧频
		private static var _deltaTime : Number = 0;
		// 总时间
		private static var _totalTime : Number = 0;
		
		public function Time3D() {
			
		}
		
		public static function update() : void {
			currTime 	= getTimer();
			_deltaTime 	= (currTime - lastTime) / 1000.0;
			lastTime 	= currTime;			
			_totalTime += _deltaTime;
		}
		
		/**
		 * 获取deltaTime 
		 * @return 
		 * 
		 */		
		public static function get deltaTime() : Number {
			return _deltaTime;
		}
		
		public static function get totalTime() : Number {
			return _totalTime;
		}
		
	}
}
