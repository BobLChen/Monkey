package monkey.event {

	import flash.events.Event;
	
	import monkey.loader.IQueLoader;
	
	/**
	 * 加载队列事件 
	 * @author Neil
	 * 
	 */	
	public class QueLoaderEvent extends Event {
		
		/** 队列加载完一项 */
		public static const QUEUE_ITEM_COMPLETE : String = "QUEUE_ITEM_COMPLETE";
		/** 队列IO错误 */
		public static const QUEUE_ITEM_IO_ERROE : String = "QUEUE_ITEM_COMPLETE";
		
		public var item : IQueLoader;
		
		public function QueLoaderEvent(item : IQueLoader, type : String = QUEUE_ITEM_COMPLETE, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
			this.item = item;
		}
		
	}
}
