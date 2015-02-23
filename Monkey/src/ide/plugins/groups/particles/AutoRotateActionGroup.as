package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.rotation.AutoRotateGlobalAction;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class AutoRotateActionGroup extends ParticlesProperties {
		
		private var _axisX : Spinner;
		private var _axisY : Spinner;
		private var _axisZ : Spinner;
		private var _degree : Spinner;
		
		private var _action : AutoRotateGlobalAction;
		
		public function AutoRotateActionGroup() {
			super("AutoRotateAction");
			enableCheck = true;
			accordion.contentHeight = 44;
			layout.addHorizontalGroup("Axis:");
			_axisX = layout.addControl(new Spinner()) as Spinner;
			_axisY = layout.addControl(new Spinner()) as Spinner;
			_axisZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			_degree = layout.addControl(new Spinner(), "Degree:") as Spinner;
			
			_axisX.addEventListener(ControlEvent.CHANGE, changeRotate);
			_axisY.addEventListener(ControlEvent.CHANGE, changeRotate);
			_axisZ.addEventListener(ControlEvent.CHANGE, changeRotate);
			_degree.addEventListener(ControlEvent.CHANGE, changeRotate);
		}
		
		public function get action():AutoRotateGlobalAction {
			return _action;
		}

		public function set action(value:AutoRotateGlobalAction):void {
			_action = value;
			
			if (_action == null) {
				_axisX.enabled = false;
				_axisY.enabled = false;
				_axisZ.enabled = false;
				_degree.enabled = false;
				_check.value = false;
				accordion.open = false;
			} else {
				_check.value = true;
				_axisX.enabled = true;
				_axisY.enabled = true;
				_axisZ.enabled = true;
				_degree.enabled = true;
				
				_axisX.value = action.axis.x;
				_axisX.value = action.axis.x;
				_axisX.value = action.axis.x;
				_degree.value = action.degree;
			}
		}

		protected function changeRotate(event:Event) : void {
			action.axis = new Vector3D(_axisX.value, _axisY.value, _axisZ.value);
			action.degree = _degree.value;
		}
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new AutoRotateGlobalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, AutoRotateGlobalAction) as AutoRotateGlobalAction;
		}
		
		
	}
}
