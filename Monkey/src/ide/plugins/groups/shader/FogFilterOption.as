package ide.plugins.groups.shader {

	import flash.events.Event;

	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.FogFilter;

	import ide.App;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.InputText;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class FogFilterOption extends ShaderProperties {

		private var _fogFilter : FogFilter;
		private var _distance : Spinner;
		private var _color : ColorPicker;
		private var _removeBtn : InputText;
		private var _shader : Shader3D;
		private var _app : App;


		public function FogFilterOption(filter : FogFilter, shader : Shader3D, app : App) {
			super("FogFilter");
			accordion.contentHeight = 40;
			layout.space = 0;
			layout.margins = 0;
			layout.addHorizontalGroup().maxHeight = 20;
			layout.labelWidth = 60;
			_distance = layout.addControl(new Spinner(), "Distance:") as Spinner;
			_color = layout.addControl(new ColorPicker(), "FogColor:") as ColorPicker;
			_distance.width = 40;
			_color.width = 60;
			layout.endGroup();
			_removeBtn = layout.addControl(new InputText("Remove FogFilter")) as InputText;
			_removeBtn.textField.selectable = false;
			_removeBtn.addEventListener(ControlEvent.CLICK, removeFilter);

			_distance.addEventListener(ControlEvent.CHANGE, changeDistance);
			_color.addEventListener(ControlEvent.CHANGE, changeFogColor);
			
			
			_shader = shader;
			_app = app;
			_fogFilter = filter;
			_color.color = _fogFilter.fogColor;
			_distance.value = _fogFilter.fogDistance;
		}

		protected function changeFogColor(event : Event) : void {
			_fogFilter.fogColor = _color.color;
		}

		protected function changeDistance(event : Event) : void {
			_fogFilter.fogDistance = _distance.value;
		}

		protected function removeFilter(event : Event) : void {
			this._shader.removeFilter(_fogFilter);
		}

		override public function update(shader : Shader3D, app : App) : Boolean {
			_shader = shader;
			_app = app;
			_fogFilter = _shader.getFilterByClass(FogFilter) as FogFilter;

			if (_fogFilter == null) {
				return false;
			}
			_color.color = _fogFilter.fogColor;
			_distance.value = _fogFilter.fogDistance;

			return true;
		}


	}
}
