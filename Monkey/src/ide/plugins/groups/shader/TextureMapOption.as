package ide.plugins.groups.shader {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.ColorFilter;
	import L3D.core.shader.filters.TextureMapFilter;
	import L3D.core.shader.filters.base.Filter3D;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	
	import ide.events.SelectionEvent;
	
	import ide.App;
	import ui.core.controls.ComboBox;
	import ui.core.controls.Image;
	import ui.core.controls.InputText;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ui.core.utils.FileUtils;

	public class TextureMapOption extends ShaderProperties {

		private var _shader : Shader3D;
		private var _textureMapFilter : TextureMapFilter;

		private var _textureImage : Image;
		private var _mipCombox : ComboBox;
		private var _filterCombox : ComboBox;
		private var _wrapCombox : ComboBox;
		private var _modeCombox : ComboBox;
		private var _repeatX : Spinner;
		private var _repeatY : Spinner;
		private var _offsetX : Spinner;
		private var _offsetY : Spinner;
		private var _easeX : Spinner;
		private var _easeY : Spinner;
		private var _alpha : Spinner;
		private var _mask : Spinner;
		private var _removeBtn : InputText;
		private var _app : App;

		public function TextureMapOption(filter : TextureMapFilter, shader : Shader3D, app : App) {
			super("TextureMapFilter");
			accordion.contentHeight = 300;
			layout.space = 1;
			layout.margins = 2;
			layout.labelWidth = 60;
			this._textureImage = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100), "Texture:") as Image;
			layout.addVerticalGroup().maxHeight = 60;
			layout.space = 0;
			layout.margins = 2;
			layout.addHorizontalGroup().height = 18;
			this._alpha = layout.addControl(new Spinner(1, 0, 0, 2, 0.001), "Alpha:") as Spinner;
			this._mask = layout.addControl(new Spinner(0, 0, 0, 2, 0.001), "Mask:") as Spinner;
			layout.endGroup();
			
			layout.addHorizontalGroup().height = 18;
			this._offsetX = layout.addControl(new Spinner(0), "OffsetX:") as Spinner;
			this._offsetY = layout.addControl(new Spinner(0), "OffsetY:") as Spinner;
			layout.endGroup();
			
			layout.addHorizontalGroup().height = 18;
			this._repeatX = layout.addControl(new Spinner(1), "RepeatX:") as Spinner;
			this._repeatY = layout.addControl(new Spinner(1), "RepeatY:") as Spinner;
			layout.endGroup();
			
			layout.addHorizontalGroup().height = 18;
			this._easeX = layout.addControl(new Spinner(), "EaseX:") as Spinner;
			this._easeY = layout.addControl(new Spinner(), "EaseY:") as Spinner;
			layout.endGroup();
			
			layout.endGroup();
			layout.addHorizontalGroup();
			layout.labelWidth = 30;
			this._mipCombox = layout.addControl(new ComboBox([Texture3D.MIP_LINEAR, Texture3D.MIP_NEAREST, Texture3D.MIP_NONE], [Texture3D.MIP_LINEAR, Texture3D.MIP_NEAREST, Texture3D.MIP_NONE]), "Mip") as
				ComboBox;
			this._filterCombox = layout.addControl(new ComboBox([Texture3D.FILTER_LINEAR, Texture3D.FILTER_NEAREST], [Texture3D.FILTER_LINEAR, Texture3D.FILTER_NEAREST]), "Filter") as ComboBox;
			this._wrapCombox = layout.addControl(new ComboBox([Texture3D.WRAP_CLAMP, Texture3D.WRAP_REPEAT], [Texture3D.WRAP_CLAMP, Texture3D.WRAP_REPEAT]), "Wrap") as ComboBox;
			this._modeCombox = layout.addControl(new ComboBox([TextureMapFilter.ADD, TextureMapFilter.MULTIPLY, TextureMapFilter.NONE], [TextureMapFilter.ADD, TextureMapFilter.MULTIPLY, TextureMapFilter.NONE]), "Mode") as ComboBox;
			layout.endGroup();
			this._removeBtn = layout.addControl(new InputText("Remove TextureMapFilter")) as InputText;
			this._removeBtn.textField.selectable = false;
			
			this._removeBtn.addEventListener(ControlEvent.CLICK, removeTextureMapfilter);
			this._textureImage.addEventListener(MouseEvent.CLICK, changeTexture);
			this._alpha.addEventListener(ControlEvent.CHANGE, changeAlpha);
			this._mask.addEventListener(ControlEvent.CHANGE, changeMask);
			this._offsetX.addEventListener(ControlEvent.CHANGE, changeOffset);
			this._offsetY.addEventListener(ControlEvent.CHANGE, changeOffset);
			this._repeatX.addEventListener(ControlEvent.CHANGE, changeRepeat);
			this._repeatY.addEventListener(ControlEvent.CHANGE, changeRepeat);
			this._modeCombox.addEventListener(ControlEvent.CHANGE, changeModel);
			this._easeX.addEventListener(ControlEvent.CHANGE, changeEase);
			this._easeY.addEventListener(ControlEvent.CHANGE, changeEase);
						
			_app = app;
			_shader = shader;
			_textureMapFilter = filter;
			_offsetX.value = _textureMapFilter.offsetX;
			_offsetY.value = _textureMapFilter.offsetY;
			_repeatX.value = _textureMapFilter.repeatX;
			_repeatY.value = _textureMapFilter.repeatY;
			_alpha.value = _textureMapFilter.alpha;
			_mask.value = _textureMapFilter.mask;
			_textureImage.source = _textureMapFilter.texture.bitmapData;
			_mipCombox.selectedItem = _textureMapFilter.texture.mipMode;
			_filterCombox.selectedItem = _textureMapFilter.texture.filterMode;
			_wrapCombox.selectedItem = _textureMapFilter.texture.wrapMode;
			_modeCombox.selectedItem = _textureMapFilter.mode;
			_easeX.value = _textureMapFilter.ease.x;
			_easeY.value = _textureMapFilter.ease.y;
		}
		
		protected function changeEase(event:Event) : void {
			_textureMapFilter.ease.x = _easeX.value;
			_textureMapFilter.ease.y = _easeY.value;
		}
		
		protected function changeModel(event:Event) : void {
			_textureMapFilter.mode = _modeCombox.selectedItem;
			_shader.build();
		}
		
		protected function removeTextureMapfilter(event : Event) : void {
			_shader.removeFilter(_textureMapFilter);
			var found : Boolean = false;
			for each (var filter : Filter3D in _shader.filters) {
				if (filter is TextureMapFilter) {
					found = true;
					break;
				}
			}
			if (!found) {
				if (_shader.getFilterByClass(ColorFilter) == null) {
					_shader.addFilter(new ColorFilter(0xc8c8c8));
				}	
			}
			_app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
		}
		
		protected function changeRepeat(event : Event) : void {
			_textureMapFilter.repeatX = this._repeatX.value;
			_textureMapFilter.repeatY = this._repeatY.value;
		}

		protected function changeOffset(event : Event) : void {
			_textureMapFilter.offsetX = this._offsetX.value;
			_textureMapFilter.offsetY = this._offsetY.value;
		}

		protected function changeMask(event : Event) : void {
			_textureMapFilter.mask = this._mask.value;
		}

		protected function changeAlpha(event : Event) : void {
			_textureMapFilter.alpha = this._alpha.value;
		}

		protected function changeTexture(event : Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, changeImageDone);
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}

		protected function changeImageDone(event : Event) : void {
			var file : FileUtils = (event.target as FileUtils);
			_textureMapFilter.texture.dispose();
			_textureMapFilter.texture = new Texture3D(file.bitmap.bitmapData);
			_textureMapFilter.texture.wrapMode = this._wrapCombox.selectedValue as String;
			_textureMapFilter.texture.filterMode = this._filterCombox.selectedValue as String;
			_textureMapFilter.texture.mipMode = this._mipCombox.selectedValue as String;
			_textureMapFilter.texture.upload(_shader.scene);
			_textureMapFilter.texture.name = file.name;
			_textureImage.source = file.bitmap;
		}
				
		override public function update(shader : Shader3D, app : App) : Boolean {
			if (shader.getFilterByClass(TextureMapFilter) == null)
				return false;
			_app = app;
			_shader = shader;
			_textureMapFilter = shader.getFilterByClass(TextureMapFilter) as TextureMapFilter;
			_offsetX.value = _textureMapFilter.offsetX;
			_offsetY.value = _textureMapFilter.offsetY;
			_repeatX.value = _textureMapFilter.repeatX;
			_repeatY.value = _textureMapFilter.repeatY;
			_alpha.value = _textureMapFilter.alpha;
			_mask.value = _textureMapFilter.mask;
			return true;
		}

	}
}
