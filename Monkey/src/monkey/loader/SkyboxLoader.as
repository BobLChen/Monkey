package monkey.loader {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.SkyBox;
	import monkey.core.utils.Zip;
	
	/**
	 * 天空盒加载器 
	 * @author Neil
	 * 
	 */	
	public class SkyboxLoader extends Object3D {

		public var skybox 	: SkyBox;
		
		private var zip 	: Zip;
		private var cfg 	: Object;
		private var loader 	: Loader;

		public function SkyboxLoader() {
			super();
		}

		public function loadBytes(bytes : ByteArray) : void {
			this.zip = new Zip();
			this.zip.loadBytes(bytes);
			var cfgBytes : ByteArray = zip.getFileByName("config");
			this.cfg = JSON.parse(cfgBytes.readUTFBytes(cfgBytes.length));
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTextureLoadComplete);
			this.loader.loadBytes(zip.getFileByName("texture"));
		}

		public function load(url : String) : void {
			var urlloader : URLLoader = new URLLoader();
			urlloader.dataFormat = URLLoaderDataFormat.BINARY;
			urlloader.addEventListener(Event.COMPLETE, onLoadComplete);
			urlloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			urlloader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			urlloader.load(new URLRequest(url));
		}

		private function onIoError(event : IOErrorEvent) : void {
			this.dispatchEvent(event);
		}

		private function onProgress(event : ProgressEvent) : void {
			this.dispatchEvent(event);
		}

		private function onLoadComplete(event : Event) : void {
			var bytes : ByteArray = (event.target as URLLoader).data as ByteArray;
			this.loadBytes(bytes);
			bytes.clear();
		}

		private function onTextureLoadComplete(event : Event) : void {
			this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onTextureLoadComplete);
			var bmp : BitmapData = (this.loader.content as Bitmap).bitmapData;
			this.loader.unloadAndStop(true);
			this.skybox = new SkyBox(bmp, this.cfg.size, this.cfg.scaleRatio);
			this.zip.dispose();
			this.addChild(skybox);
			this.dispatchEvent(event);
		}

	}
}
