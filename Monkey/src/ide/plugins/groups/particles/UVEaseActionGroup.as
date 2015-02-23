package ide.plugins.groups.particles {
	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.uv.UVLinearEaseGlobalAction;
	
	import ide.App;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class UVEaseActionGroup extends ParticlesProperties {
		
		private var _action : UVLinearEaseGlobalAction;
		
		private var _scale : Spinner;
		private var _ease : Spinner;
		private var _u : CheckBox;
		private var _v : CheckBox;
		
		public function UVEaseActionGroup() {
			super("UVEaseMovieClipAction");
			enableCheck = true;
			accordion.contentHeight = 42;
			layout.addHorizontalGroup();
			layout.labelWidth = 70;
			_scale = layout.addControl(new Spinner(), "Scale:") as Spinner;
			_ease = layout.addControl(new Spinner(), "Ease:") as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup();
			_u = layout.addControl(new CheckBox(), "U:") as CheckBox;
			_v = layout.addControl(new CheckBox(), "V:") as CheckBox;
			
			_scale.addEventListener(ControlEvent.CHANGE, change);
			_ease.addEventListener(ControlEvent.CHANGE, change);
			_u.addEventListener(ControlEvent.CHANGE, changeU);
			_v.addEventListener(ControlEvent.CHANGE, changeV);
		}
		
		protected function changeV(event:Event) : void {
			action.axis = UVLinearEaseGlobalAction.V_AXIS;
			_u.value = false;
		}
		
		protected function changeU(event:Event) : void {
			_v.value = false;
			action.axis = UVLinearEaseGlobalAction.U_AXIS;
		}
		
		protected function change(event:Event) : void {
			action.scale = _scale.value;
			action.liearValue = _ease.value;
		}
		
		public function get action():UVLinearEaseGlobalAction {
			return _action;
		}

		public function set action(value:UVLinearEaseGlobalAction):void {
			_action = value;
			
			if (_action == null) {
				_scale.enabled = false;
				_ease.enabled = false;
				_u.enabled = false;
				_v.enabled = false;
				_check.value = false;
				accordion.open = false;
			} else {
				_scale.enabled = true;
				_ease.enabled = true;
				_u.enabled = true;
				_v.enabled = true;
				_check.value = true;
				
				_scale.value = action.scale;
				_ease.value = action.liearValue;
				if (action.axis == UVLinearEaseGlobalAction.U_AXIS) {
					_u.value = true;
					_v.value = false;
				} else {
					_u.value = false;
					_v.value = true;
				}
			}
		}
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new UVLinearEaseGlobalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, UVLinearEaseGlobalAction) as UVLinearEaseGlobalAction;
		}

	}
}
