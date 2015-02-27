package ide {

	import flash.display.Sprite;
	import flash.events.Event;
	
	import ide.plugins.CreatePlugin;
	import ide.plugins.HierarchyPlugin;
	import ide.plugins.ImportPlugin;
	import ide.plugins.LogPlugin;
	import ide.plugins.PropertiesPlugin;
	import ide.plugins.ScenePlugin;
	import ide.plugins.SelectionPlugin;
	
	import ui.core.Style;
	import ui.core.container.Box;
	import ui.core.controls.TabControl;
	import ui.core.controls.ToolTip;
	import ui.core.controls.Window;

	public class Studio extends Sprite {
		
		private var _rootLayer	: Sprite;
		private var _ide		: Box;
		private var _scene  	: TabControl;
		private var _output	 	: TabControl;
		private var _property	: TabControl;
		private var _hierarchy 	: TabControl;
				
		public function Studio() {
			if (this.stage) {
				this.init();
			} else {
				this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			}
		}
		
		public function get rootLayer():Sprite {
			return _rootLayer;
		}
		
		/**
		 * 层级panel 
		 * @return 
		 * 
		 */		
		public function get hierarchy():TabControl {
			return _hierarchy;
		}
		
		/**
		 * 属性panel 
		 * @return 
		 * 
		 */		
		public function get property():TabControl {
			return _property;
		}
		
		/**
		 * 日志panel 
		 * @return 
		 * 
		 */		
		public function get output():TabControl {
			return _output;
		}
		
		/**
		 * 场景panel 
		 * @return 
		 * 
		 */		
		public function get scene():TabControl {
			return _scene;
		}
		
		/**
		 * added to stage 
		 * @param event
		 * 
		 */		
		private function onAddToStage(event : Event) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			this.init();
		}
		
		private function init() : void {
			this.stage.color = Style.backgroundColor;
			this.stage.frameRate = 60;
			this._rootLayer = new Sprite();
			
			var baseLayer : Sprite = new Sprite();
			var popLayer  : Sprite = new Sprite();
			popLayer.addChild(ToolTip.toolTip);
			popLayer.addChild(Window.popWindow.view);
			Window.popWindow.visible = false;
			Window.popWindow.x = stage.stageWidth / 2;
			Window.popWindow.y = stage.stageHeight / 2;
			// add to stage			
			this.addChild(rootLayer);
			this.addChild(baseLayer);
			this.addChild(popLayer);
			// ide
			this._ide = new Box();
			this._ide.name = "root";
			this._ide.orientation = Box.HORIZONTAL;
			this._ide.allowResize = true;
			this._ide.flexible 	  = 1;
			this._ide.space 	  = 0;
			this._ide.height 	  = 400;
			baseLayer.addChild(this._ide.view);
			// 场景面板
			this._scene  = new TabControl();
			this._scene.minHeight = 550;
			// 日志面板
			this._output = new TabControl();
			this._output.minHeight = 100;
			// 属性面板
			this._property = new TabControl();
			this._property.minWidth = 120;
			// 层级面板
			this._hierarchy = new TabControl();
			this._hierarchy.minWidth = 200;
			// 左边panel
			var leftBox : Box = new Box();
			leftBox.minWidth = 900;
			leftBox.orientation = Box.VERTICAL;
			leftBox.allowResize = true;
			leftBox.showBorders = true;
			leftBox.addControl(scene);
			leftBox.addControl(output);
			// 右边panel
			var right : Box = new Box();
			right.width = 400;
			right.orientation = Box.HORIZONTAL;
			right.showBorders = true;
			right.allowResize = true;
			right.minWidth = 200;
			right.addControl(property);
			right.addControl(hierarchy);
			// ide
			this._ide.addControl(leftBox);
			this._ide.addControl(right);
			
			var app : App = new App(this);
			app.stage = this.stage;
			// 初始化app
			app.initPlugin(new ScenePlugin());
			app.initPlugin(new LogPlugin());
			app.initPlugin(new CreatePlugin());
			app.initPlugin(new SelectionPlugin());
			app.initPlugin(new PropertiesPlugin());
			app.initPlugin(new HierarchyPlugin());
//			this._app.initPlugin(new MaterialPlugin());
			app.initPlugin(new ImportPlugin());
//			this._app.initPlugin(new ControllerPlugin());
//			this._app.initPlugin(new ExportPlugin());
			
			this.stage.addEventListener(Event.RESIZE, onResize);
		}
		
		/**
		 * resize event 
		 * @param event
		 * 
		 */		
		private function onResize(event : Event) : void {
			this._ide.width = stage.stageWidth;
			this._ide.height = stage.stageHeight;
			this.update();	
		}
		
		public function update() : void {
			this._ide.update();
			this._ide.draw();
		}

	}
}
