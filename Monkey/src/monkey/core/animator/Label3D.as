package monkey.core.animator {

	/**
	 * 动画标签 
	 * @author Neil
	 * 
	 */	
	public class Label3D {
		
		/** 动画名称 */
		public var name  : String;
		/** 起始帧 */
		public var from  : int;
		/** 结束帧 */
		public var to	 : int;
		/** 播放速度 */
		public var speed : Number = 1;
		
		/**
		 * @param name			动画名称
		 * @param from			from
		 * @param to			to
		 * @param frameSpeed	speed
		 */
		public function Label3D(name : String, from : int, to : int, frameSpeed : Number = 1) {
			this.name	= name;
			this.from	= from;
			this.to 	= to;
			this.speed 	= frameSpeed;
		}
		
		/**
		 * 动画长度 
		 * @return 
		 */		
		public function get length() : int {
			return this.to - this.from + 1;
		}
		
		public function toString() : String {
			return "[object Label3D " + this.name + " from:" + this.from + ", to:" + this.to + "]";
		}
	}
}
