package ide.plugins.groups.particles {
	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.scale.ScaleByLifeGlobalAction;
	
	import ide.App;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class ScaleByLifeGlobalGroup extends ParticlesProperties {
		
		
		private var _action : ScaleByLifeGlobalAction;
		
		private var _startScale : Spinner;
		private var _endScale : Spinner;
		
		public function ScaleByLifeGlobalGroup() {
			super("ScaleByLifeGlobalAction");
			enableCheck = true;
			accordion.contentHeight = 22;
			layout.labelWidth = 70;
			layout.addHorizontalGroup();
			_startScale = layout.addControl(new Spinner(), "StartScale:") as Spinner;
			_endScale = layout.addControl(new Spinner(), "EndScale:") as Spinner;
			layout.endGroup();
			
			_startScale.addEventListener(ControlEvent.CHANGE, changeScale);
			_endScale.addEventListener(ControlEvent.CHANGE, changeScale);
		}
		
		protected function changeScale(event:Event) : void {
			action.endScale = _endScale.value;
			action.startScale = _startScale.value;
		}
		
		public function get action():ScaleByLifeGlobalAction {
			return _action;
		}

		public function set action(value:ScaleByLifeGlobalAction):void {
			_action = value;
			
			if (_action == null) {
				_startScale.enabled = false;
				_endScale.enabled = false;
				_check.value = false;
			} else {
				_startScale.enabled = true;
				_endScale.enabled = true;
				_check.value = true;
				_endScale.value = action.endScale;
				_startScale.value = action.startScale;
			}
		}
		
		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (action == null) {
					_particles.addAction(new ScaleByLifeGlobalAction());
				}
			} else {
				if (action != null) {
					_particles.removeAction(action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, ScaleByLifeGlobalAction) as ScaleByLifeGlobalAction;
		}
		
		
		
	}
}
