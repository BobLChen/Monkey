package ide.plugins.groups.properties {

	import flash.display.BitmapData;
	import flash.events.Event;
	
	import ide.App;
	import ide.utils.FileUtils;
	
	import monkey.core.entities.Water3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.textures.BitmapCubeTexture;
	import monkey.core.utils.Texture3DUtils;
	
	import ui.core.controls.ColorPicker;
	import ui.core.controls.Image;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class WaterGroup extends PropertiesGroup {

		private var _app 		: App;
		private var _segment 	: Spinner;
		private var _width 		: Spinner;
		private var _height 	: Spinner;
		private var _speed 		: Spinner;
		private var _wave 		: Spinner;
		private var _waveHeight : Spinner;
		private var _blendColor	: ColorPicker;
		private var _texture 	: Image;
		private var _displayment: Image;
		private var _water 		: Water3D;
		
		public function WaterGroup() {
			super("Water");
			this.accordion.contentHeight = 340;
			this.layout.maxHeight = 340;
			
			this._width 	 = layout.addControl(new Spinner(3000), "Width:")  as Spinner;
			this._height 	 = layout.addControl(new Spinner(3000), "Height:") as Spinner;
			this._segment 	 = layout.addControl(new Spinner(64, 1, 64, 2, 1), 		"Segment:")    as Spinner;
			this._speed 	 = layout.addControl(new Spinner(0,  0, 10, 5, 0.0002), "WaterSpeed:") as Spinner;
			this._wave 		 = layout.addControl(new Spinner(20), 	"WavePower:")  as Spinner;
			this._waveHeight = layout.addControl(new Spinner(20), 	"WaveHeight:") as Spinner;
			this._blendColor = layout.addControl(new ColorPicker(), "BlendColor:") as ColorPicker;
			
			this.layout.addControl(new Label("WaterTexture:"));
			this._texture = layout.addControl(new Image(Texture3DUtils.nullBitmapData, true, 100, 100)) as Image;
			this.layout.addControl(new Label("WaterDisplaymentTexture:"));
			this._displayment = layout.addControl(new Image(Texture3DUtils.nullBitmapData, true, 100, 100)) as Image;
			
			this._width.addEventListener(ControlEvent.STOP, 		changeWaterWidth);
			this._height.addEventListener(ControlEvent.STOP, 		changeWaterHeight);
			this._segment.addEventListener(ControlEvent.STOP, 		changeWaterSegment);
			this._speed.addEventListener(ControlEvent.CHANGE, 		changeWaterSpeed);
			this._wave.addEventListener(ControlEvent.CHANGE, 		changeWavePower);
			this._texture.addEventListener(ControlEvent.CLICK, 		changeWaterTexture);
			this._displayment.addEventListener(ControlEvent.CLICK, 	changeWaterDisplayment);
			this._blendColor.addEventListener(ControlEvent.CHANGE, 	changeBlendColor);
			this._waveHeight.addEventListener(ControlEvent.CHANGE, 	changeWaveHeight);
		}
		
		/**
		 * 水波高度 
		 * @param event
		 * 
		 */		
		private function changeWaveHeight(event:Event) : void {
			_water.waterHeight = _waveHeight.value;		
		}
		
		/**
		 * 闪光色 
		 * @param event
		 * 
		 */		
		private function changeBlendColor(event:Event) : void {
			_water.blendColor.color = _blendColor.color;
		}
		
		/**
		 * 扭曲图 
		 * @param event
		 * 
		 */		
		private function changeWaterDisplayment(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.openForImage(function(bmp : BitmapData):void{
				_displayment.source = bmp;
				_water.userData.normal = file.bytes;
				_water.normalTexture.dispose();
				_water.normalTexture = new Bitmap2DTexture(bmp);
			});
		}
				
		/**
		 * 海水颜色 
		 * @param event
		 * 
		 */		
		private function changeWaterTexture(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.openForImage(function(bmp : BitmapData):void{
				_texture.source = bmp;
				_water.userData.texture = file.bytes;
				_water.texture.dispose();
				_water.texture = new BitmapCubeTexture(bmp);
			});
		}
		
		/**
		 * 海水等级 
		 * @param event
		 * 
		 */		
		private function changeWavePower(event:Event) : void {
			_water.waterWave = _wave.value;
		}
		
		/**
		 * 海水速度 
		 * @param event
		 * 
		 */		
		private function changeWaterSpeed(event:Event) : void {
			_water.waterSpeed = _speed.value;			
		}
		
		/**
		 * 海水段数 
		 * @param event
		 * 
		 */		
		private function changeWaterSegment(event:Event) : void {
			_water.segment = _segment.value;			
		}
		
		/**
		 * 海水高度 
		 * @param event
		 * 
		 */		
		private function changeWaterHeight(event:Event) : void {
			_water.height = _height.value;			
		}
		
		/**
		 * 海水宽度 
		 * @param event
		 * 
		 */		
		private function changeWaterWidth(event:Event) : void {
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
			this._height.value 			= _water.height;
			this._segment.value 		= _water.segment;
			this._speed.value 			= _water.waterSpeed;
			this._wave.value 			= _water.waterWave;
			this._texture.source 		= _water.texture.bitmapData;
			this._displayment.source	= _water.normalTexture.bitmapData;
			this._blendColor.color 		= _water.blendColor.color;
			this._waveHeight.value 		= _water.waterHeight;
		}
				
	}
}
