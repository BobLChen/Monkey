package ide.plugins.groups.properties {
	
	
	import flash.events.Event;
	
	import L3D.core.light.DirectionalLight;
	
	import ide.App;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class DirectionLightGroup extends PropertiesGroup {
		
		private var app : App;
		
		private var _lightColor : ColorPicker;
		private var _ambientColor : ColorPicker;
		private var _specularColor : ColorPicker;
		private var _power : Spinner;
		
		private var _light : DirectionalLight;
				
		public function DirectionLightGroup() {
			super("DirectionLight");
			accordion.contentHeight = 100;
			layout.margins = 5;
			layout.labelWidth = 40;
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.labelWidth = 100;
			_lightColor = layout.addControl(new ColorPicker(), "LightColor:") as ColorPicker;
			_ambientColor = layout.addControl(new ColorPicker(), "Ambient:") as ColorPicker;
			_specularColor = layout.addControl(new ColorPicker(), "Specular:") as ColorPicker;
			_power = layout.addControl(new Spinner(), "Power:") as Spinner;
			
			_lightColor.addEventListener(ControlEvent.CHANGE, change);
			_ambientColor.addEventListener(ControlEvent.CHANGE, change);
			_specularColor.addEventListener(ControlEvent.CHANGE, change);
			_power.addEventListener(ControlEvent.CHANGE, change);
		}
		
		protected function change(event:Event) : void {
			_light.color = _lightColor.color;
			_light.ambient = _ambientColor.color;
			_light.specular = _specularColor.color;
			_light.power = _power.value;
		}
		
		override public function update(app : App) : Boolean {
			if (app.selection.main is DirectionalLight) {
				_light = app.selection.main as DirectionalLight;
				_lightColor.color = _light.color;
				_ambientColor.color = _light.ambient;
				_specularColor.color = _light.specular;
				_power.value = _light.power;
				return true;
			}
			return false;
		}
		
	}
}
