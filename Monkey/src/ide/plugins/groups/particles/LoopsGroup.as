package ide.plugins.groups.particles {
	
	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Label;
	import ui.core.event.ControlEvent;

	public class LoopsGroup extends ParticleAttribute {
		
		private var loops : CheckBox;
		private var label : Label;
		
		public function LoopsGroup() {
			super();
			this.minHeight = 20;
			this.maxHeight = 20;
			this.orientation = HORIZONTAL;
			this.label = new Label("Loops:");
			this.loops = new CheckBox();
			this.addControl(label);
			this.addControl(loops);
			this.loops.addEventListener(ControlEvent.CHANGE, changeLoops);
		}
		
		private function changeLoops(event:Event) : void {
			this.particle.loops = this.loops.value;
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.loops.value = particle.loops;
		}
		
	}
}
