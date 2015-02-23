package ide.plugins.groups.shader {

	import flash.events.Event;
	
	import L3D.core.shader.Shader3D;
	import L3D.core.shader.filters.BillboardFilter;
	
	import ide.events.SelectionEvent;
	
	import ide.App;
	import ui.core.controls.InputText;
	import ui.core.event.ControlEvent;

	public class BillboardFilterOption extends ShaderProperties {

		private var _shader : Shader3D;
		private var _app : App;
		private var _closeBtn : InputText;
		private var _billboardFilter : BillboardFilter;

		public function BillboardFilterOption(filter : BillboardFilter, shader : Shader3D, app : App) {
			super("BillboardFilter");
			accordion.contentHeight = 20;
			layout.margins = 0;
			layout.space = 0;
			_closeBtn = layout.addControl(new InputText("Remove BillboardFilter")) as InputText;
			_closeBtn.textField.selectable = false;
			_closeBtn.addEventListener(ControlEvent.CLICK, removeFilter);
			
			_shader = shader;
			_app = app;
			_billboardFilter = filter;
		}

		protected function removeFilter(event : Event) : void {
			_shader.removeFilter(_billboardFilter);
			_app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
		}
		
		override public function update(shader : Shader3D, app : App) : Boolean {
			_shader = shader;
			_app = app;
			_billboardFilter = _shader.getFilterByClass(BillboardFilter) as BillboardFilter;
			if (_billboardFilter == null)
				return false;
			return true;
		}


	}
}
