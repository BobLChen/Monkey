package ide.plugins.groups.shader {
	
	import flash.events.Event;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.RimFilter;
	
	import ide.App;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.InputText;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class RimFilterOption extends ShaderProperties {
		
		private var _filter : RimFilter;
		private var _app    : App;
		private var _shader : Shader3D;
		
		private var _power 	: Spinner;
		private var _color	: ColorPicker;
		private var _btn		: InputText;
		
		public function RimFilterOption(filter : RimFilter, shader : Shader3D, app : App) {
			super("RimFilter");
			
			this._filter	= filter;
			this._app	= app;
			this._shader	= shader;
			
			this.accordion.contentHeight = 40;
			this.layout.space = 0;
			this.layout.margins = 0;
			this.layout.addHorizontalGroup().maxHeight = 20;
			this.layout.labelWidth = 60;
			this._power = layout.addControl(new Spinner(), "Power") as Spinner;
			this._color = layout.addControl(new ColorPicker(), "Color") as ColorPicker;
			this._power.width = 40;
			this._color.width = 60;
			this.layout.endGroup();
			this._btn = layout.addControl(new InputText("Remove Rim Filter")) as InputText;
			
			this._power.value = filter.power;
			this._color.color = filter.color;
			
			this._btn.addEventListener(ControlEvent.CLICK, onRemoveFilter);
			this._power.addEventListener(ControlEvent.CHANGE, changePower);
			this._color.addEventListener(ControlEvent.CHANGE, changeColor);
		}
		
		protected function onRemoveFilter(event:Event) : void {
			this._shader.removeFilter(_filter);			
		}
		
		protected function changeColor(event:Event) : void {
			this._filter.color = this._color.color;
		}
		
		protected function changePower(event:Event) : void {
			this._filter.power = this._power.value;
		}
		
	}
}
