package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.circle.CirCleLocalAction;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class CircleLoaclActionGroup extends ParticlesProperties {

		private var _action : CirCleLocalAction;
		
		private var _rotX : Spinner;
		private var _rotY : Spinner;
		private var _rotZ : Spinner;
		private var _minDegree : Spinner;
		private var _maxDegree : Spinner;
		private var _minRadius : Spinner;
		private var _maxRadius : Spinner;
		
		public function CircleLoaclActionGroup() {
			super("CircleLoaclAction");
			enableCheck = true;
			layout.addHorizontalGroup("Rotation:");
			_rotX = layout.addControl(new Spinner()) as Spinner;
			_rotY = layout.addControl(new Spinner()) as Spinner;
			_rotZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("Degree:");
			_minDegree = layout.addControl(new Spinner()) as Spinner;
			_maxDegree = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("Radius:");
			_minRadius = layout.addControl(new Spinner()) as Spinner;
			_maxRadius = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			
			_minDegree.addEventListener(ControlEvent.STOP, changeDegRad);
			_maxDegree.addEventListener(ControlEvent.STOP, changeDegRad);
			_minRadius.addEventListener(ControlEvent.STOP, changeDegRad);
			_maxRadius.addEventListener(ControlEvent.STOP, changeDegRad);
			
			_rotX.addEventListener(ControlEvent.STOP, changeAxis);
			_rotY.addEventListener(ControlEvent.STOP, changeAxis);
			_rotZ.addEventListener(ControlEvent.STOP, changeAxis);
		}
		
		protected function changeAxis(event:Event) : void {
			action.eulers = new Vector3D(_rotX.value, _rotY.value, _rotZ.value);
		}
		
		protected function changeDegRad(event:Event) : void {
			action.minDegree = _minDegree.value;
			action.maxDegree = _maxDegree.value;
			action.minRadius = _minRadius.value;
			action.maxRadius = _maxRadius.value;
			_particles.build();
		}
		
		public function get action():CirCleLocalAction {
			return _action;
		}

		public function set action(value:CirCleLocalAction):void {
			_action = value;
			
			if (_action == null) {
				_rotX.enabled = false;
				_rotY.enabled = false;
				_rotZ.enabled = false;
				_minDegree.enabled = false;
				_maxDegree.enabled = false;
				_minRadius.enabled = false;
				_maxRadius.enabled = false;
				_check.value = false;
				accordion.open = false;
			} else {
				_rotX.enabled = true;
				_rotY.enabled = true;
				_rotZ.enabled = true;
				_minDegree.enabled = true;
				_maxDegree.enabled = true;
				_minRadius.enabled = true;
				_maxRadius.enabled = true;
				_check.value = true;
				
				_rotX.value = action.eulers.x;
				_rotY.value = action.eulers.y;
				_rotZ.value = action.eulers.z;
				
				_minDegree.value = action.minDegree;
				_maxDegree.value = action.maxDegree;
				_minRadius.value = action.minRadius;
				_maxRadius.value = action.maxRadius;
			}
			
		}

		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (action == null) {
					_particles.addAction(new CirCleLocalAction());
				}
			} else {
				if (action != null) {
					_particles.removeAction(action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, CirCleLocalAction) as CirCleLocalAction;
		}
		
		
	}
}
