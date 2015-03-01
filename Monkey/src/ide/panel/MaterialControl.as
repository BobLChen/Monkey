package ide.panel {

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ide.App;
	import ide.events.SelectionEvent;
	import ide.plugins.groups.shader.ShaderOptions;
	import ide.plugins.groups.shader.ShaderProperties;
	
	import monkey.core.materials.Material3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.BillboardFilter;
	import monkey.core.shader.filters.ColorFilter;
	import monkey.core.shader.filters.Filter3D;
	import monkey.core.shader.filters.FogFilter;
	import monkey.core.shader.filters.LightMapfilter;
	import monkey.core.shader.filters.RimFilter;
	import monkey.core.shader.filters.TextureMapFilter;
	import monkey.core.textures.Texture3D;
	
	import ui.core.container.Accordion;
	import ui.core.container.MenuCombox;
	import ui.core.controls.Layout;
	import ui.core.event.ControlEvent;

	public class MaterialControl {

		[Embed(source = "image 79.png")]
		private var AddIcon : Class;
		
		public var accordion : Accordion;
		public var layout 	 : Layout;
		
		private var _shader  : Shader3D;					// shader
		private var _groups  : Vector.<ShaderProperties>;	// group
		private var _app 	 : App;							// app
		private var _tree 	 : PivotTree;					// tree
		private var _addBtn  : MenuCombox;					// add按钮
		
		public function MaterialControl() {
			this.layout = new Layout(true);
			this.layout.labelWidth = 90;
			
			this.accordion = new Accordion("Material");
			this.accordion.addControl(this.layout);
			this.accordion.contentHeight = 500;
			
			this.layout.margins = 0;
			this.layout.space = 0;
			
			this._addBtn = new MenuCombox("Add Filter");
			this._addBtn.addMenuItem("ColorFilter", 		addColorFilter);
			this._addBtn.addMenuItem("BillboardFilter", 	addBillboardFilter);
			this._addBtn.addMenuItem("TextureMapFilter", 	addTextureMapFilter);
			this._addBtn.addMenuItem("PositionColorFilter", addPositionColorFilter);
			this._addBtn.addMenuItem("FogFilter", 			addFogFilter);
			this._addBtn.addMenuItem("LightFilter", 		addLightFilter);
			this._addBtn.addMenuItem("LightMapFilter", 		addLightmapFilter);
			this._addBtn.addMenuItem("NormalMapFilter",	 	addNormalMapFilter);
			this._addBtn.addMenuItem("RimFilter", 			addRimFilter);
			
			this._groups = new Vector.<ShaderProperties>();
			this._groups.push(new ShaderOptions());
			
			this._tree = new PivotTree();
			this._tree.width = 250;
			this._tree.height = 500;
			this._tree.minHeight = 500;
			this._tree.visible = false;
			
			this.accordion.view.addChild(this._tree.view);
		}
		
		private function chooseLight(event : Event) : void {
//			if (_tree.selected.length >= 1 && _tree.selected[0] is Light3D) {
//				var light : Light3D = this._tree.selected[0] as Light3D;
//				if (light is PointLight) {
//					this._shader.addFilter(new PointLightFilter(light as PointLight));
//				} else if (light is DirectionalLight) {
//					this._shader.addFilter(new DirectionalLightFilter(light as DirectionalLight));
//				}
//				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
//				this._tree.visible = false;
//			}
		}
		
		private function addRimFilter(e : MouseEvent) : void {
			if (this._shader.getFilterByClass(RimFilter) == null) {
				this._shader.addFilter(new RimFilter());
				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
			}
		}
		
		private function addLightFilter(e : MouseEvent) : void {
			this._tree.pivot = this._app.scene;
			this._tree.addEventListener(ControlEvent.CLICK, chooseLight);
			this._tree.draw();
			this._tree.visible = true;
		}
		
		private function addBillboardFilter(e : MouseEvent) : void {
			if (this._shader.getFilterByClass(BillboardFilter) == null) {
				this._shader.addFilter(new BillboardFilter());
				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
			}
		}
		
		private function addNormalMapFilter(e : MouseEvent) : void {
//			if (this._shader.getFilterByClass(NormalMapFilter) == null) {
//				this._shader.addFilter(new NormalMapFilter(new Texture3D(Device3D.nullBitmapData)));
//				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
//			}
		}
		
		private function addLightmapFilter(e : MouseEvent) : void {
			if (this._shader.getFilterByClass(LightMapfilter) == null) {
				this._shader.addFilter(new LightMapfilter(new Texture3D()));
				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
			}
		}
		
		private function addFogFilter(e : MouseEvent) : void {
			if (this._shader.getFilterByClass(FogFilter) == null) {
				this._shader.addFilter(new FogFilter(100));
				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
			}
		}
		
		private function addPositionColorFilter(e : MouseEvent) : void {
//			if (this._shader.getFilterByClass(VertColor) == null) {
//				this._shader.addFilter(new VertColor());
//				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
//			}
		}
		
		private function addColorFilter(e : MouseEvent) : void {
//			if (this._shader.getFilterByClass(ColorFilter) == null) {
//				var textureMapFilter : TextureMapFilter = this._shader.getFilterByClass(TextureMapFilter) as TextureMapFilter;
//				if (textureMapFilter != null) {
//					this._shader.removeFilter(textureMapFilter);
//				}
//				this._shader.addFilter(new ColorFilter(0xc8c8c8));
//				this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
//			}
		}
		
		private function addTextureMapFilter(e : MouseEvent) : void {
			var colorFilter : ColorFilter = _shader.getFilterByClass(ColorFilter) as ColorFilter;
			if (colorFilter != null) {
				this._shader.removeFilter(colorFilter);
			}
			this._shader.addFilter(new TextureMapFilter(new Texture3D()));
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
		}
		
		public function updateShader(shader : Shader3D, app : App) : void {
			this._shader = shader;
			this._app    = app;
			this.layout.removeAllControls();
			for each (var group : ShaderProperties in _groups) {
				if (group.update(shader, app)) {
					this.layout.addControl(group.accordion);
				}
			}
			for each (var filter : Filter3D in shader.filters) {
				var grp : ShaderProperties = filterGroup(filter, shader, app);
				if (grp != null) {
					this.layout.addControl(grp.accordion);
				}
			}
			this.layout.addControl(this._addBtn);
			this.layout.draw();
		}
		
		private function filterGroup(filter : Filter3D, shader : Shader3D, app : App) : ShaderProperties {
//			if (filter is TextureMapFilter) {
//				return new TextureMapOption(filter as TextureMapFilter, shader, app);
//			} else if (filter is ColorFilter) {
//				return new ColorFilterOption(filter as ColorFilter, shader, app);
//			} else if (filter is BillboardFilter) {
//				return new BillboardFilterOption(filter as BillboardFilter, shader, app);
//			} else if (filter is FogFilter) {
//				return new FogFilterOption(filter as FogFilter, shader, app);
//			} else if (filter is DirectionalLightFilter) {
//				return new DirectionLightOption(filter as DirectionalLightFilter, shader, app);
//			} else if (filter is PointLightFilter) {
//				return new PointLightOption(filter as PointLightFilter, shader, app);
//			} else if (filter is LightMapfilter) {
//				return new LightmapFilterOption(filter as LightMapfilter, shader, app);
//			} else if (filter is NormalMapFilter) {
//				return new NormalMapFilterOption(filter as NormalMapFilter, shader, app);
//			} else if (filter is RimFilter) {
//				return new RimFilterOption(filter as RimFilter, shader, app);
//			}
			return null;
		}

		public function update(material:Material3D, app:Object) : void {
			
		}
	}
}
