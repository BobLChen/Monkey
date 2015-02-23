package ide.plugins.groups.shader {
	
	import flash.events.Event;
	import flash.net.FileFilter;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.NormalMapFilter;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	
	import ide.events.SelectionEvent;
	
	import ide.App;
	import ui.core.controls.Image;
	import ui.core.controls.InputText;
	import ui.core.event.ControlEvent;
	import ui.core.utils.FileUtils;

	public class NormalMapFilterOption extends ShaderProperties {
		
		private var _app 	: App;
		private var _shader	: Shader3D;
		private var _filter	: NormalMapFilter;
		private var _image	: Image;
		private var _rmBtn	: InputText;
		
		public function NormalMapFilterOption(filter : NormalMapFilter, shader : Shader3D, app : App) {
			super("NormalMapFilter");
			
			this._app	= app;
			this._shader	= shader;
			this._filter	= filter;
			
			this.accordion.contentHeight = 120;
			this.layout.space = 1;
			this.layout.margins = 2;
			this.layout.labelWidth = 60;
			
			this._image = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100)) as Image;
			this._rmBtn = layout.addControl(new InputText("Remove NormalMapFilter")) as InputText;
			
			this._rmBtn.addEventListener(ControlEvent.CLICK, removeFilter);
			this._image.addEventListener(ControlEvent.CLICK, changeTexture);
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
