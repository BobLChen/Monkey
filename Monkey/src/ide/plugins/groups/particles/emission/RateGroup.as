package ide.plugins.groups.particles.emission {
	
	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ide.plugins.groups.particles.ParticleBaseGroup;

	/**
	 * 发射器属性 
	 * @author Neil
	 * 
	 */	
	public class RateGroup extends ParticleBaseGroup {
		
		private var rate : Spinner;
				
		public function RateGroup() {
			super();
			this.orientation = HORIZONTAL;
			this.addControl(new Label("Rate:"));
			this.rate = new Spinner();
			this.addControl(this.rate);
			this.rate.addEventListener(ControlEvent.CHANGE, changeRate);
			this.minHeight = this.maxHeight = 20;
		}
		
		private function changeRate(event:Event) : void {
			this.particle.rate = this.rate.value;			
		}
		
		override public function updateGroup(app : App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.rate.value = particle.rate;
		}
		
	}
}
