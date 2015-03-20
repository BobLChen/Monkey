package ide.plugins.groups.properties {

	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.scene.Scene3D;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;
		
	public class GeneralGroup extends PropertiesGroup {

		private var _app 	: App;
		private var visible : CheckBox;
		private var isView 	: CheckBox;
		private var layer 	: Spinner;
		
		public function GeneralGroup() {
			super("GENERAL");
			this.layout.labelWidth = 55;
			this.layout.addHorizontalGroup();
			this.visible = layout.addControl(new CheckBox("", true, Align.LEFT), "Visible:") as CheckBox;
			this.layer   = layout.addControl(new Spinner(0, 0, 0, 2, 1), "Layer:") as Spinner;
			this.layout.endGroup();
			this.accordion.contentHeight = 30;
			this.layer.addEventListener(ControlEvent.CHANGE, changeLayer);
			this.visible.addEventListener(ControlEvent.CHANGE, chaneVisible);
		}
		
		protected function chaneVisible(event:Event) : void {
			if (this._app.selection.main) {
				this._app.selection.main.visible = !this._app.selection.main.visible;
			}
		}
		
		protected function changeLayer(event:Event) : void {
			if (this._app.selection.main) {
				this._app.selection.main.setLayer(layer.value);
			}
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if (!app.selection.main || app.selection.main is Scene3D) {
				return false;
			}
			this.visible.value = app.selection.main.visible;
			this.layer.value   = app.selection.main.layer;
			return true;
		}
		
	}
}
