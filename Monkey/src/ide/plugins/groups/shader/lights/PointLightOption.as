package ide.plugins.groups.shader.lights {

	import flash.events.Event;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.light.PointLightFilter;
	
	import ide.events.SelectionEvent;
	import ide.plugins.groups.shader.ShaderProperties;
	
	import ide.App;
	import ui.core.controls.InputText;
	import ui.core.event.ControlEvent;

	public class PointLightOption extends ShaderProperties {

		private var _removeBtn : InputText;
		private var _filter : PointLightFilter;
		private var _shader : Shader3D;
		private var _app : App;

		public function PointLightOption(filter : PointLightFilter, shader : Shader3D, app : App) {
			super("PointLightFilter");
			
			accordion.contentHeight = 22;
			layout.margins = 0;
			layout.space = 0;
			_removeBtn = layout.addControl(new InputText("RemoveLightFilter")) as InputText;
			_removeBtn.textField.selectable = false;
			
			
			_app = app;
			_shader = shader;
			_filter = filter;
			
			_removeBtn.addEventListener(ControlEvent.CLICK, removeFilter);
			
		}
		
		protected function removeFilter(event:Event) : void {
			_shader.removeFilter(_filter);
			_app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
		}
	}
}
