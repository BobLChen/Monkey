package ide.plugins.groups.particles {
	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.scale.ScaleGlobalAction;
	import L3D.core.shader.filters.particle.action.uv.UVSeqByLifeGlobalAction;
	
	import ide.App;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class UVMovieActionGroup extends ParticlesProperties {
		
		
		private var _action : UVSeqByLifeGlobalAction;
		private var _rows : Spinner;
		private var _columns : Spinner;
		
		public function UVMovieActionGroup() {
			super("UVMovieClipAction");
			enableCheck = true;
			accordion.contentHeight = 22;
			
			layout.addHorizontalGroup();
			_rows = layout.addControl(new Spinner(1, 1, 99999, 2, 1), "Rows:") as Spinner;
			_columns = layout.addControl(new Spinner(1, 1, 99999, 2, 1), "Columns:") as Spinner;
			
			_rows.addEventListener(ControlEvent.CHANGE, changeRowColumns);
			_columns.addEventListener(ControlEvent.CHANGE, changeRowColumns);
		}
		
		protected function changeRowColumns(event:Event) : void {
			_action.rows = _rows.value;
			_action.columns = _columns.value;
		}
		
		public function get action():UVSeqByLifeGlobalAction {
			return _action;
		}

		public function set action(value:UVSeqByLifeGlobalAction):void {
			_action = value;
			
			if (_action == null) {
				_rows.enabled = false;
				_columns.enabled = false;
				_check.value = false;
				accordion.open = false;
			} else {
				_rows.enabled = true;
				_columns.enabled = true;
				_check.value = true;
				
				_rows.value = _action.rows;
				_columns.value = _action.columns;
			}
		}

		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new UVSeqByLifeGlobalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(_action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, UVSeqByLifeGlobalAction) as UVSeqByLifeGlobalAction;
		}
		
	}
}
