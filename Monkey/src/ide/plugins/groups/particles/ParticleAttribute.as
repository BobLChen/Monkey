package ide.plugins.groups.particles {

	import ide.App;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.container.Box;

	public class ParticleAttribute extends Box {
		
		public var app		: App;
		public var particle	: ParticleSystem;
		
		public function ParticleAttribute() {
			super();
		}
		
		public function updateGroup(app : App, particle : ParticleSystem) : void {
			this.app	= app;
			this.particle = particle;
		}
		
	}
}
