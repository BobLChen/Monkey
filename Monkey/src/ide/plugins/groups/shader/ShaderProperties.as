package ide.plugins.groups.shader {

	import L3D.core.shader.Shader3D;
	
	import ide.App;
	import ui.core.container.Accordion;
	import ui.core.controls.Layout;

	public class ShaderProperties {

		public var accordion : Accordion;
		public var layout : Layout;

		public function ShaderProperties(name : String, scroll : Boolean = false) {
			this.layout = new Layout(scroll);
			this.layout.labelWidth = 90;
			this.accordion = new Accordion(name);
			this.accordion.addControl(this.layout);
			this.accordion.open = false;
		}
		
		public function update(shader : Shader3D, app : App) : Boolean {
			return true;
		}
		
	}
}
