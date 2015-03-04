package ide.plugins.groups.properties {

	import flash.events.Event;
	import flash.net.FileFilter;
	
	import ide.App;
	
	import monkey.core.entities.Water3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.textures.BitmapCubeTexture;
	import monkey.core.utils.Device3D;
	
	import ui.core.controls.ColorPicker;
	import ui.core.controls.Image;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ui.core.utils.FileUtils;

	public class WaterGroup extends PropertiesGroup {

		private var _app 				: App;
		private var _waterSegment 		: Spinner;
		private var _width 				: Spinner;
		private var _height 			: Spinner;
		private var _waterSpeed 		: Spinner;
		private var _waveDias 			: Spinner;
		private var _waveHeight 		: Spinner;
		private var _waterBlendColor	: ColorPicker;
		private var _waterTexture 		: Image;
		private var _waterDisplayment 	: Image;
		private var _water 				: Water3D;
		
		public function WaterGroup() {
			super("Water");
			this.accordion.contentHeight = 340;
			this.layout.maxHeight = 340;
			
			this._width 		= layout.addControl(new Spinner(3000), "Width:") as Spinner;
			this._height 		= layout.addControl(new Spinner(3000), "Height:") as Spinner;
			this._waterSegment 	= layout.addControl(new Spinner(64, 1, 64, 2, 1), "Segment:") as Spinner;
			this._waterSpeed 	= layout.addControl(new Spinner(0.0025, 0, 10, 5, 0.0002), "WaterSpeed:") as Spinner;
			this._waveDias 		= layout.addControl(new Spinner(20), "WavePower:") as Spinner;
			this._waveHeight 	= layout.addControl(new Spinner(20), "WaveHeight:") as Spinner;
			this._waterBlendColor = layout.addControl(new ColorPicker(), "BlendColor:") as ColorPicker;
			
			this.layout.addControl(new Label("WaterTexture:"));
			this._waterTexture = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100)) as Image;
			this.layout.addControl(new Label("WaterDisplaymentTexture:"));
			this._waterDisplayment = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100)) as Image;
			
			this._width.addEventListener(ControlEvent.STOP, 			changeWaterWidth);
			this._height.addEventListener(ControlEvent.STOP, 			changeWaterHeight);
			this._waterSegment.addEventListener(ControlEvent.STOP, 		changeWaterSegment);
			this._waterSpeed.addEventListener(ControlEvent.CHANGE, 		changeWaterSpeed);
			this._waveDias.addEventListener(ControlEvent.CHANGE, 		changeWavePower);
			this._waterTexture.addEventListener(ControlEvent.CLICK, 	changeWaterTexture);
			this._waterDisplayment.addEventListener(ControlEvent.CLICK, changeWaterDisplayment);
			this._waterBlendColor.addEventListener(ControlEvent.CHANGE, changeBlendColor);
			this._waveHeight.addEventListener(ControlEvent.CHANGE, 		changeWaveHeight);
		}
		
		protected function changeWaveHeight(event:Event) : void {
			_water.waterHeight = _waveHeight.value;		
		}
		
		protected function changeBlendColor(event:Event) : void {
			_water.blendColor.color = _waterBlendColor.color;
		}
		
		protected function changeWaterDisplayment(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, function(e:Event):void{
				_waterDisplayment.source = file.bitmap;
				_water.normalTexture.dispose(true);
				_water.normalTexture = new Bitmap2DTexture(file.bitmap.bitmapData);
			});
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}
		
		protected function changeWaterTexture(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, function(e:Event):void{
				_waterTexture.source = file.bitmap;
				_water.texture.dispose(true);
				_water.texture = new BitmapCubeTexture(file.bitmap.bitmapData);
			});
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}
		
		protected function changeWavePower(event:Event) : void {
			_water.waterWave = _waveDias.value;
		}
		
		protected function changeWaterSpeed(event:Event) : void {
			_water.waterSpeed = _waterSpeed.value;			
		}
		
		protected function changeWaterSegment(event:Event) : void {
			_water.segment = _waterSegment.value;			
		}
		
		protected function changeWaterHeight(event:Event) : void {
			_water.height = _height.value;			
		}
		
		protected function changeWaterWidth(event:Event) : void {
			_water.width = _width.value;
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if (app.selection.main is Water3D) {
				this._water = app.selection.main as Water3D;
				this.updateWater();
				return true;
			}
			return false;
		}
				
		private function updateWater() : void {
			this._width.value 			= _water.width;
			this._height.height 		= _water.height;
			this._waterSegment.value 	= _water.segment;
			this._waterSpeed.value 		= _water.waterSpeed;
			this._waveDias.value 		= _water.waterWave;
			this._waterTexture.source 	= _water.texture.bitmapData;
			this._waterDisplayment.source= _water.normalTexture.bitmapData;
			this._waterBlendColor.color = _water.blendColor.color;
			this._waveHeight.value 		= _water.waterHeight;
		}
		
	}
}
