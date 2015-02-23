package ide.plugins.groups.particles {
	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.rotation.BillboardAction;
	
	import ide.App;

	public class BillboardActionGroup extends ParticlesProperties {
		
		private var _action : BillboardAction;
		
		public function BillboardActionGroup() {
			super("BillboardAction");
			enableCheck = true;
			accordion.contentHeight = 0;
		}
		
		public function get action():BillboardAction {
			return _action;
		}

		public function set action(value:BillboardAction):void {
			_action = value;
			if (_action == null) {
				_check.value = false;
				accordion.open = false;
			} else {
				_check.value = true;
			}
		}
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new BillboardAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, BillboardAction) as BillboardAction;
		}
		
		
	}
}
