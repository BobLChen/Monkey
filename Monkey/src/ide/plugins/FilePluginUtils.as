package ide.plugins {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import ide.App;
	import ide.events.LogEvent;
	import ide.events.SceneEvent;
	
	import monkey.core.base.Object3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.parser.Max3DSParser;
	import monkey.core.parser.NavMeshParser;
	import monkey.core.parser.OBJParser;
	import monkey.core.utils.AssetsType;
	import monkey.core.utils.Color;
	import monkey.core.utils.Mesh3DUtils;
	import monkey.loader.SkyboxLoader;
	import monkey.loader.WaterLoader;

	public class FilePluginUtils extends EventDispatcher {
		
		public static const TYPES : Array = [
			AssetsType.JPEG,
			AssetsType.JPG,
			AssetsType.PNG,
			AssetsType.MESH,
			AssetsType.ANIM,
			AssetsType.OBJ,
			AssetsType.MAX3DS,
			AssetsType.NAV,
			AssetsType.WATER,
			AssetsType.SKYBOX
		];
		
		private static var _filters : Array;
		private static var _app		: App;
		private static var _utils	: Dictionary;
		
		public function FilePluginUtils() {
				
		}
		
		public static function openFile() : void {
			var file : File = new File();
			file.addEventListener(Event.SELECT, onSelectedFile);
			file.browseForOpen("open", filters);
		}
		
		public static function openFiles() : void {
			var file : File = new File();
			file.addEventListener(Event.SELECT, onSelectedFiles);
			file.browseForDirectory("open");
		}
		
		private static function onSelectedFiles(event:Event) : void {
			var files : File = event.target as File;
			for each (var file : File in files.getDirectoryListing()) {
				if (file.exists && !file.isDirectory) {
					readFile(file);
				}
			}
		}
		
		private static function readFile(file : File) : void {
			var type : String = getType(file.name);
			if (TYPES.indexOf(type) == -1) {
				return;
			}
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.position = 0;
			var bytes : ByteArray = new ByteArray();
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			onImport(bytes, file.name, type);
			App.core.dispatchEvent(new LogEvent("file:" + file.nativePath));
		}
		
		private static function onSelectedFile(event:Event) : void {
			var file : File = event.target as File;
			readFile(file);
		}		
						
		private static function onImport(data : ByteArray, name : String, type : String) : void {
			if (!_utils[type] || !data) {
				return;
			}
			var func : Function = _utils[type];
			var obj  : Object3D = func(data);
			if (obj) {
				obj.name = name;
				_app.scene.addChild(obj);
				_app.selection.objects = [obj];
			}
		}
		
		private static function getType(name : String) : String {
			var tokens : Array = name.split(".");
			var type : String = tokens.pop();
			return type.toLowerCase();
		}
		
		private static function get filters() : Array {
			if (!_filters) {
				var extension : String = "";
				for each (var type : String in TYPES) {
					extension += "*." + type + ";";
				}
				_filters = [new FileFilter("File", extension)];
			}
			return _filters;
		}
		
		public static function init(app:App) : void {
			_app = app;
			_utils = new Dictionary();
			_utils[AssetsType.MESH] 	= openMesh;
			_utils[AssetsType.OBJ]  	= openOBJ;
			_utils[AssetsType.MAX3DS] 	= open3DS;
			_utils[AssetsType.WATER]	= openWater;
			_utils[AssetsType.SKYBOX]	= openSkybox;
		}
		
		/**
		 * 导入mesh 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openMesh(bytes : ByteArray) : Object3D {
			var obj   : Object3D = Mesh3DUtils.readMesh(bytes);
			obj.renderer.material = new ColorMaterial(new Color(0x888888));
			return obj;
		}
		
		/**
		 * 导入obj 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openOBJ(bytes : ByteArray) : Object3D {
			bytes.position = 0;
			var txt : String = bytes.readUTFBytes(bytes.length);
			var parser : OBJParser = new OBJParser();
			parser.proceedParsing(txt);
			return parser.pivot;
		}
		
		/**
		 * 导入3ds 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function open3DS(bytes : ByteArray) : Object3D {
			bytes.position = 0;
			var parser : Max3DSParser = new Max3DSParser(bytes, "");
			parser.startParsing();
			return parser.pivot;
		}
		
		/**
		 * 导入navmesh 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openNavmesh(bytes : ByteArray) : Object3D {
			bytes.position = 0;
			var parser : NavMeshParser = new NavMeshParser();
			return null;
		}
		
		/**
		 * 导入water 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openWater(bytes : ByteArray) : Object3D {
			var loader : WaterLoader = new WaterLoader();
			loader.loadBytes(bytes);
			loader.addEventListener(Event.COMPLETE, function(e : Event):void{
				App.core.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
			});
			return loader;
		}
		
		public static function openSkybox(bytes : ByteArray) : Object3D {
			var loader : SkyboxLoader = new SkyboxLoader();
			loader.loadBytes(bytes);
			loader.addEventListener(Event.COMPLETE, function(e : Event):void{
				App.core.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
			});
			return loader;
		}
		
	}
}
