package ide.plugins {

	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import ide.App;
	import ide.events.SelectionEvent;
	import ide.panel.MaterialControl;
	
	import monkey.core.base.Object3D;
	import monkey.core.materials.Material3D;
	
	import ui.core.container.Panel;
	import ui.core.controls.Layout;
	import ui.core.interfaces.IPlugin;

	public class MaterialPlugin implements IPlugin {
		
		private var _app 		: App;
		private var _panel 		: Panel;
		private var _layout 	: Layout;
		private var _materials 	: Dictionary;
		
		public function MaterialPlugin() {
			this._materials = new Dictionary(true);
			this._panel 	= new Panel("MATERIAL");
			this._layout 	= new Layout();
			this._panel.addControl(this._layout);
			this._panel.minWidth = 200;
		}

		public function init(app : App) : void {
			this._app = app;
			this._app.studio.property.addPanel(this._panel);
			this._app.addEventListener(SelectionEvent.CHANGE, changeMaterialEvent);
			this._app.addEventListener(SelectionEvent.CHANGE_MATERIAL, changeMaterialEvent);
		}
				
		private function changeMaterialEvent(event:Event) : void {
//			this._layout.removeAllControls();
//			var pivot : Object3D = this._app.selection.main;
//			if (!pivot || !pivot.renderer || !pivot.renderer.material) {
//				return;
//			}
//			var material : Material3D = pivot.renderer.material;
//			if (!this._materials[material]) {
//				this._materials[material] = new MaterialControl();
//			}
//			var mc : MaterialControl = this._materials[material] as MaterialControl;
//			mc.update(material, this._app);
//			this._layout.addControl(mc.accordion);
//			this._panel.update();
//			this._panel.draw();
		}
				
		public function start() : void {
			
		}
	}
}
