package ide.plugins.groups.properties {

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.FileFilter;
	
	import L3D.core.entities.primitives.SkyBox;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	
	import ide.App;
	import ui.core.controls.Image;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ui.core.utils.FileUtils;

	public class SkyboxGroup extends PropertiesGroup {

		private var _app : App;
		private var _sky : SkyBox;
		
		private var _size : Spinner;
		private var _ratio : Spinner;
		private var _texture : Image;
		
		public function SkyboxGroup() {
			super("Skybox");
			accordion.contentHeight = 160;
			layout.maxHeight = 160;
			_size = layout.addControl(new Spinner(), "Size:") as Spinner;
			_ratio = layout.addControl(new Spinner(), "Ratio:") as Spinner;
			layout.addControl(new Label("Texture:"));
			_texture = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100)) as Image;
			
			_size.addEventListener(ControlEvent.STOP, changeSize);
			_ratio.addEventListener(ControlEvent.CHANGE, changeRatio);
			_texture.addEventListener(ControlEvent.CLICK, changeImage);
		}
		
		protected function changeImage(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, function(e:Event):void{
				var texture : Texture3D = new Texture3D(file.bitmap, false, 0, Texture3D.TYPE_CUBE);
				texture.upload(_sky.scene);
//				_sky.request = file.bitmap.bitmapData;
				_texture.source = file.bitmap;
			});
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}
		
		protected function changeRatio(event:Event) : void {
			this._sky.scaleRatio = _ratio.value;			
		}
		
		protected function changeSize(event:Event) : void {
//			this._sky.size = _size.value;			
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if ((app.selection.objects.length == 1) && (app.selection.objects[0] is SkyBox)) {
				this._sky = (app.selection.objects[0] as SkyBox);
				updateSky();
				return true;
			}
			return false;
		}
		
		private function updateSky() : void {
			_ratio.value = this._sky.scaleRatio;
			_size.value = this._sky.size;
			if (this._sky.request is BitmapData) {
				this._texture.source = this._sky.request as BitmapData;
			}
		}
				
	}
}
