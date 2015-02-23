package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.velocity.VelocityGlobalAction;
	
	import ide.App;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class VelocityGlobalActionGroup extends ParticlesProperties {
		
		private var _action : VelocityGlobalAction;
		
		private var _vx : Spinner;
		private var _vy : Spinner;
		private var _vz : Spinner;
		
		public function VelocityGlobalActionGroup() {
			super("VelocityGlobalAction");
			enableCheck = true;
			accordion.contentHeight = 22;
			layout.addHorizontalGroup("VelocityGlobal:");
			_vx = layout.addControl(new Spinner()) as Spinner;
			_vy = layout.addControl(new Spinner()) as Spinner;
			_vz = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			
			_vx.addEventListener(ControlEvent.CHANGE, changeVelocity)
			_vy.addEventListener(ControlEvent.CHANGE, changeVelocity)
			_vz.addEventListener(ControlEvent.CHANGE, changeVelocity)
		}
		
		protected function changeVelocity(event:Event) : void {
			_action.velocity = new Vector3D(_vx.value, _vy.value, _vz.value);			
		}
		
		public function get action():VelocityGlobalAction {
			return _action;
		}

		public function set action(value:VelocityGlobalAction):void {
			_action = value;
			
			if (_action == null) {
				_check.value = false;
				accordion.open = false;
				_vx.enabled = false;
				_vy.enabled = false;
				_vz.enabled = false;
			} else {
				_vx.enabled = true;
				_vy.enabled = true;
				_vz.enabled = true;
				_check.value = true;
				
				_vx.value = _action.velocity.x;
				_vy.value = _action.velocity.y;
				_vz.value = _action.velocity.z;
			}
			
		}

		override protected function changeCheck(event:Event):void {
			
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new VelocityGlobalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
			
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, VelocityGlobalAction) as VelocityGlobalAction;
		}
		
		
		
	}
}
