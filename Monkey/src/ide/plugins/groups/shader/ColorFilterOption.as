package ide.plugins.groups.shader {
	import flash.events.Event;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.ColorFilter;
	import L3D.core.shader.filters.TextureMapFilter;
	import L3D.core.texture.Texture3D;
	
	import ide.events.SelectionEvent;
	
	import ide.App;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.InputText;
	import ui.core.event.ControlEvent;

	public class ColorFilterOption extends ShaderProperties {
		
		private var _app : App;
		private var _shader : Shader3D;
		private var _colorPicker : ColorPicker;
		private var _colorFilter : ColorFilter;
		private var _closeBtn : InputText;
		
		public function ColorFilterOption(filter : ColorFilter, shader : Shader3D, app : App) {
			super("ColorFilter");
			accordion.contentHeight = 50;
			layout.margins = 0;
			layout.space = 0;
			_colorPicker = layout.addControl(new ColorPicker(), "Color:") as ColorPicker;
			_colorPicker.addEventListener(ControlEvent.CHANGE, changeColor);
			_closeBtn = layout.addControl(new InputText("Remove Color Filter")) as InputText;
			_closeBtn.maxHeight = 20;
			_closeBtn.addEventListener(ControlEvent.CLICK, removeColorFilter);
			
			
			_app = app;
			_shader = shader;
			_colorFilter = filter;
			_colorPicker.color = _colorFilter.color;
			_colorPicker.alpha = _colorFilter.alpha;
		}
		
		protected function removeColorFilter(event:Event) : void {
			_shader.removeFilter(_colorFilter);
			if (_shader.getFilterByClass(TextureMapFilter) == null) {
				_shader.addFilter(new TextureMapFilter(new Texture3D()));
			}
			_app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
		}
		
		protected function changeColor(event:Event) : void {
			_colorFilter.color = _colorPicker.color;
			_colorFilter.alpha = _colorPicker.alpha;
		}
		
		override public function update(shader:Shader3D, app:App):Boolean {
			_app = app;
			_shader = shader;
			_colorFilter = _shader.getFilterByClass(ColorFilter) as ColorFilter;
			if (_colorFilter == null)
				return false;
			_colorPicker.color = _colorFilter.color;
			_colorPicker.alpha = _colorFilter.alpha;
			return true;
		}
		
		
	}
}
