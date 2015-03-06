package ide.plugins.groups.particles {

	import ide.App;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.container.Accordion;

	public class ParticleLifetimeGroup extends Accordion {
		
		public var app		: App;
		public var particle	: ParticleSystem;
		
		public function ParticleLifetimeGroup(text : String) {
			super(text);
		}
		
		public function updateGroup(app : App, particle : ParticleSystem) : void {
			this.app = app;
			this.particle = particle;
		}
	}
}
