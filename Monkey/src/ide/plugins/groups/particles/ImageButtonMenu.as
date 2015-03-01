package ide.plugins.groups.particles {

	import flash.events.Event;
	
	import ui.core.Menu;
	import ui.core.controls.ImageButton;
	import ui.core.event.ControlEvent;

	public class ImageButtonMenu extends ImageButton {
		
		private var menu : Menu;
		
		public function ImageButtonMenu(source : Object = null, toggle : Boolean = false) {
			super(source, toggle);
			this.addEventListener(ControlEvent.CLICK, onClick);
			this.menu = new Menu();
		}
		
		public function addMenu(txt : String, func : Function) : void {
			this.menu.addMenuItem(txt, func);
			this.view.contextMenu = this.menu.menu;
		}
		
		private function onClick(event:Event) : void {
			this.view.contextMenu.display(this.view.stage, this.view.stage.mouseX, this.view.stage.mouseY);
		}
	}
}
