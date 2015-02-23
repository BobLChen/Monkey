package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.acceleration.GrivityAction;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class GrivityGlobalActionGroup extends ParticlesProperties {
		
		private var _gx : Spinner;
		private var _gy : Spinner;
		private var _gz : Spinner;
		private var _power : Spinner;
		private var _grivityAction : GrivityAction;
		
		public function GrivityGlobalActionGroup() {
			super("GrivityAction");
			enableCheck = true;
			accordion.contentHeight = 42;
			layout.maxHeight = 42;
			layout.addHorizontalGroup("Grivity:");
			_gx = layout.addControl(new Spinner()) as Spinner;
			_gy = layout.addControl(new Spinner()) as Spinner;
			_gz = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			_power = layout.addControl(new Spinner(), "Power:") as Spinner;
			
			_gx.addEventListener(ControlEvent.CHANGE, changeGrivity);
			_gy.addEventListener(ControlEvent.CHANGE, changeGrivity);
			_gz.addEventListener(ControlEvent.CHANGE, changeGrivity);
			_power.addEventListener(ControlEvent.CHANGE, changeGrivity);
		}
		
		protected function changeGrivity(event:Event) : void {
			_grivityAction.grivity = new Vector3D(_gx.value, _gy.value, _gz.value, _power.value);			
		}
				
		public function get grivityAction():GrivityAction {
			return _grivityAction;
		}

		public function set grivityAction(value:GrivityAction):void {
			_grivityAction = value;
			
			if (_grivityAction == null) {
				_gx.enabled = false;
				_gy.enabled = false;
				_gz.enabled = false;
				_power.enabled = false;
				accordion.open = false;
				_check.value = false;
			} else {
				_gx.enabled = true;
				_gy.enabled = true;
				_gz.enabled = true;
				_power.enabled = true;
				_check.value = true;
				_gx.value = _grivityAction.grivity.x;
				_gy.value = _grivityAction.grivity.y;
				_gz.value = _grivityAction.grivity.z;
				_power.value = _grivityAction.grivity.w;
			}
			
		}

		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_grivityAction == null) {
					_particles.addAction(new GrivityAction());
				}
			} else {
				if (_grivityAction != null) {
					_particles.removeAction(_grivityAction);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			grivityAction = ActionUtils.checkAction(particles, GrivityAction) as GrivityAction;
			
		}
		
		
	}
}
