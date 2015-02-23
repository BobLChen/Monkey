package ide.plugins.groups.particles {
	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.rotation.RotateByLifeLocalAction;
	import L3D.core.shader.filters.particle.action.scale.ScaleGlobalAction;
	
	import ide.App;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class ScaleByTimeActionGroup extends ParticlesProperties {
		
		private var _min : Spinner;
		private var _max : Spinner;
		private var _degree : Spinner;
		private var _action : ScaleGlobalAction;
		
		public function ScaleByTimeActionGroup() {
			super("ScaleByTimeAction");
			enableCheck = true;
			accordion.contentHeight = 22;
			layout.addHorizontalGroup();
			layout.labelWidth = 45;
			_min = layout.addControl(new Spinner(), "Min:") as Spinner;
			_max = layout.addControl(new Spinner(), "Max:") as Spinner;
			_degree = layout.addControl(new Spinner(), "Degree:") as Spinner;
			
			_min.addEventListener(ControlEvent.CHANGE, change);
			_max.addEventListener(ControlEvent.CHANGE, change);
			_degree.addEventListener(ControlEvent.CHANGE, change);
		}
		
		public function get action():ScaleGlobalAction {
			return _action;
		}

		public function set action(value:ScaleGlobalAction):void {
			_action = value;
			if (_action == null) {
				_min.enabled = false;
				_max.enabled = false;
				_degree.enabled = false;
				_check.value = false;
				accordion.open = false;
			} else {
				_min.enabled = true;
				_max.enabled = true;
				_degree.enabled = true;
				_check.value = true;
				
				_min.value = action.startScale;
				_max.value = action.endScale;
				_degree.value = action.degree;
			}
		}

		protected function change(event:Event) : void {
			action.startScale = _min.value;
			action.endScale = _max.value;
			action.degree = _degree.value;
		}
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new ScaleGlobalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, ScaleGlobalAction) as ScaleGlobalAction;
		}
		
		
	}
}
