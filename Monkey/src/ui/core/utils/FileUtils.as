package ui.core.utils {

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class FileUtils extends EventDispatcher {

		public static const IMAGE 	: String = "image";
		public static const BINARY 	: String = "binary";
		public static const TXT 	: String = "txt";

		public  var name 	: String;
		private var _bitmap : Bitmap;
		private var _fr 	: FileReference;
		private var _type 	: String;

		public function FileUtils() {
			_fr = new FileReference();
			_fr.addEventListener(Event.COMPLETE, onFileLoadCompleted);
			_fr.addEventListener(Event.SELECT, 	onFileSelected);
		}

		public function get bitmap() : Bitmap {
			return _bitmap;
		}

		public function get binary() : ByteArray {
			return _fr.data;
		}

		private function done() : void {
			switch (_type) {
				case IMAGE:  {
					this.dispatchEvent(new Event(IMAGE));
					break;
				}
				case BINARY:  {
					this.dispatchEvent(new Event(BINARY));
					break;
				}
			}
		}
		
		private function onFileLoadCompleted(event : Event) : void {
			switch (_type) {
				case IMAGE:  {
					var loader : Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e : Event) : void {
						_bitmap = loader.content as Bitmap;
						done();
					});
					loader.loadBytes(_fr.data);
					break;
				}
				case BINARY:  {
					done();
					break;
				}
			}
		}
		
		private function onFileSelected(event : Event) : void {
			name = _fr.name;
			_fr.load();
		}
		
		public function openForImage(filters : Array) : void {
			_type = IMAGE;
			_fr.browse(filters);
		}

		public function openForBinary(filter : Array) : void {
			_type = BINARY;
			_fr.browse(filter);
		}
		
	}
}
