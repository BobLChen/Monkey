package ide.plugins.groups.particles.lifetime {
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleLifetimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.ParticleUtils;
	
	import ui.core.Menu;
	import ui.core.controls.LinearsEditor;

	/**
	 * lifetime speed x 
	 * @author Neil
	 * 
	 */	
	public class LifetimeSize extends ParticleLifetimeGroup {
		
		private var curve  : LinearsEditor;
		private var data   : LifetimeData;
		
		public function LifetimeSize() {
			super("LifetimeSize");
			this.curve  = new LinearsEditor(230, 150);
			this.curve.lockX = true;
			this.contentHeight = 200;
			this.addControl(curve);
			
			var menu : Menu = new Menu();
			menu.addMenuItem("Build", onChangeLifetime);
			this.curve.view.contextMenu = menu.menu;
		}
		
		private function onChangeLifetime(e : Event) : void {
			this.data.size.datas = new Vector.<Point>();
			for each (var p : Point in this.curve.points) {
				this.data.size.datas.push(p.clone());
			}
			this.particle.keyFrames = ParticleUtils.GeneratelifetimeBytes(
				data.lifetime,
				data.speedX,
				data.speedY,
				data.speedZ,
				data.rotX,
				data.rotY,
				data.rotZ,
				data.size
			);
		}
		
		override public function updateGroup(app : App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.open = false;
			this.data = particle.userData.lifetime;
			this.curve.points = this.data.size.datas;
		}
				
	}
}
