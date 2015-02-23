package ide.plugins.groups.shader {

	import flash.events.Event;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.VertColor;
	
	import ide.events.SelectionEvent;
	
	import ide.App;
	import ui.core.controls.InputText;
	import ui.core.event.ControlEvent;

	public class PositionColorOption extends ShaderProperties {

		private var _app : App;
		private var _shader : Shader3D;
		private var _closeBtn : InputText;
	
		public function PositionColorOption() {
			super("PositionColorFilter");
			accordion.contentHeight = 20;
			layout.margins = 0;
			layout.space = 0;
			_closeBtn = layout.addControl(new InputText("Remove ColorByPositionFilter")) as InputText;
			_closeBtn.addEventListener(ControlEvent.CLICK, removeFilter);
		}
		
		protected function removeFilter(event:Event) : void {
			var filter : VertColor = _shader.getFilterByClass(VertColor) as VertColor;
			_shader.removeFilter(filter);
			_app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
		} 
		
		override public function update(shader : Shader3D, app : App) : Boolean {
			_app = app;
			_shader = shader;
			if (_shader.getFilterByClass(VertColor) == null) {
				return false;
			}
			return true;
		}

	}
}
