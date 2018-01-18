package ide.plugins {

	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import ide.App;
	import ide.events.SelectionEvent;
	import ide.plugins.groups.properties.MaterialGroup;
	
	import monkey.core.base.Object3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.materials.DiffuseMaterial;
	import monkey.core.materials.Material3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.Texture3DUtils;
	
	import ui.core.container.Panel;
	import ui.core.controls.Layout;
	import ui.core.interfaces.IPlugin;
	
	/**
	 * 材质插件 
	 * @author Neil
	 * 
	 */	
	public class MaterialPlugin implements IPlugin {
		
		private var _app 		: App;
		private var _panel 		: Panel;
		private var _layout 	: Layout;
		private var _materials 	: Dictionary;
		
		public function MaterialPlugin() {
			this._materials = new Dictionary();
			this._panel 	= new Panel("MATERIAL");
			this._layout 	= new Layout();
			this._panel.addControl(this._layout);
			this._panel.minWidth = 200;
		}

		public function init(app : App) : void {
			this._app = app;
			this._app.studio.property.addPanel(this._panel);
			this._app.addEventListener(SelectionEvent.CHANGE, changeMaterialEvent);
			this._app.addEventListener(SelectionEvent.CHANGE_MATERIAL, changeMaterialEvent);
			
			this._app.addMenu("Material/ColorMaterial",   createColorMaterial);
			this._app.addMenu("Material/DiffuseMaterial", createDiffuseMaterial);
		}
		
		private function createColorMaterial(e : Event) : void {
			if (this._app.selection.main && this._app.selection.main.renderer && this._app.selection.main.renderer.material) {
				this._app.selection.main.renderer.material.dispose();
				this._app.selection.main.renderer.material = new ColorMaterial(Color.GRAY);
			}
		}
		
		private function createDiffuseMaterial(e : Event) : void {
			if (this._app.selection.main && this._app.selection.main.renderer && this._app.selection.main.renderer.material) {
				this._app.selection.main.renderer.material.dispose();
				this._app.selection.main.renderer.material = new DiffuseMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData));
			}
		}
		
		private function changeMaterialEvent(event:Event) : void {
			this._layout.removeAllControls();
			var pivot : Object3D = this._app.selection.main;
			if (!pivot || !pivot.renderer || !pivot.renderer.material) {
				return;
			}
			var material : Material3D = pivot.renderer.material;
			if (!this._materials[material]) {
				this._materials[material] = new MaterialGroup();
			}
			var mc : MaterialGroup = this._materials[material] as MaterialGroup;
			mc.update(material, this._app);
			this._layout.addControl(mc.accordion);
			this._panel.update();
			this._panel.draw();
		}
		
		public function start() : void {
			
		}
	}
}
