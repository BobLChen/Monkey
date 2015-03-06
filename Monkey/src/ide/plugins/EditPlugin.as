package ide.plugins {

	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.base.Object3D;
	import monkey.navmesh.NavigationMesh;
	
	import ui.core.interfaces.IPlugin;

	public class EditPlugin implements IPlugin {
		
		private var _app : App;
		
		public function EditPlugin() {
		
		}

		public function init(app : App) : void {
			this._app = app;
			
			this._app = app;
			this._app.addMenu("Edit/Convert To Navmesh",  convertToNavMesh);
		}

		public function start() : void {
		
		}
		
		/**
		 * 将obj转化为navmesh 
		 * @param e
		 * 
		 */		
		private function convertToNavMesh(e : Event) : void {
			var obj : Object3D = this._app.selection.main;
			if (obj && obj.renderer && obj.renderer.mesh) {
				var navMesh : NavigationMesh = new NavigationMesh();
				navMesh.build(obj.renderer.mesh);
				navMesh.name = obj.name + "_NavMesh";
				this._app.scene.addChild(navMesh);
				this._app.selection.objects = [navMesh];
			}
		}
		
	}
}
