package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.action.bezier.BezierCurvelGlobalAction;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class BezierGlobalGroup extends ParticlesProperties {
		
		private var _cx : Spinner;
		private var _cy : Spinner;
		private var _cz : Spinner;
		private var _ex : Spinner;
		private var _ey : Spinner;
		private var _ez : Spinner;
		
		private var _action : BezierCurvelGlobalAction;
		
		public function BezierGlobalGroup() {
			super("BezierGlobalAction");
			enableCheck = true;
			accordion.contentHeight = 40;
			layout.addHorizontalGroup("ControlPoint:");
			_cx = layout.addControl(new Spinner()) as Spinner;
			_cy = layout.addControl(new Spinner()) as Spinner;
			_cz = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("EndPoint:");
			_ex = layout.addControl(new Spinner()) as Spinner;
			_ey = layout.addControl(new Spinner()) as Spinner;
			_ez = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			
			_cx.addEventListener(ControlEvent.CHANGE, changeBezier);
			_cy.addEventListener(ControlEvent.CHANGE, changeBezier);
			_cz.addEventListener(ControlEvent.CHANGE, changeBezier);
			_ex.addEventListener(ControlEvent.CHANGE, changeBezier);
			_ey.addEventListener(ControlEvent.CHANGE, changeBezier);
			_ez.addEventListener(ControlEvent.CHANGE, changeBezier);
		}
		
		protected function changeBezier(event:Event) : void {
			_action.controlPoint = new Vector3D(_cx.value, _cy.value, _cz.value);
			_action.endPoint = new Vector3D(_ex.value, _ey.value, _ez.value);
		}
		
		public function get action():BezierCurvelGlobalAction {
			return _action;
		}

		public function set action(value:BezierCurvelGlobalAction):void {
			_action = value;
			
			if (_action == null) {
				_cx.enabled = false;
				_cy.enabled = false;
				_cz.enabled = false;
				_ex.enabled = false;
				_ey.enabled = false;
				_ez.enabled = false;
				_check.value = false;
				accordion.open = false;
			} else {
				_cx.enabled = true;
				_cy.enabled = true;
				_cz.enabled = true;
				_ex.enabled = true;
				_ey.enabled = true;
				_ez.enabled = true;
				_check.value = true;
				_cx.value = action.controlPoint.x;
				_cy.value = action.controlPoint.y;
				_cz.value = action.controlPoint.z;
				_ex.value = action.endPoint.x;
				_ey.value = action.endPoint.y;
				_ez.value = action.endPoint.z;
			}
			
		}

		override protected function changeCheck(event:Event):void {
			if (_check.value) {
				if (_action == null) {
					_particles.addAction(new BezierCurvelGlobalAction());
				}
			} else {
				if (_action != null) {
					_particles.removeAction(action);
				}
			}
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			action = ActionUtils.checkAction(particles, BezierCurvelGlobalAction) as BezierCurvelGlobalAction;
		}
		
		
		
	}
}
