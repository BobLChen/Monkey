package ide.plugins.groups.particles {
	
	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.uv.UVDriftGlobalAction;
	
	import ide.App;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class UVDriftActionGroup extends ParticlesProperties {
		
		private var _action : UVDriftGlobalAction;
		
		private var _scale : Spinner;
		private var _degree : Spinner;
		private var _axisU : CheckBox;
		private var _axisV : CheckBox;
		
		public function UVDriftActionGroup() {
			super("UVDriftMovieClipAction");
			enableCheck = true;
			accordion.contentHeight = 42;
			layout.addHorizontalGroup();
			layout.labelWidth = 70;
			_scale = layout.addControl(new Spinner(), "Scale:") as Spinner;
			_degree = layout.addControl(new Spinner(), "Degree:") as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup();
			_axisU = layout.addControl(new CheckBox(), "U:") as CheckBox;
			_axisV = layout.addControl(new CheckBox(), "V:") as CheckBox;
			
			_scale.addEventListener(ControlEvent.CHANGE, change);
			_degree.addEventListener(ControlEvent.CHANGE, change);
			_axisU.addEventListener(ControlEvent.CHANGE, changeU);
			_axisV.addEventListener(ControlEvent.CHANGE, changeV);
		}
		
		protected function changeV(event:Event) : void {
			_axisU.value = false;
			action.axis = UVDriftGlobalAction.V_AXIS;
		}
		
		protected function changeU(event:Event) : void {
			_axisV.value = false;
			action.axis = UVDriftGlobalAction.U_AXIS;
		}
		
		protected function change(event:Event) : void {
			action.scale = _scale.value;
			action.cycle = _degree.value;
		}
		
		public function get action():UVDriftGlobalAction {
			return _action;
		}

		public function set action(value:UVDriftGlobalAction):void {
			_action = value;
			
			if (_action == null) {
				_check.value = false;
				accordion.open = false;
				_scale.enabled = false;
				_degree.enabled = false;
				_axisU.enabled = false;
				_axisV.enabled = false;
			} else {
				_check.value = true;
				_scale.enabled = true;
				_degree.enabled = true;
				_axisU.enabled = true;
				_axisV.enabled = true;
				
				_scale.value = action.scale;
				_degree.value = action.cycle;
				if (action.axis == UVDriftGlobalAction.U_AXIS) {
					_axisU.value = true;
					_axisV.value = false;
				} else {
					_axisU.value = false;
					_axisV.value = true;
				}
			}
		}
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new UVDriftGlobalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, UVDriftGlobalAction) as UVDriftGlobalAction;
		}
		
	}
}
