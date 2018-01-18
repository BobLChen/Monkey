package ide.plugins.groups.properties {

	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.light.PointLight;
	
	import ui.core.controls.ColorPicker;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class PointLightGroup extends PropertiesGroup {
	
		private var app : App;

		private var _lightColor 	: ColorPicker;
		private var _ambientColor 	: ColorPicker;
		private var _radius 		: Spinner;
		private var _intensity 		: Spinner;
		private var _light 			: PointLight;
		
		public function PointLightGroup() {
			super("PointLight");
			this.accordion.contentHeight = 100;
			this.layout.margins = 5;
			this.layout.labelWidth = 100;
			
			this._lightColor 	= layout.addControl(new ColorPicker(), 	"LightColor:") 	as ColorPicker;
			this._ambientColor 	= layout.addControl(new ColorPicker(), 	"Ambient:")		as ColorPicker;
			this._radius 		= layout.addControl(new Spinner(), 		"Radius:") 		as Spinner;
			this._intensity 	= layout.addControl(new Spinner(), 		"Intensity:") 	as Spinner;

			this._lightColor.addEventListener(ControlEvent.CHANGE, change);
			this._ambientColor.addEventListener(ControlEvent.CHANGE, change);
			this._radius.addEventListener(ControlEvent.CHANGE, change);
			this._intensity.addEventListener(ControlEvent.CHANGE, change);
		}

		private function change(event : Event) : void {
			this._light.color.color 	= _lightColor.color;
			this._light.ambient.color 	= _ambientColor.color;
			this._light.radius 			= _radius.value;
			this._light.intensity   	= _intensity.value;
		}
		
		override public function update(app : App) : Boolean {
			if (app.selection.main is PointLight) {
				this._light = app.selection.main as PointLight;
				this._lightColor.color 	 = _light.color.color;
				this._ambientColor.color = _light.ambient.color;
				this._radius.value 		 = _light.radius;
				this._intensity.value 	 = _light.intensity;
				return true;
			}
			return false;
		}

	}
}
