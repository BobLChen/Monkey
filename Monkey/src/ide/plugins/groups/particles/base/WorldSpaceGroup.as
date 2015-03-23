package ide.plugins.groups.particles.base {

	import flash.events.Event;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleBaseGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Label;
	import ui.core.event.ControlEvent;
	
	/**
	 * world space 
	 * @author Neil
	 * 
	 */	
	public class WorldSpaceGroup extends ParticleBaseGroup {
		
		private var world : CheckBox;
		
		public function WorldSpaceGroup() {
			super();
			this.orientation = HORIZONTAL;
			this.world = new CheckBox();
			this.addControl(new Label("WorldSpace:"));
			this.addControl(world);
			this.maxHeight = 20;
			this.minHeight = 20;
			this.world.addEventListener(ControlEvent.CHANGE, change);
		}
		
		private function change(event:Event) : void {
			this.particle.worldspace = world.value;
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.world.value = this.particle.worldspace;
		}
		
	}
}
