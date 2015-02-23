package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.position.OffsetPositionLocalAction;
	
	import ide.App;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class OffsetPositionGroup extends ParticlesProperties {
		
		
		private var _action : OffsetPositionLocalAction;
		
		private var _minX : Spinner;
		private var _minY : Spinner;
		private var _minZ : Spinner;
		private var _maxX : Spinner;
		private var _maxY : Spinner;
		private var _maxZ : Spinner;
		private var _random : CheckBox;
				
		public function OffsetPositionGroup() {
			super("OffsetPositionAction");
			
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
			_random = layout.addControl(new CheckBox(), "Random") as CheckBox;
			
			_minX.addEventListener(ControlEvent.STOP, changePosition);
			_minY.addEventListener(ControlEvent.STOP, changePosition);
			_minZ.addEventListener(ControlEvent.STOP, changePosition);
			_maxX.addEventListener(ControlEvent.STOP, changePosition);
			_maxY.addEventListener(ControlEvent.STOP, changePosition);
			_maxZ.addEventListener(ControlEvent.STOP, changePosition);
			_random.addEventListener(ControlEvent.CHANGE, changePosition);
		}
		
		protected function changePosition(event:Event) : void {
			action.minPos = new Vector3D(_minX.value, _minY.value, _minZ.value);
			action.maxPos = new Vector3D(_maxX.value, _maxY.value, _maxZ.value);
			action.random = _random.value;
			_particles.build();
		}
		
		public function get action():OffsetPositionLocalAction {
			return _action;
		}

		public function set action(value:OffsetPositionLocalAction):void {
			_action = value;
			
			if (_action == null) {
				_check.value = false;
				accordion.open = false;
				_minX.enabled = false;
				_minY.enabled = false;
				_minZ.enabled = false;
				_maxX.enabled = false;
				_maxY.enabled = false;
				_maxZ.enabled = false;
			} else {
				_check.value = true;
				_minX.enabled = true;
				_minY.enabled = true;
				_minZ.enabled = true;
				_maxX.enabled = true;
				_maxY.enabled = true;
				_maxZ.enabled = true;
				
				_minX.value = action.minPos.x;
				_minY.value = action.minPos.y;
				_minZ.value = action.minPos.z;
				_maxX.value = action.maxPos.x;
				_maxY.value = action.maxPos.y;
				_maxZ.value = action.maxPos.z;
				_random.value = action.random;
			}
			
		}

		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new OffsetPositionLocalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, OffsetPositionLocalAction) as OffsetPositionLocalAction;
		}
		
		
		
	}
}
