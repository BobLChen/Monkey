package ide.plugins.groups.properties {

	import flash.events.Event;
	import flash.net.FileFilter;
	
	import L3D.core.entities.primitives.Water;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	
	import ide.App;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.Image;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ui.core.utils.FileUtils;

	public class WaterGroup extends PropertiesGroup {

		private var _app : App;
		
		private var _waterSegment : Spinner;
		private var _width : Spinner;
		private var _height : Spinner;
		private var _waterSpeed : Spinner;
		private var _waveDias : Spinner;
		private var _waveHeight : Spinner;
		private var _waterBlendColor : ColorPicker;
		private var _waterTexture : Image;
		private var _waterDisplayment : Image;
		
		
		private var _water : Water;
		
		public function WaterGroup() {
			super("Water");
			accordion.contentHeight = 340;
			layout.maxHeight = 340;
			_width = layout.addControl(new Spinner(3000), "Width:") as Spinner;
			_height = layout.addControl(new Spinner(3000), "Height:") as Spinner;
			_waterSegment = layout.addControl(new Spinner(64, 1, 64, 2, 1), "Segment:") as Spinner;
			_waterSpeed = layout.addControl(new Spinner(0.0025, 0, 10, 5, 0.0002), "WaterSpeed:") as Spinner;
			_waveDias = layout.addControl(new Spinner(20), "WavePower:") as Spinner;
			_waveHeight = layout.addControl(new Spinner(20), "WaveHeight:") as Spinner;
			_waterBlendColor = layout.addControl(new ColorPicker(), "BlendColor:") as ColorPicker;
			
			layout.addControl(new Label("WaterTexture:"));
			_waterTexture = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100)) as Image;
			layout.addControl(new Label("WaterDisplaymentTexture:"));
			_waterDisplayment = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100)) as Image;
			
			_width.addEventListener(ControlEvent.STOP, changeWaterWidth);
			_height.addEventListener(ControlEvent.STOP, changeWaterHeight);
			_waterSegment.addEventListener(ControlEvent.STOP, changeWaterSegment);
			_waterSpeed.addEventListener(ControlEvent.CHANGE, changeWaterSpeed);
			_waveDias.addEventListener(ControlEvent.CHANGE, changeWavePower);
			_waterTexture.addEventListener(ControlEvent.CLICK, changeWaterTexture);
			_waterDisplayment.addEventListener(ControlEvent.CLICK, changeWaterDisplayment);
			_waterBlendColor.addEventListener(ControlEvent.CHANGE, changeBlendColor);
			_waveHeight.addEventListener(ControlEvent.CHANGE, changeWaveHeight);
		}
		
		protected function changeWaveHeight(event:Event) : void {
			_water.waterHeight = _waveHeight.value;		
		}
		
		protected function changeBlendColor(event:Event) : void {
			_water.blendColor = _waterBlendColor.color;
		}
		
		protected function changeWaterDisplayment(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, function(e:Event):void{
				var texture : Texture3D = new Texture3D(file.bitmap);
				texture.upload(_water.scene);
//				_water.normalTexture = texture;
				_waterDisplayment.source = file.bitmap;
			});
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}
		
		protected function changeWaterTexture(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, function(e:Event):void{
				var texture : Texture3D = new Texture3D(file.bitmap, false, 0, Texture3D.TYPE_CUBE);
				texture.upload(_water.scene);
//				_water.cubeTexture = texture;
				_waterTexture.source = file.bitmap;
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
//			_water.segment = _waterSegment.value;			
		}
		
		protected function changeWaterHeight(event:Event) : void {
//			_water.height = _height.value;			
		}
		
		protected function changeWaterWidth(event:Event) : void {
//			_water.width = _width.value;
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if ((app.selection.objects.length == 1) && (app.selection.objects[0] is Water)) {
				this._water = (app.selection.objects[0] as Water);
				updateWater();
				return true;
			}
			return false;
		}
		
		private function updateWater() : void {
			_width.value = _water.width;
			_height.height = _water.height;
			_waterSegment.value = _water.segment;
			_waterSpeed.value = _water.waterSpeed;
			_waveDias.value = _water.waterWave;
			_waterTexture.source = _water.cubeTexture.bitmapData;
			_waterDisplayment.source = _water.normalTexture.bitmapData;
			_waterBlendColor.color = _water.blendColor;
			_waveHeight.value = _water.waterHeight;
		}
		
	}
}
