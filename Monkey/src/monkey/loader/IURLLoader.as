package monkey.loader {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class IURLLoader extends EventDispatcher implements IQueLoader {
		
		private var loader : URLLoader;
		private var _closed: Boolean;
		private var _loaded: Boolean;
		private var _data  : Object;
		private var _url   : String;
		
		/**
		 * @param url	url
		 * 
		 */		
		public function IURLLoader(url : String) {
			this._url = url;
			this.loader = new URLLoader();
		}

		public function get data():Object {
			return this._data;
		}
		
		public function set dataFormat(format : String) : void {
			this.loader.dataFormat = format;
		}

		public function load() : void {
			this.loader.addEventListener(Event.COMPLETE, 		 onLoadComplete);
			this.loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR,  onIoError);
			this.loader.load(new URLRequest(this._url));
		}
		
		private function onProgress(event:ProgressEvent) : void {
			this.dispatchEvent(event);
		}
		
		private function onIoError(event:IOErrorEvent) : void {
			this.dispatchEvent(event);		
		}
		
		private function onLoadComplete(event:Event) : void {
			this._loaded = true;
			this._closed = true;
			this._data   = loader.data as ByteArray;
			this.loader.close();
			this.dispatchEvent(event);
		}
		
		public function close() : void {
			if (this._closed) {
				return;
			}
			if (this.loader) {
				this.loader.close();
			}
			this._closed = true;
		}

		public function get bytesTotal() : uint {
			return this.loader.bytesTotal;
		}

		public function get bytesLoaded() : uint {
			return this.loader.bytesLoaded;
		}

		public function get loaded() : Boolean {
			return this._loaded;
		}

	}
}
