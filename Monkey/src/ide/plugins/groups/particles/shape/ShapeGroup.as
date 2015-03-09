package ide.plugins.groups.particles.shape {

	import ide.App;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.shape.SphereShape;
	
	import ui.core.container.Accordion;
	import ui.core.controls.ComboBox;
	import ui.core.controls.Layout;
	
	/**
	 * shape 
	 * @author Neil
	 * 
	 */	
	public class ShapeGroup extends Accordion {
		
		
		public var app		: App;
		public var particle	: ParticleSystem;
		
		private var shapes	: ComboBox;
		private var header  : Layout;
		private var sphere  : SphereShapeGroup;
		
		public function ShapeGroup() {
			super("Shape");
			this.header = new Layout();
			this.header.maxHeight = 20;
			this.header.labelWidth = 100;
			this.shapes = new ComboBox(["Sphere"], ["Sphere"]);
			this.header.addControl(this.shapes, "Shape");
			this.addControl(this.header);
			this.sphere = new SphereShapeGroup();
		}
		
		public function updateGroup(app : App, particle : ParticleSystem) : void {
			this.app = app;
			this.particle = particle;
			this.removeAllControls();
			this.addControl(this.header);
			
			if (particle.shape is SphereShape) {
				this.sphere.update(particle.shape as SphereShape, particle);
				this.addControl(this.sphere);
			}
		}
		
	}
}
