package ide.plugins.groups.properties {

	import flash.display.BitmapData;
	import flash.events.Event;
	
	import ide.App;
	import ide.utils.FileUtils;
	
	import monkey.core.entities.SkyBox;
	import monkey.core.utils.Texture3DUtils;
	
	import ui.core.controls.Image;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class SkyboxGroup extends PropertiesGroup {

		private var _app 	 : App;
		private var _sky 	 : SkyBox;
		private var _size 	 : Spinner;
		private var _ratio 	 : Spinner;
		private var _image : Image;
		
		public function SkyboxGroup() {
			super("Skybox");
			this.accordion.contentHeight = 160;
			this.layout.maxHeight = 160;
			this._size  = layout.addControl(new Spinner(), "Size:") as Spinner;
			this._ratio = layout.addControl(new Spinner(), "Ratio:") as Spinner;
			this.layout.addControl(new Label("Texture:"));
			this._image = layout.addControl(new Image(Texture3DUtils.nullBitmapData, true, 100, 100)) as Image;
			this._size.addEventListener(ControlEvent.STOP, changeSize);
			this._ratio.addEventListener(ControlEvent.CHANGE, changeRatio);
			this._image.addEventListener(ControlEvent.CLICK, changeImage);
		}
		
		private function changeImage(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.openForImage(function(bmp:BitmapData):void{
				_sky.bitmapData = bmp;
				_image.source = bmp;
				_sky.userData.texture = file.bytes;
			});
		}
		
		private function changeRatio(event:Event) : void {
			this._sky.scaleRatio = _ratio.value;			
		}
		
		private function changeSize(event:Event) : void {
			this._sky.size = _size.value;			
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if (app.selection.main is SkyBox) {
				this._sky = app.selection.main as SkyBox;
				this.updateSky();
				return true;
			}
			return false;
		}
		
		private function updateSky() : void {
			this._ratio.value  = this._sky.scaleRatio;
			this._size.value   = this._sky.size;
			this._image.source = this._sky.bitmapData;
		}
		
	}
}
