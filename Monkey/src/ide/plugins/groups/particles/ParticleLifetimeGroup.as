package ide.plugins.groups.particles {

	import flash.events.Event;
	
	import ide.App;
	import ide.plugins.groups.particles.lifetime.LifetimeData;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.ParticleUtils;
	
	import ui.core.Menu;
	import ui.core.container.Accordion;
	import ui.core.controls.LinearsEditor;

	public class ParticleLifetimeGroup extends Accordion {
		
		public var app		: App;
		public var particle	: ParticleSystem;
		
		protected var curve : LinearsEditor;
		protected var data  : LifetimeData;
		
		public function ParticleLifetimeGroup(text : String) {
			super(text);
			
			this.curve  = new LinearsEditor(230, 170);
			this.curve.lockX = true;
			this.contentHeight = 230;
			this.addControl(curve);
			
			var menu : Menu = new Menu();
			menu.addMenuItem("Build", onChangeLifetime);
			this.curve.view.contextMenu = menu.menu;
		}
		
		protected function onChangeLifetime(e : Event) : void {
			this.particle.keyFrames = ParticleUtils.GeneratelifetimeBytes(
				data.lifetime,
				data.speedX,
				data.speedY,
				data.speedZ,
				data.axisX,
				data.axisY,
				data.axisZ,
				data.angle,
				data.size
			);			
		}
		
		public function updateGroup(app : App, particle : ParticleSystem) : void {
			this.app = app;
			this.particle = particle;
		}
	}
}
