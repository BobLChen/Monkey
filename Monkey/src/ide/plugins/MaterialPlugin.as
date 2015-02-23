package ide.plugins {

	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import L3D.core.base.Pivot3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.scene.Scene3D;
	
	import ide.Studio;
	import ide.events.SelectionEvent;
	import ide.panel.MaterialControl;
	
	import ide.App;
	import ui.core.container.Panel;
	import ui.core.controls.Layout;
	import ui.core.controls.Separator;
	import ui.core.controls.TabControl;
	import ui.core.interfaces.IPlugin;

	public class MaterialPlugin implements IPlugin {
		
		private var _app : App;
		private var _panel : Panel;
		private var _layout : Layout;
		private var _materials : Dictionary;

		public function MaterialPlugin() {
			this._materials = new Dictionary(true);
			this._panel = new Panel("MATERIAL");
			this._layout = new Layout();
			this._panel.addControl(this._layout);
			this._panel.minWidth = 200;
		}

		public function init(app : App) : void {
			this._app = app;

			var tab : TabControl = this._app.ui.getPanel(Studio.MIDDLE_TAB) as TabControl;
			tab.addPanel(this._panel);
						
			this._app.addEventListener(SelectionEvent.CHANGE, changeMaterialEvent);
			this._app.addEventListener(SelectionEvent.CHANGE_MATERIAL, changeMaterialEvent);
		}
		
		protected function changeMaterialEvent(event:Event) : void {
			_layout.removeAllControls();
			if (this._app.selection.objects.length == 0 || this._app.selection.objects[0] is Scene3D) {
				return;
			}
			var pivot : Pivot3D = this._app.selection.main;
			if ((pivot is Mesh3D) == false) {
				return;
			}
			var mesh : Mesh3D = pivot as Mesh3D;
			
			if (this._materials[mesh.material.shader] == undefined) {
				this._materials[mesh.material.shader] = new MaterialControl();
			}
			var mc : MaterialControl = this._materials[mesh.material.shader] as MaterialControl;
			_layout.addControl(mc.accordion);
			_layout.addControl(new Separator(Separator.HORIZONTAL));
			mc.updateShader(mesh.material.shader, _app);
			this._panel.update();
			this._panel.draw();
		}
		
		public function start() : void {
			
		}
	}
}
