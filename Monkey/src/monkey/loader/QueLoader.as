package monkey.loader {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	import monkey.event.QueLoaderEvent;

	/**
	 * 队列加载器 
	 * @author Neil
	 * 
	 */	
	public class QueLoader extends EventDispatcher implements IQueLoader {
		
		private var _queues 	 : Vector.<IQueLoader>;		// 加载队列
		private var _loaded		 : Boolean;					// 是否已经加载完成
		private var _loading	 : Boolean;					// 正在载入
		private var _bytesLoaded : uint;
		private var _bytesTotal  : uint;
		
		public function QueLoader() {
			this._queues = new Vector.<IQueLoader>();
			this._loading = false;
		}
		
		public function push(item : IQueLoader) : void {
			this._queues.push(item);
		}
		
		public function load() : void {
			if (this._loading) {
				return;
			}
			var item : IQueLoader = this._queues.pop();
			if (!item) {
				this._loaded = true;
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			this._loading = true;
			item.addEventListener(Event.COMPLETE, 			onComplete);
			item.addEventListener(ProgressEvent.PROGRESS, 	onProgress);
			item.addEventListener(IOErrorEvent.IO_ERROR,  	onComplete);
			item.load();
		}
		
		private function onProgress(e : ProgressEvent) : void {
			this._bytesLoaded = e.bytesLoaded;
			this._bytesTotal  = e.bytesTotal;
			this.dispatchEvent(e);
		}
				
		private function onComplete(e : Event) : void {
			
			this._loading = false;
			
			var item : IQueLoader = e.target as IQueLoader;
			
			item.removeEventListener(Event.COMPLETE, 			onComplete);
			item.removeEventListener(ProgressEvent.PROGRESS, 	onProgress);
			item.removeEventListener(IOErrorEvent.IO_ERROR,  	onComplete);
			
			if (e is IOErrorEvent) {
				this.dispatchEvent(new QueLoaderEvent(item, QueLoaderEvent.QUEUE_ITEM_IO_ERROE));	
			} else {
				this.dispatchEvent(new QueLoaderEvent(item, QueLoaderEvent.QUEUE_ITEM_COMPLETE));	
			}
			
			this.load();
		}
		
		public function get bytesLoaded():uint {
			return _bytesLoaded;
		}
		
		public function get bytesTotal():uint {
			return _bytesTotal;
		}
		
		public function get loaded():Boolean {
			return _loaded;
		}
		
	}
}
