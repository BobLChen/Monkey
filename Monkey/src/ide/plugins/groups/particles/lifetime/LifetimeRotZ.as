package ide.plugins.groups.particles.lifetime {
	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleLifetimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.Menu;
	import ui.core.controls.CurvesEditor;

	/**
	 * lifetime speed x 
	 * @author Neil
	 * 
	 */	
	public class LifetimeRotZ extends ParticleLifetimeGroup {
		
		private var curve  : CurvesEditor;
		private var data   : LifetimeData;
		
		public function LifetimeRotZ() {
			super("LifetimeRotateZ");
			this.curve  = new CurvesEditor(230, 150);
			this.curve.lockX = true;
			this.contentHeight = 200;
			this.addControl(curve);
			
			var menu : Menu = new Menu();
			menu.addMenuItem("Build", onChangeLifetime);
			this.curve.view.contextMenu = menu.menu;
		}
		
		private function onChangeLifetime(e : Event) : void {
			this.data.rotZ.datas = new Vector.<Point>();
			for each (var p : Point in this.curve.points) {
				this.data.rotZ.datas.push(p.clone());
			}
			this.particle.keyFrames = this.data.generate();
		}
		
		override public function updateGroup(app : App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.open = false;
			this.data = particle.userData.lifetime;
			this.curve.points = this.data.rotZ.datas;
		}
		
	}
}
