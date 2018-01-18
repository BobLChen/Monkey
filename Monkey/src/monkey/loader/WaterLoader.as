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
	import monkey.core.entities.Water3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.Zip;
	
	/**
	 * 海水加载器 
	 * @author Neil
	 * 
	 */	
	public class WaterLoader extends Object3D implements IQueLoader {
		
		public var water	: Water3D;
		
		private var zip 	: Zip;
		private var cfg 	: Object;		
		private var tex 	: BitmapData;
		private var loader 	: Loader;
		private var url		: String;
		
		private var _bytesLoaded : uint;
		private var _bytesTotal	 : uint;
		private var _urlloader	 : URLLoader;
		private var _closed		 : Boolean;
		private var _loaded		 : Boolean;
		
		public function WaterLoader(url : String) {
			super();
			this.url = url;
			this._closed = false;
			this._loaded = false;
		}
		
		/**
		 * load bytes 
		 * @param bytes
		 * 
		 */		
		public function loadBytes(bytes : ByteArray) : void {
			zip = new Zip();
			zip.loadBytes(bytes);
			// 读取配置
			var strBytes : ByteArray = zip.getFileByName("config");
			var configStr: String = strBytes.readUTFBytes(strBytes.length);
			this.cfg = JSON.parse(configStr);
			// 读取贴图
			var texBytes : ByteArray = zip.getFileByName("texture");
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onTextureLoadComplete);
			this.loader.loadBytes(texBytes);
		}
		
		/**
		 * 贴图加载完成 
		 * @param event
		 * 
		 */		
		private function onTextureLoadComplete(event:Event) : void {
			this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onTextureLoadComplete);
			this.tex = (loader.content as Bitmap).bitmapData;
			this.loader.unloadAndStop(true);
			// 加载扭曲贴图
			var nrmBytes : ByteArray = zip.getFileByName("normal");
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onNormalLoadComplete);
			this.loader.loadBytes(nrmBytes);
		}
				
		private function onNormalLoadComplete(event:Event) : void {
			this._loaded = true;
			this.zip.dispose();
			var nrm : BitmapData = (loader.content as Bitmap).bitmapData;
			this.loader.unloadAndStop(true);
			// 初始化water
			this.water = new Water3D(tex, nrm, cfg.width, cfg.height, cfg.segment);
			this.water.setLayer(cfg.layer);
			this.water.waterSpeed = cfg.waterSpeed;
			this.water.waterWave  = cfg.waterWave;
			this.water.waterHeight= cfg.waterHeight;
			this.water.blendColor = new Color(cfg.blendColor);
			this.water.transform.local.copyRawDataFrom(Vector.<Number>(cfg.transform));
			this.addChild(water);
			this.transform.updateTransforms(true);
			this.dispatchEvent(event);
		}
		
		/**
		 * load url 
		 * @param url
		 * 
		 */		
		public function load() : void {
			this._urlloader = new URLLoader();
			this._urlloader.dataFormat = URLLoaderDataFormat.BINARY;
			this._urlloader.addEventListener(Event.COMPLETE, 			onLoadComplete);
			this._urlloader.addEventListener(ProgressEvent.PROGRESS, 	onProgress);
			this._urlloader.addEventListener(IOErrorEvent.IO_ERROR,  	onIoError);
			this._urlloader.load(new URLRequest(url));
		}
		
		public function close():void {
			if (this._closed) {
				return;
			}
			this._closed = true;
			if (this._urlloader) {
				this._urlloader.close();
			}
		}
				
		public function get bytesLoaded():uint {
			return _bytesLoaded;
		}
		
		public function get bytesTotal():uint {
			return _bytesTotal;
		}
		
		public function get loaded():Boolean {
			return this._loaded;
		}
		
		private function onIoError(event:IOErrorEvent) : void {
			this.dispatchEvent(event);			
		}
		
		private function onProgress(event:ProgressEvent) : void {
			this._bytesLoaded = event.bytesLoaded;
			this._bytesTotal  = event.bytesTotal;
			this.dispatchEvent(event);			
		}
		
		private function onLoadComplete(event:Event) : void {
			this._urlloader.removeEventListener(Event.COMPLETE, 			onLoadComplete);
			this._urlloader.removeEventListener(ProgressEvent.PROGRESS, 	onProgress);
			this._urlloader.removeEventListener(IOErrorEvent.IO_ERROR,  	onIoError);
			var bytes : ByteArray = this._urlloader.data as ByteArray;
			this._urlloader.close();
			this._urlloader = null;
			this.loadBytes(bytes);
			bytes.clear();
		}
		
	}
}
