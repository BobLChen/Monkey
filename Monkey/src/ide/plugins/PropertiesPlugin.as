package ide.plugins {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import ide.App;
	import ide.events.SceneEvent;
	import ide.events.SelectionEvent;
	import ide.plugins.groups.properties.AnimatorGroup;
	import ide.plugins.groups.properties.BoundsGroup;
	import ide.plugins.groups.properties.DirectionLightGroup;
	import ide.plugins.groups.properties.GeneralGroup;
	import ide.plugins.groups.properties.MeshGroup;
	import ide.plugins.groups.properties.NameGroup;
	import ide.plugins.groups.properties.NavmeshGroup;
	import ide.plugins.groups.properties.ParticlesGroup;
	import ide.plugins.groups.properties.PointLightGroup;
	import ide.plugins.groups.properties.PropertiesGroup;
	import ide.plugins.groups.properties.SkyboxGroup;
	import ide.plugins.groups.properties.TransformGroup;
	import ide.plugins.groups.properties.WaterGroup;
	
	import monkey.core.base.Bone3D;
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.light.Light3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	
	import ui.core.container.Panel;
	import ui.core.controls.Layout;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IPlugin;

	
	
	/**
	 * 属性插件 
	 * @author Neil
	 * 
	 */	
	public class PropertiesPlugin implements IPlugin {

		private var _panel 		: Panel;
		private var _icon 		: MovieClip;
		private var _app 		: App;
		private var _nameGroup 	: NameGroup;
		private var _layout 	: Layout;
		private var _groups 	: Vector.<PropertiesGroup>;
		
		public function PropertiesPlugin() {
			this._icon 		= new McIcons();
			this._nameGroup = new NameGroup();
			this._groups 	= new Vector.<PropertiesGroup>();
		}
		
		public function init(app : App) : void {
			this._app = app;
			
			this._panel = new Panel("PROPERTIES", 200, 350, false);
			this._panel.minWidth = 200;
			this._layout = new Layout(true);
			this._layout.root.background = true;
			this._layout.root.minHeight = 800;
			this._layout.margins = 0;
			this._layout.space = 1;
			this._layout.minHeight = 800;
			this._layout.addControl(this._nameGroup);
						
			this.addPropGroup(new GeneralGroup());
			this.addPropGroup(new TransformGroup());
			this.addPropGroup(new MeshGroup());
			this.addPropGroup(new BoundsGroup());
			this.addPropGroup(new NavmeshGroup());
			this.addPropGroup(new WaterGroup());
			this.addPropGroup(new SkyboxGroup());
			this.addPropGroup(new ParticlesGroup());
			this.addPropGroup(new DirectionLightGroup());
			this.addPropGroup(new PointLightGroup());
			this.addPropGroup(new AnimatorGroup());
			
			this._icon.gotoAndStop(0);
			this._icon.x = 20;
			this._icon.y = 17;
			this._icon.graphics.clear();
			this._icon.graphics.lineStyle(1, 0xA0A0A0, 1, true);
			this._icon.graphics.drawRect(-10, -11, 20, 20);
			this._nameGroup.view.addChild(this._icon);
			this._panel.addControl(this._layout);
			this._nameGroup.addEventListener(ControlEvent.CHANGE, this.changingControlEvent);
						
			this._app.studio.property.addPanel(_panel);
			this._app.studio.property.open();
		}
		
		/**
		 * 添加一个属性栏目 
		 * @param group
		 * 
		 */		
		public function addPropGroup(group : PropertiesGroup) : void {
			this._groups.push(group);
		}
		
		protected function changingControlEvent(event : Event) : void {
			switch (event.target) {
				case this._nameGroup.names:  {
					if (this._app.selection.main != null) {
						this._app.selection.main.name = this._nameGroup.names.text;
					} else {
						this._app.scene.name = this._nameGroup.names.text;
					}
					this._app.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
					break;
				}
			}
		}
		
		public function start() : void {
			this._app.addEventListener(SelectionEvent.CHANGE, this.changeSelectionEvent);
			this.changeSelectionEvent(null);
		}
		
		private function changeSelectionEvent(event : Event) : void {
			
			var objects : Array = this._app.selection.objects;
			var main : Object3D = this._app.selection.main;
			
			if (!main) {
				main = this._app.scene;
			}
			if (objects.length == 0) {
				objects = [this._app.scene];
			}
			this._layout.removeAllControls();
			this._layout.addControl(this._nameGroup);
			
			var name : String = "";
			for each (var pivot : Object3D in objects) {
				name += pivot.name + ",";
			}
			if (objects.length > 1) {
				name = objects.length + " Object Selected : " + name;
				this._nameGroup.names.toolTip = name;
			} else {
				this._nameGroup.names.toolTip = null;
			}
			
			this._nameGroup.names.text = name.substr(0, -1);
			this._nameGroup.names.enabled = (objects.length == 1);
			
			if (objects.length != 1) {
				this._icon.gotoAndStop(0);
			} else if (main is ParticleSystem) {
				this._icon.gotoAndStop(7);
			} else if (main is Scene3D) {
				this._icon.gotoAndStop(6);
			} else if (main.getComponent(MeshRenderer)) {
				this._icon.gotoAndStop(1);
			} 
			else if (main is Camera3D) {
				this._icon.gotoAndStop(4);
			} else if (main is Light3D) {
				this._icon.gotoAndStop(11);
			}  else if (main is Bone3D) {
				this._icon.gotoAndStop(10);
			} else {
				this._icon.gotoAndStop(2);
			}
			
			for each (var group : PropertiesGroup in this._groups) {
				if (group.update(this._app)) {
					this._layout.addControl(group.accordion);
				}
			}
			
			this._layout.draw();
		}
	}
}
