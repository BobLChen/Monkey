package ide.plugins.groups.properties {

	import flash.events.Event;
	
	import L3D.core.light.PointLight;
	
	import ide.App;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class PointLightGroup extends PropertiesGroup {
		
		private var app : App;

		private var _lightColor : ColorPicker;
		private var _ambientColor : ColorPicker;
		private var _radius : Spinner;
		private var _multiplier : Spinner;
				
		private var _light : PointLight;
		
		public function PointLightGroup() {
			super("PointLight");
			accordion.contentHeight = 100;
			layout.margins = 5;
			layout.labelWidth = 40;
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.labelWidth = 100;
			_lightColor = layout.addControl(new ColorPicker(), "LightColor:") as ColorPicker;
			_ambientColor = layout.addControl(new ColorPicker(), "Ambient:") as ColorPicker;
			_radius = layout.addControl(new Spinner(), "Radius:") as Spinner;
			_multiplier = layout.addControl(new Spinner(), "Multiplier:") as Spinner;
			
			_lightColor.addEventListener(ControlEvent.CHANGE, change);
			_ambientColor.addEventListener(ControlEvent.CHANGE, change);
			_radius.addEventListener(ControlEvent.CHANGE, change);
			_multiplier.addEventListener(ControlEvent.CHANGE, change);
		}

		protected function change(event : Event) : void {
			_light.color = _lightColor.color;
			_light.ambient = _ambientColor.color;
			_light.radius = _radius.value;
			_light.multiplier = _multiplier.value;
		}

		override public function update(app : App) : Boolean {
			if (app.selection.main is PointLight) {
				_light = app.selection.main as PointLight;
				_lightColor.color = _light.color;
				_ambientColor.color = _light.ambient;
				_radius.value = _light.radius;
				_multiplier.value = _light.multiplier;
				return true;
			}
			return false;
		}

	}
}
