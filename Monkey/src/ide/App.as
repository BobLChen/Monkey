package ide {

	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	import ide.help.Selection;
	
	import monkey.core.scene.Scene3D;
	
	import ui.core.Undo;
	import ui.core.event.UndoEvent;
	import ui.core.interfaces.IPlugin;

	public class App extends EventDispatcher {

		private static var _instance : App;

		public var stage : Stage; 						// stage

		private var _keysDict 	: Dictionary; 			// 按键
		private var _shortKey 	: Dictionary; 			// 快捷键
		private var _plugins 	: Vector.<IPlugin>; 	// 插件
		private var _started 	: Boolean; 				// started
		private var _version 	: String; 				// 版本
		private var _undo 		: Undo; 				// undo
		private var _scene 		: Scene3D; 				// scene
		private var _selection 	: Selection;			// selection
		private var _menu 		: NativeMenu; 			// menu
		private var _studio 	: Studio;
				
		public function App(studio : Studio) {
			if (_instance != null) {
				throw new Error("App:single ton");
			}
			_instance = this;
			this._selection= new Selection(this);
			this._menu 	   = new NativeMenu();
			this._studio   = studio;
			this._shortKey = new Dictionary();
			this._keysDict = new Dictionary();
			this._plugins  = new Vector.<IPlugin>();
			this._undo 	   = new Undo();
			this._undo.addEventListener(UndoEvent.PUSH, this.dispatchEvent);
			this._undo.addEventListener(UndoEvent.UNDO, this.dispatchEvent);
			this._undo.addEventListener(UndoEvent.REDO, this.dispatchEvent);
			this._studio.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		/**
		 * 添加menu 
		 * @param label			labels
		 * @param callback		callback
		 * @return 
		 * 
		 */		
		public function addMenu(label : String = null, callback : Function = null) : NativeMenuItem {
			var labels : Array = label.split("/");
			if (labels.length == 0) {
				throw new Error("Invalud menu path.");
			}
			var menu : NativeMenu = this._menu;
			while (labels.length) {
				var txt  : String = labels.shift();
				var item : NativeMenuItem = null;
				for each (var mi : NativeMenuItem in menu.items) {
					if (mi.name == txt || mi.label == txt) {
						item = mi;
					}
				}
				if (!item) {
					item = menu.addItem(new NativeMenuItem(txt));
				}
				if (labels.length) {
					if (!item.submenu) {
						item.submenu = new NativeMenu();
					}
				} else {
					item.name = label;
					if (callback != null) {
						item.addEventListener(Event.SELECT, callback);
					}
				}
				menu = item.submenu;
			}
			if (NativeApplication.supportsMenu){
				NativeApplication.nativeApplication.menu = this._menu;
			} else if (NativeWindow.supportsMenu){
				App.core.stage.nativeWindow.menu = this._menu;
			}
			return item;
		}
		
		public function get selection() : Selection {
			return _selection;
		}

		public function set selection(value : Selection) : void {
			this._selection = value;
		}
		
		public function get studio() : Studio {
			return _studio;
		}

		public function get scene() : Scene3D {
			return _scene;
		}

		public function set scene(value : Scene3D) : void {
			this._scene = value;
		}

		public static function get core() : App {
			return _instance;
		}

		/**
		 * 初始化插件
		 * @param plugin
		 *
		 */
		public function initPlugin(plugin : IPlugin) : void {
			plugin.init(this);
			plugin.start();
			this._plugins.push(plugin);
		}
		
		/**
		 * 通过类类型获取对应的Plugin 
		 * @param clazz
		 * @return 
		 * 
		 */		
		public function getPluginByClazz(clazz : Class) : IPlugin {
			for each (var ip : IPlugin in this._plugins) {
				if (ip is clazz) {
					return ip;
				}
			}
			return null;
		}
		
		/**
		 * 按键
		 * @param event
		 */
		private function onKeyDown(event : KeyboardEvent) : void {
			var arr : Array = null;
			if (_shortKey[event.keyCode] != undefined && event.ctrlKey) {
				arr = _shortKey[event.keyCode];
				for (var i : int = 0; i < arr.length; i++) {
					arr[i].call();
				}
			}
			if (_keysDict[event.keyCode] != undefined) {
				arr = _keysDict[event.keyCode];
				for (var j : int = 0; j < arr.length; j++) {
					arr[j].call();
				}
			}
		}

		/**
		 * 移除快捷键
		 * @param callback		回调函数
		 * @param key			keycode
		 * @param command		command
		 *
		 */
		public function removeKey(callback : Function, key : int, command : Boolean = false) : void {
			var arr : Array = null;
			var idx : int = -1;
			if (command) {
				if (_shortKey[key] == undefined)
					return;
				arr = _shortKey[key];
				idx = arr.indexOf(callback);
				if (idx == -1)
					return;
				arr.splice(idx, 1);
			} else {
				if (_keysDict[key] == undefined)
					return;
				arr = _keysDict[key];
				idx = arr.indexOf(callback);
				if (idx == -1)
					return;
				arr.splice(idx, 1);
			}
		}
		
		/**
		 *
		 * @param callback
		 * @param key
		 * @param command
		 *
		 */
		public function addShortKey(callback : Function, key : int, command : Boolean = false) : void {
			var arr : Array = null;
			if (command) {
				if (_shortKey[key] == undefined) {
					_shortKey[key] = [];
				}
				arr = _shortKey[key];
				if (arr.indexOf(callback) == -1) {
					arr.push(callback);
				}
			} else {
				if (_keysDict[key] == undefined) {
					_keysDict[key] = [];
				}
				arr = _keysDict[key];
				if (arr.indexOf(callback) == -1) {
					arr.push(callback);
				}
			}
		}

	}
}

/**
 * key item
 * @author Neil
 */
class KeyItem {
	public var command : Boolean; 	// command
	public var key 	   : int; 		// keycode
	public var func    : Function;	// callback
}
