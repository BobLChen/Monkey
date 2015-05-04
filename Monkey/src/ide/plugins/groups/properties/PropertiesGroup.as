package ide.plugins.groups.properties {

	import ide.App;
	import ui.core.container.Accordion;
	import ui.core.controls.Layout;

	public class PropertiesGroup {
		
		public var accordion : Accordion;
		public var layout : Layout;

		public function PropertiesGroup(name : String, scroll : Boolean = false) {
			this.layout = new Layout(scroll);
			this.layout.labelWidth = 90;
			this.accordion = new Accordion(name);
			this.accordion.addControl(this.layout);
		}
		
		public function update(app : App) : Boolean {
			return true;
		}

	}
}
