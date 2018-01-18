package ide.plugins.groups.particles.base {

	import flash.events.Event;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleBaseGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Label;
	import ui.core.event.ControlEvent;

	/**
	 * 广告牌
	 * @author Neil
	 *
	 */
	public class BillboardGroup extends ParticleBaseGroup {

		private var billboard : CheckBox;

		public function BillboardGroup() {
			super();
			this.orientation = HORIZONTAL;
			this.billboard = new CheckBox();
			this.addControl(new Label("Billboard:"));
			this.addControl(billboard);
			this.maxHeight = 20;
			this.minHeight = 20;
			this.billboard.addEventListener(ControlEvent.CHANGE, change);
		}

		private function change(event : Event) : void {
			particle.billboard = billboard.value;
		}

		override public function updateGroup(app : App, particle : ParticleSystem) : void {
			super.updateGroup(app, particle);
			this.billboard.value = particle.billboard;
		}

	}
}
