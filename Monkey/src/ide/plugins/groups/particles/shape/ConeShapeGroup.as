package ide.plugins.groups.particles.shape {

	import flash.events.Event;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.shape.ConeShape;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Layout;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	/**
	 * Cone发射器 
	 * @author Neil
	 * 
	 */	
	public class ConeShapeGroup extends Layout {
		
		private var height : Spinner;
		private var angle  : Spinner;
		private var radius : Spinner;
		private var shell  : CheckBox;
		private var volume : CheckBox;
		private var cone   : ConeShape;
		private var particle : ParticleSystem;
				
		public function ConeShapeGroup() {
			super();
			
			this.labelWidth = 60;
			this.height = this.addControl(new Spinner(), "Height") as Spinner;
			this.angle  = this.addControl(new Spinner(), "Angle")  as Spinner;
			this.radius = this.addControl(new Spinner(), "Radius") as Spinner;
			this.shell  = this.addControl(new CheckBox(), "Shell") as CheckBox;
			this.volume = this.addControl(new CheckBox(),"Volume") as CheckBox;
			this.maxHeight = 100;
			this.minHeight = 100;
			
			this.height.addEventListener(ControlEvent.CHANGE, change);
			this.angle.addEventListener(ControlEvent.CHANGE, change);
			this.radius.addEventListener(ControlEvent.CHANGE, change);
			this.shell.addEventListener(ControlEvent.CHANGE, change);
			this.volume.addEventListener(ControlEvent.CHANGE, change);
		}
		
		private function change(event:Event) : void {
			this.cone.angle 	= angle.value;
			this.cone.radius	= radius.value;
			this.cone.shell		= shell.value;
			this.cone.volume	= volume.value;
			this.cone.height	= height.value;
			this.particle.build();
		}
		
		public function update(shape : ConeShape, particle : ParticleSystem) : void {
			this.cone = shape;
			this.angle.value  = shape.angle;
			this.radius.value = shape.radius;
			this.shell.value  = shape.shell;
			this.volume.value = shape.volume;
			this.height.value = shape.height;
			this.particle = particle;
		}
		
	}
}
