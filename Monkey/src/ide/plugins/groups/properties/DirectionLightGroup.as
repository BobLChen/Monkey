package ide.plugins.groups.properties {
		
	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.light.DirectionalLight;
	
	import ui.core.controls.ColorPicker;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	
	/**
	 * 平行光 
	 * @author Neil
	 * 
	 */	
	public class DirectionLightGroup extends PropertiesGroup {
		
		private var app : App;
		
		private var _lightColor 	: ColorPicker;
		private var _ambientColor 	: ColorPicker;
		private var _specularColor 	: ColorPicker;
		private var _intensity		: Spinner;
		private var _power 			: Spinner;
		private var _light 			: DirectionalLight;
		
		public function DirectionLightGroup() {
			super("DirectionLight");
			this.accordion.contentHeight = 120;
			this.layout.margins = 5;
			this.layout.labelWidth = 100;
			this._lightColor 	= layout.addControl(new ColorPicker(), "LightColor:") as ColorPicker;
			this._ambientColor 	= layout.addControl(new ColorPicker(), "Ambient:") as ColorPicker;
			this._specularColor = layout.addControl(new ColorPicker(), "Specular:") as ColorPicker;
			this._power 		= layout.addControl(new Spinner(), "Power:") as Spinner;
			this._intensity 	= layout.addControl(new Spinner(), "Intensity:") as Spinner;
			
			this._lightColor.addEventListener(ControlEvent.CHANGE, change);
			this._ambientColor.addEventListener(ControlEvent.CHANGE, change);
			this._specularColor.addEventListener(ControlEvent.CHANGE, change);
			this._power.addEventListener(ControlEvent.CHANGE, change);
		}
		
		private function change(event:Event) : void {
			this._light.color.color    = _lightColor.color;
			this._light.ambient.color  = _ambientColor.color;
			this._light.specular.color = _specularColor.color;
			this._light.power 	 	   = _power.value;
		}
		
		override public function update(app : App) : Boolean {
			if (app.selection.main is DirectionalLight) {
				this._light = app.selection.main as DirectionalLight;
				this._lightColor.color 	  = _light.color.color;
				this._ambientColor.color  = _light.ambient.color;
				this._specularColor.color = _light.specular.color;
				this._power.value 		  = _light.power;
				return true;
			}
			return false;
		}
		
	}
}
