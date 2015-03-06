package ide.plugins.groups.particles.base {
	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.Label;
	import ide.plugins.groups.particles.ParticleBaseGroup;

	public class MaxParticleGroup extends ParticleBaseGroup {
		
		private var label : Label;
		private var nums  : Label;
		
		public function MaxParticleGroup() {
			super();
			this.orientation = HORIZONTAL;
			this.label = new Label("MaxParticles:");
			this.nums  = new Label();
			
			this.addControl(label);
			this.addControl(nums);
			this.maxHeight = 20;
			this.minHeight = 20;
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.nums.text = "" + particle.maxParticles;
			this.particle.addEventListener(ParticleSystem.BUILD, onBuild);
		}
		
		private function onBuild(event:Event) : void {
			this.nums.text = "" + particle.maxParticles;
		}
		
	}
}
