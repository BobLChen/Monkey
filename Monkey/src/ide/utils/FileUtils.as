package ide.utils {
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
		
	/**
	 * file工具 
	 * @author Neil
	 * 
	 */	
	public class FileUtils {
		
		private static const IMAGE_TYPE : Array = [new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")];
		
		public var file 	 : File;
		public var data 	 : Object;
		public var bytes	 : ByteArray;
		private var callback : Function;
		
		public function FileUtils() {
			this.file = new File();
		}
		
		/**
		 * 打开图片 
		 * @param callback
		 * 
		 */		
		public function openForImage(callback : Function) : void {
			this.callback = callback;
			this.file.addEventListener(Event.SELECT, onSelectImage);
			this.file.browseForOpen("Image", IMAGE_TYPE);
		}
		
		private function onSelectImage(event:Event) : void {
			var fr : FileStream = new FileStream();
			fr.open(file, FileMode.READ);
			bytes = new ByteArray();
			fr.readBytes(bytes, 0, fr.bytesAvailable);
			fr.close();
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e : Event):void{
				if (callback) {
					callback((loader.content as Bitmap).bitmapData);
				}
			});
			loader.loadBytes(bytes);
		}
		
		/**
		 * 保存文件 
		 * @param data		data
		 * @param type		.xxx
		 * 
		 */		
		public function save(data : ByteArray, type : String) : void {
			this.file.browseForSave("Save As");
			this.file.addEventListener(Event.SELECT, function(e : Event):void{
				var f : File = new File(file.url + "." + type);
				var fs : FileStream = new FileStream();
				fs.open(f, FileMode.WRITE);
				fs.writeBytes(data, 0, data.length);
				fs.close();
			});
		}
		
	}
}
