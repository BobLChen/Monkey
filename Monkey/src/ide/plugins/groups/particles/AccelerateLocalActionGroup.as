package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.acceleration.AccelerateLocalAction;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class AccelerateLocalActionGroup extends ParticlesProperties {
		
		
		private var _minX : Spinner;
		private var _minY : Spinner;
		private var _minZ : Spinner;
		private var _maxX : Spinner;
		private var _maxY : Spinner;
		private var _maxZ : Spinner;
		private var _minPow : Spinner;
		private var _maxPow : Spinner;
		private var _action : AccelerateLocalAction;
		private var _app : App;
				
		public function AccelerateLocalActionGroup() {
			super("AccelerateLocalAction");
			enableCheck = true;
			accordion.contentHeight = 60;
			layout.maxHeight = 60;
			layout.addHorizontalGroup("Min:");
			_minX = layout.addControl(new Spinner()) as Spinner;
			_minY = layout.addControl(new Spinner()) as Spinner;
			_minZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("Max:");
			_maxX = layout.addControl(new Spinner()) as Spinner;
			_maxY = layout.addControl(new Spinner()) as Spinner;
			_maxZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("Pow:");
			_minPow = layout.addControl(new Spinner()) as Spinner;
			_maxPow = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			
			_minX.addEventListener(ControlEvent.STOP, changeAccelerate);
			_minY.addEventListener(ControlEvent.STOP, changeAccelerate);
			_minZ.addEventListener(ControlEvent.STOP, changeAccelerate);
			_maxX.addEventListener(ControlEvent.STOP, changeAccelerate);
			_maxY.addEventListener(ControlEvent.STOP, changeAccelerate);
			_maxZ.addEventListener(ControlEvent.STOP, changeAccelerate);
			_minPow.addEventListener(ControlEvent.STOP, changeAccelerate);
			_maxPow.addEventListener(ControlEvent.STOP, changeAccelerate);
		}
		
		protected function changeAccelerate(event:Event) : void {
			_action.minAccelerate = new Vector3D(_minX.value, _minY.value, _minZ.value, _minPow.value);
			_action.maxAccelerate = new Vector3D(_maxX.value, _maxY.value, _maxZ.value, _maxPow.value);
			_particles.build();
		}
		
		public function get action():AccelerateLocalAction {
			return _action;
		}

		public function set action(value:AccelerateLocalAction):void {
			_action = value;
			if (_action != null) {
				_check.value = true;
				_minX.enabled= true;
				_minY.enabled = true;
				_minZ.enabled = true;
				_maxX.enabled = true;
				_maxY.enabled = true;
				_maxZ.enabled = true;
				_minPow.enabled = true;
				_maxPow.enabled = true;
				_minX.value = _action.minAccelerate.x;
				_minY.value = _action.minAccelerate.y;
				_minZ.value = _action.minAccelerate.z;
				_maxX.value = _action.maxAccelerate.x;
				_maxY.value = _action.maxAccelerate.y;
				_maxZ.value = _action.maxAccelerate.z;
				_minPow.value = _action.minAccelerate.w;
				_maxPow.value = _action.maxAccelerate.w;
			} else {
				_check.value = false;
				accordion.open = false;
				_minX.enabled= false;
				_minY.enabled = false;
				_minZ.enabled = false;
				_maxX.enabled = false;
				_maxY.enabled = false;
				_maxZ.enabled = false;
				_minPow.enabled = false;
				_maxPow.enabled = false;
			}
		}

		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_action = new AccelerateLocalAction();
					_particles.addAction(_action);
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, AccelerateLocalAction) as AccelerateLocalAction;
		}
		
		
		
	}
}
