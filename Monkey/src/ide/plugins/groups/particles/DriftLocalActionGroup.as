package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.drift.DriftLocalAction;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class DriftLocalActionGroup extends ParticlesProperties {

		
		private var _minX : Spinner;
		private var _minY : Spinner;
		private var _minZ : Spinner;
		private var _maxX : Spinner;
		private var _maxY : Spinner;
		private var _maxZ : Spinner;
		private var _minDeg : Spinner;
		private var _maxDeg : Spinner;
		
		private var _action : DriftLocalAction;
		
		public function DriftLocalActionGroup() {
			super("DriftLocalAction");
			enableCheck = true;
			accordion.contentHeight = 64;
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
			layout.addHorizontalGroup("Degree:");
			_minDeg = layout.addControl(new Spinner()) as Spinner;
			_maxDeg = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			
			_minX.addEventListener(ControlEvent.STOP, changeDrift);
			_minY.addEventListener(ControlEvent.STOP, changeDrift);
			_minZ.addEventListener(ControlEvent.STOP, changeDrift);
			_maxX.addEventListener(ControlEvent.STOP, changeDrift);
			_maxY.addEventListener(ControlEvent.STOP, changeDrift);
			_maxZ.addEventListener(ControlEvent.STOP, changeDrift);
			_minDeg.addEventListener(ControlEvent.STOP, changeDrift);
			_maxDeg.addEventListener(ControlEvent.STOP, changeDrift);
		}
		
		public function get action():DriftLocalAction {
			return _action;
		}

		public function set action(value:DriftLocalAction):void {
			_action = value;
			
			if (_action == null) {
				accordion.open = false;
				_check.value = false;
				_minX.enabled = false;
				_minY.enabled = false;
				_minZ.enabled = false;
				_maxX.enabled = false;
				_maxY.enabled = false;
				_maxZ.enabled = false;
				_minDeg.enabled = false;
				_maxDeg.enabled = false;
			} else {
				_check.value = true;
				_minX.enabled = true;
				_minY.enabled = true;
				_minZ.enabled = true;
				_maxX.enabled = true;
				_maxY.enabled = true;
				_maxZ.enabled = true;
				_minDeg.enabled = true;
				_maxDeg.enabled = true;
				
				_minX.value = action.minDrift.x;
				_minY.value = action.minDrift.y;
				_minZ.value = action.minDrift.z;
				_maxX.value = action.maxDrift.x;
				_maxY.value = action.maxDrift.y;
				_maxZ.value = action.maxDrift.z;
				_minDeg.value = action.minDrift.w;
				_maxDeg.value = action.maxDrift.w;
			}
		}

		protected function changeDrift(event:Event) : void {
			_action.minDrift = new Vector3D(_minX.value, _minY.value, _minZ.value, _minDeg.value);
			_action.maxDrift = new Vector3D(_maxX.value, _maxY.value, _maxZ.value, _maxDeg.value);
			_particles.build();
		}
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new DriftLocalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, DriftLocalAction) as DriftLocalAction;
		}
		
	}
}
