package ide.plugins.groups.particles.shape {

	import flash.events.Event;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.shape.SphereShape;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Layout;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	/**
	 * 圆形shape 
	 * @author Neil
	 * 
	 */	
	public class SphereShapeGroup extends Layout {
		
		private var sphere 	: SphereShape;
		private var particle: ParticleSystem;
		private var radius 	: Spinner;
		private var hemi   	: CheckBox;
		private var shell  	: CheckBox;
		private var random 	: CheckBox;
		
		public function SphereShapeGroup() {
			super();
			this.labelWidth = 100;
			this.radius = this.addControl(new Spinner(1, 0, 9999999, 2, 0), "Radius") as Spinner;
			this.hemi	= this.addControl(new CheckBox(), "HemiSphere") as CheckBox;
			this.shell  = this.addControl(new CheckBox(), "Emit from shell") as CheckBox;
			this.random = this.addControl(new CheckBox(), "RandomDirection") as CheckBox;
			
			this.radius.addEventListener(ControlEvent.CHANGE, change);
			this.hemi.addEventListener(ControlEvent.CHANGE,   change);
			this.shell.addEventListener(ControlEvent.CHANGE,  change);
			this.random.addEventListener(ControlEvent.CHANGE, change);
		}
		
		private function change(event:Event) : void {
			this.sphere.radius = this.radius.value;
			this.sphere.hemi   = this.hemi.value;
			this.sphere.random = this.random.value;
			this.sphere.shell  = this.shell.value;
			this.particle.build();
		}
		
		public function update(shape : SphereShape, particle : ParticleSystem) : void {
			this.sphere = shape;
			this.particle = particle;
			this.shell.value = shape.shell;
			this.radius.value= shape.radius;
			this.hemi.value  = shape.hemi;
			this.random.value= shape.random;
		}
		
	}
}
