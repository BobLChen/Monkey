package ide {

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import ui.core.container.Box;
	import ui.core.controls.Control;

	public class GUI {
		
		public  var root 		: Box;
		private var _panelDict 	: Dictionary;
		private var _container 	: DisplayObjectContainer;
		
		public function GUI(container : DisplayObjectContainer) {
			this._container = container;
			this._panelDict = new Dictionary();
			
			this.root = new Box();
			this.root.name = "root";
			this.root.orientation = Box.VERTICAL;
			this.root.allowResize = true;
			this.root.flexible 	  = 1;
			this.root.space 	  = 0;
			this.root.height 	  = 500;
			
			this._container.addChild(this.root.view);
			
			if (this._container.stage == null) {
				this._container.addEventListener(Event.ADDED_TO_STAGE, addToStage);
			} else {
				this.addToStage(null);
			}
		}
		
		protected function addToStage(event : Event) : void {
			this._container.removeEventListener(Event.ADDED_TO_STAGE, addToStage);
			this.update();
			this.draw();
		}
		
		public function update() : void {
			this.root.width  = this._container.stage.stageWidth - 1;
			this.root.height = this._container.stage.stageHeight - 1;
			this.root.update();
		}
		
		/**
		 * 标记Panel 
		 * @param control
		 * 
		 */		
		public function markPanel(control : Control) : void {
			this._panelDict[control.name] = control;
		}
		
		/**
		 * 获取Panel 
		 * @param name
		 * @return 
		 * 
		 */		
		public function getPanel(name : String) : Control {
			return this._panelDict[name];
		}
		
		/**
		 * 绘制 
		 */		
		public function draw() : void {
			this.root.showBorders = true;
			this.root.draw();
		}
		
		/**
		 * 添加UI 
		 * @param ui
		 * 
		 */		
		public function addUI(ui : Control) : void {
			this.root.addControl(ui);
			this.root.update();
			this.root.draw();
		}
	}
}
