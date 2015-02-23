package ide.plugins.groups.particles {

	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	
	import ide.App;
	import ui.core.container.Accordion;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Layout;
	import ui.core.event.ControlEvent;

	public class ParticlesProperties {

		public var accordion : Accordion;
		public var layout : Layout;
		
		protected var _check : CheckBox;
		protected var _particles : Particles3D;
		protected var _app : App;
		
		private var _enableCheck : Boolean;

		public function ParticlesProperties(name : String, scroll : Boolean = false) {
			this.layout = new Layout(scroll);
			this.layout.height = 1000;
			this.layout.labelWidth = 90;
			this.layout.margins = 0;
			this.layout.space = 0;
			this._check = new CheckBox();
			this._check.width = 20;
			this.accordion = new Accordion(name);
			this.accordion.view.addChild(this._check.view);
			this.accordion.addControl(this.layout);
			this.accordion.addEventListener(ControlEvent.DRAW, onDraw);
			this.enableCheck = false;
			this._check.addEventListener(ControlEvent.CHANGE, changeCheck);
		}
		
		protected function changeCheck(event:Event) : void {
						
		}
		
		public function get enableCheck():Boolean {
			return _enableCheck;
		}

		public function set enableCheck(value:Boolean):void {
			_enableCheck = value;
			this._check.visible = value;
		}

		private function onDraw(event:Event) : void {
			this._check.x = accordion.width - this._check.width;
		}
		
		public function update(particles : Particles3D, app : App) : void {
			_particles = particles;
			_app = app;
		}

	}
}
