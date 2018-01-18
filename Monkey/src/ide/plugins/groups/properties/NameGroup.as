package ide.plugins.groups.properties {

	import ui.core.controls.InputText;
	import ui.core.controls.Layout;
	import ui.core.type.Align;

	public class NameGroup extends Layout {

		public var names : InputText;

		public function NameGroup() {
			super(false);
			addHorizontalGroup();
			margins = 3;
			labelWidth = 65;
			labelAlign = Align.RIGHT;
			this.names = addControl(new InputText(), "Name:") as InputText;
			this.names.enabled = false;
			this.names.minWidth = 40;
			endGroup();
			minWidth = 40;
			minHeight = 34;
			maxHeight = 34;
		}
	}
}
