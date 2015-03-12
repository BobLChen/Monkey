package ide.plugins.groups.particles.start {

	import flash.events.Event;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleBaseGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.container.Box;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class StartDelayGroup extends ParticleBaseGroup {

		private var label : Label;
		private var delay : Spinner;

		public function StartDelayGroup() {
			super();
			this.orientation = Box.HORIZONTAL;
			this.label = new Label("StartDelay:");
			this.delay = new Spinner();
			this.addControl(this.label);
			this.addControl(this.delay);
			this.minHeight = 20;
			this.maxHeight = 20;
			this.delay.addEventListener(ControlEvent.CHANGE, changeDelay);
		}

		private function changeDelay(event : Event) : void {
			this.particle.startDelay = this.delay.value;
		}

		override public function updateGroup(app : App, particle : ParticleSystem) : void {
			super.updateGroup(app, particle);
			this.delay.value = particle.startDelay;
		}
	}
}
