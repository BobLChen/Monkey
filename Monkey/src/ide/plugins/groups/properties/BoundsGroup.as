package ide.plugins.groups.properties {
	import ide.App;
	
	import ui.core.controls.Spinner;

	public class BoundsGroup extends PropertiesGroup {
		
		private var _lenX : Spinner;
		private var _lenY : Spinner;
		private var _lenZ : Spinner;
		
		private var app : App;
		
		public function BoundsGroup() {
			super("Boundings");
			this.accordion.contentHeight = 30;
			this.layout.labelWidth = 20;
			this.layout.addHorizontalGroup();
			this._lenX = layout.addControl(new Spinner(), "X:") as Spinner;
			this._lenY = layout.addControl(new Spinner(), "Y:") as Spinner;
			this._lenZ = layout.addControl(new Spinner(), "Z:") as Spinner;
		}
		
		override public function update(app : App) : Boolean {
			this._lenX.value = app.selection.bounds.x;
			this._lenY.value = app.selection.bounds.y;
			this._lenZ.value = app.selection.bounds.z;
			return true;
		}
		
	}
}
