package ide.plugins.groups.properties {

	import ide.App;
	import ide.events.SceneEvent;
	
	import monkey.core.base.Object3D;
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
			this.layout.endGroup();
			this.layout.addEventListener(ControlEvent.CHANGE, this.changeControlEvent);
			this.layout.addEventListener(ControlEvent.CLICK, this.changeControlEvent);
			this.accordion.contentHeight = 30;
		}
		
		private function changeControlEvent(e : ControlEvent) : void {
			for each (var pivot : Object3D in this._app.selection.objects) {
				if (pivot is Scene3D) {
					continue;
				}
				pivot.visible = this.visible.value;
			}
			this._app.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
		}

		override public function update(app : App) : Boolean {
			this._app = app;
			if (!app.selection.main || app.selection.main is Scene3D) {
				return false;
			}
			this.visible.value = app.selection.main.visible;
			return true;
		}
		
	}
}
