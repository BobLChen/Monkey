package ide.plugins.groups.particles {
	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.rotation.RotateByLifeLocalAction;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class RotateByLifeActionGroup extends ParticlesProperties {
		
		private var _minAxisX : Spinner;
		private var _minAxisY : Spinner;
		private var _minAxisZ : Spinner;
		private var _maxAxisX : Spinner;
		private var _maxAxisY : Spinner;
		private var _maxAxisZ : Spinner;
		private var _minAngle : Spinner;
		private var _maxAngle : Spinner;
		
		private var _action : RotateByLifeLocalAction;
				
		public function RotateByLifeActionGroup() {
			super("RotateByLifeLocalAction");
			
			accordion.contentHeight = 80;
			enableCheck = true;
			layout.addHorizontalGroup("MinAxis:");
			_minAxisX = layout.addControl(new Spinner()) as Spinner;
			_minAxisY = layout.addControl(new Spinner()) as Spinner;
			_minAxisZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("MaxAxis:");
			_maxAxisX = layout.addControl(new Spinner()) as Spinner;
			_maxAxisY = layout.addControl(new Spinner()) as Spinner;
			_maxAxisZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			_minAngle = layout.addControl(new Spinner(), "MinAngle:") as Spinner;
			_maxAngle = layout.addControl(new Spinner(), "MaxAngle:") as Spinner;
			
			_minAxisX.addEventListener(ControlEvent.STOP, changeRotate);
			_minAxisY.addEventListener(ControlEvent.STOP, changeRotate);
			_minAxisZ.addEventListener(ControlEvent.STOP, changeRotate);
			_maxAxisX.addEventListener(ControlEvent.STOP, changeRotate);
			_maxAxisY.addEventListener(ControlEvent.STOP, changeRotate);
			_maxAxisZ.addEventListener(ControlEvent.STOP, changeRotate);
			_minAngle.addEventListener(ControlEvent.STOP, changeRotate);
			_maxAngle.addEventListener(ControlEvent.STOP, changeRotate);
			
		}
		
		public function get action():RotateByLifeLocalAction {
			return _action;
		}

		public function set action(value:RotateByLifeLocalAction):void {
			_action = value;
			
			if (_action == null) {
				_check.value = false;
				accordion.open = false;
				_minAxisX.enabled = false;
				_minAxisY.enabled = false;
				_minAxisZ.enabled = false;
				_maxAxisX.enabled = false;
				_maxAxisY.enabled = false;
				_maxAxisZ.enabled = false;
				_minAngle.enabled = false;
				_maxAngle.enabled = false;
			} else {
				_minAxisX.enabled = true;
				_minAxisY.enabled = true;
				_minAxisZ.enabled = true;
				_maxAxisX.enabled = true;
				_maxAxisY.enabled = true;
				_maxAxisZ.enabled = true;
				_minAngle.enabled = true;
				_maxAngle.enabled = true;
				_check.value = true;
				
				_minAxisX.value = action.minAxis.x;
				_minAxisY.value = action.minAxis.y;
				_minAxisZ.value = action.minAxis.z;
				_maxAxisX.value = action.maxAxis.x;
				_maxAxisY.value = action.maxAxis.y;
				_maxAxisZ.value = action.maxAxis.z;
				_minAngle.value = action.minAngle;
				_maxAngle.value = action.maxAngle;
			}
		}

		protected function changeRotate(event:Event) : void {
			action.minAxis.x = _minAxisX.value;
			action.minAxis.y = _minAxisY.value;
			action.minAxis.z = _minAxisZ.value;
			action.maxAxis.x = _maxAxisX.value;
			action.maxAxis.y = _maxAxisY.value;
			action.maxAxis.z = _maxAxisZ.value;
			action.minAngle = _minAngle.value;
			action.maxAngle = _maxAngle.value;
			
			_particles.build();
		}		
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new RotateByLifeLocalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, RotateByLifeLocalAction) as RotateByLifeLocalAction;
		}
		
	}
}
