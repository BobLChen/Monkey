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
		
		protected var _queues 	   : Vector.<IQueLoader>;		// 加载队列
		protected var _loaded	   : Boolean;					// 是否已经加载完成
		protected var _loading	   : Boolean;					// 正在载入
		protected var _bytesLoaded : uint;
		protected var _bytesTotal  : uint;
		protected var _closed	   : Boolean;
		protected var _current	   : IQueLoader;
		
		public function QueLoader() {
			this._queues  = new Vector.<IQueLoader>();
			this._loading = false;
			this._closed  = false;
			this._loaded  = false;
		}
		
		/**
		 * 载入队列 
		 * @return 
		 * 
		 */		
		public function get queues():Vector.<IQueLoader> {
			return _queues;
		}
		
		/**
		 * 压入一个 
		 * @param item
		 * 
		 */		
		public function push(item : IQueLoader) : void {
			this._queues.push(item);
		}
		
		/**
		 *  载入
		 */		
		public function load() : void {
			if (this._loading || this._closed) {
				return;
			}
			var item : IQueLoader = this._queues.pop();
			if (!item) {
				this.allComplete();
				return;
			}
			this._loading = true;
			this._current = item;
			item.addEventListener(Event.COMPLETE, 			onItemComplete);
			item.addEventListener(ProgressEvent.PROGRESS, 	onItemProgress);
			item.addEventListener(IOErrorEvent.IO_ERROR,  	onItemComplete);
			item.load();
		}
		
		/**
		 * 所有的都载入完成 
		 */		
		protected function allComplete() : void {
			this._loaded = true;
			this._closed = true;
			this.dispatchEvent(new Event(Event.COMPLETE));			
		}
		
		/**
		 * 载入进度 
		 * @param e
		 * 
		 */		
		protected function onItemProgress(e : ProgressEvent) : void {
			this._bytesLoaded = e.bytesLoaded;
			this._bytesTotal  = e.bytesTotal;
			this.dispatchEvent(e);
		}
		
		/**
		 * 载入完成 
		 * @param e
		 * 
		 */		
		protected function onItemComplete(e : Event) : void {
			this._loading = false;
			var item : IQueLoader = e.target as IQueLoader;
			item.removeEventListener(Event.COMPLETE, 			onItemComplete);
			item.removeEventListener(ProgressEvent.PROGRESS, 	onItemProgress);
			item.removeEventListener(IOErrorEvent.IO_ERROR,  	onItemComplete);
			if (e is IOErrorEvent) {
				this.dispatchEvent(e);
				this.dispatchEvent(new QueLoaderEvent(item, QueLoaderEvent.QUEUE_ITEM_IO_ERROE));	
			} else {
				this.dispatchEvent(new QueLoaderEvent(item, QueLoaderEvent.QUEUE_ITEM_COMPLETE));	
			}
			this.load();
		}
		
		/**
		 * 关闭链接 
		 */		
		public function close():void {
			if (this._closed) {
				return;
			}
			if (this._loading && this._current) {
				this._current.close();
			}
			this._closed = true;
		}
		
		/**
		 * 已经载入了多少 
		 * @return 
		 * 
		 */		
		public function get bytesLoaded():uint {
			return _bytesLoaded;
		}
		
		/**
		 * 总量 
		 * @return 
		 * 
		 */		
		public function get bytesTotal():uint {
			return _bytesTotal;
		}
		
		/**
		 * 是否载入完成 
		 * @return 
		 * 
		 */		
		public function get loaded():Boolean {
			return _loaded;
		}
		
	}
}
