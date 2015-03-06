package ide.plugins.groups.particles.emission {

	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.container.Box;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ide.plugins.groups.particles.ParticleBaseGroup;

	/**
	 * duration 
	 * @author Neil
	 * 
	 */	
	public class DurationGroup extends ParticleBaseGroup {
		
		private var duration : Spinner;
		private var label	 : Label;
		
		public function DurationGroup() {
			super();
			this.minHeight = 20;
			this.maxHeight = 20;
			this.orientation = Box.HORIZONTAL;
			this.label = new Label("Duration:");
			this.duration = new Spinner(5, 0, 0, 2, 0);
			this.addControl(label);
			this.addControl(duration);
			this.duration.addEventListener(ControlEvent.CHANGE, onChange);
		}
		
		private function onChange(event:Event) : void {
			this.particle.duration = this.duration.value;		
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.duration.value = this.particle.duration;
		}
		
	}
}
