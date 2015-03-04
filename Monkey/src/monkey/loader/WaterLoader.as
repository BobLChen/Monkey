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
	
	public class WaterLoader extends Object3D {
		
		public var water	: Water3D;
		
		private var zip 	: Zip;
		private var cfg 	: Object;		
		private var tex 	: BitmapData;
		private var loader 	: Loader;
		
		public function WaterLoader() {
				
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
			// 释放配置资源
			strBytes.clear();	
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
			this.zip.getFileByName("texture").clear();
			// 加载扭曲贴图
			var nrmBytes : ByteArray = zip.getFileByName("normal");
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onNormalLoadComplete);
			this.loader.loadBytes(nrmBytes);
		}
				
		private function onNormalLoadComplete(event:Event) : void {
			var nrm : BitmapData = (loader.content as Bitmap).bitmapData;
			this.loader.unloadAndStop(true);
			this.zip.getFileByName("normal").clear();
			// 初始化water
			this.water = new Water3D(tex, nrm, cfg.width, cfg.height, cfg.segment);
			this.water.waterSpeed = cfg.waterSpeed;
			this.water.waterWave  = cfg.waterWave;
			this.water.waterHeight= cfg.waterHeight;
			this.water.blendColor = new Color(cfg.blendColor);
			this.water.transform.local.copyRawDataFrom(Vector.<Number>(cfg.transform));
			this.addChild(water);
			this.dispatchEvent(event);
		}
		
		/**
		 * load url 
		 * @param url
		 * 
		 */		
		public function load(url : String) : void {
			var urlloader : URLLoader = new URLLoader();
			urlloader.dataFormat = URLLoaderDataFormat.BINARY;
			urlloader.addEventListener(Event.COMPLETE, onLoadComplete);
			urlloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			urlloader.addEventListener(IOErrorEvent.IO_ERROR,  onIoError);
			urlloader.load(new URLRequest(url));
		}
		
		private function onIoError(event:IOErrorEvent) : void {
			this.dispatchEvent(event);			
		}
		
		private function onProgress(event:ProgressEvent) : void {
			this.dispatchEvent(event);			
		}
		
		private function onLoadComplete(event:Event) : void {
			var bytes : ByteArray = (event.target as URLLoader).data as ByteArray;
			this.loadBytes(bytes);
			bytes.clear();
		}
		
	}
}
