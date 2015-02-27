package ide.plugins {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import ide.App;
	import ide.events.LogEvent;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Mesh3DUtils;

	public class FilePluginUtils extends EventDispatcher {
		
		public static const JPEG    : String = "jpeg";
		public static const JPG		: String = "jpg";
		public static const PNG		: String = "png";
		public static const MESH 	: String = "mesh";
		public static const ANIM 	: String = "anim";
		public static const OBJ  	: String = "obj";
		public static const MAX3DS  : String = "3ds";
		public static const NAV		: String = "nav";
		public static const WATER	: String = "water";
		public static const SKYBOX  : String = "sky";
		
		public static const TYPES : Array = [
			JPEG,
			JPG,
			PNG,
			MESH,
			ANIM,
			OBJ,
			MAX3DS,
			NAV,
			WATER,
			SKYBOX
		];
		
		private static var _filters : Array;
		private static var _app		: App;
		private static var _utils	: Dictionary;
		
		public function FilePluginUtils() {
				
		}
		
		public static function openFile() : void {
			var file : File = new File();
			file.addEventListener(Event.SELECT, onSelected);
			file.browseForOpen("open", filters);
		}
		
		private static function onSelected(event:Event) : void {
			var file : File = event.target as File;
			var type : String = getType(file.name);
			App.core.dispatchEvent(new LogEvent("file:" + file.nativePath));
			onImport(file.data, type);
		}		
				
		private static function onImport(data : ByteArray, type : String) : void {
			if (!_utils[type]) {
				return;
			}
			var func : Function = _utils[type];
			var obj  : Object3D = func(data);
			if (obj) {
				_app.selection.objects = [obj];
			}
		}
		
		private static function getType(name : String) : String {
			var tokens : Array = name.split(".");
			return tokens.pop();
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
			_utils[MESH] = openMesh;
			_utils[OBJ]  = openOBJ;
		}
		
		public static function openMesh(bytes : ByteArray) : Object3D {
			var obj   : Object3D = new Object3D();
			var mesh  : Mesh3D = Mesh3DUtils.readMesh(bytes);
			obj.addComponent(new MeshRenderer(mesh, new ColorMaterial()));			
			return obj;
		}
		
		public static function openOBJ(bytes : ByteArray) : Object3D {
			var obj : Object3D = new Object3D();
			
			
			return obj;
		}
		
	}
}
