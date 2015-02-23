package ide.plugins.groups.shader {
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.LightMapfilter;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	import L3D.utils.Texture3DUtils;
	
	import ide.events.SelectionEvent;
	
	import ide.App;
	import ui.core.controls.ComboBox;
	import ui.core.controls.Image;
	import ui.core.controls.InputText;
	import ui.core.event.ControlEvent;
	import ui.core.utils.FileUtils;

	public class LightmapFilterOption extends ShaderProperties {
		
		private var _app    : App;
		private var _shader : Shader3D;
		private var _filter : LightMapfilter;
		private var _image  : Image;
		private var _mode   : ComboBox;
		private var _removeBtn : InputText;
		
		public function LightmapFilterOption(filter : LightMapfilter, shader : Shader3D, app : App) {
			super("LightmapFilter");
			this.accordion.contentHeight = 250;
			this.layout.space = 1;
			this.layout.margins = 2;
			this.layout.labelWidth = 60;
			
			this._shader= shader;
			this._app   = app;
			this._filter= filter;
			
			this._image = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100), "Texture:") as Image;
			this._mode  = layout.addControl(new ComboBox([LightMapfilter.ADD, LightMapfilter.MUL, LightMapfilter.SUB], [LightMapfilter.ADD, LightMapfilter.MUL, LightMapfilter.SUB]), "Mode") as ComboBox;
			this._removeBtn = layout.addControl(new InputText("Remove LigmapFilter")) as InputText;
			
			this._removeBtn.addEventListener(ControlEvent.CLICK, removeFilter);
			this._image.addEventListener(MouseEvent.CLICK, changeTexture);
			this._mode.addEventListener(ControlEvent.CHANGE, changeMode);
			
			this._image.source = filter.texture.bitmapData;
			this._mode.selectedItem = filter.mode;
			
		}
		
		protected function changeMode(event:Event) : void {
			this._filter.mode = _mode.selectedItem;
			this._shader.build();
		}
		
		protected function changeTexture(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, changeImageDone);
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}
		
		protected function changeImageDone(event:Event) : void {
			var file : FileUtils = (event.target as FileUtils);
			_filter.texture.dispose();
			_filter.texture = new Texture3D(file.bitmap.bitmapData);
			_filter.texture.upload(_shader.scene);
			_filter.texture.name = file.name;
			_image.source = file.bitmap;			
		}
		
		protected function removeFilter(event:Event) : void {
			_shader.removeFilter(_filter);
			_app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
		}
		
	}
}
