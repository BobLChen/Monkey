package ide.plugins.groups.particles.shape {

	import flash.events.Event;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.shape.BoxShape;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Label;
	import ui.core.controls.Layout;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	/**
	 * 盒子发射器 
	 * @author Neil
	 * 
	 */	
	public class BoxShapeGroup extends Layout {
		
		private var box  	: BoxShape;
		private var particle: ParticleSystem;
		private var minx	: Spinner;
		private var miny	: Spinner;
		private var minz	: Spinner;
		
		private var maxx	: Spinner;
		private var maxy	: Spinner;
		private var maxz	: Spinner;
		
		private var smooth  : CheckBox;
		private var random	: CheckBox;
		
		public function BoxShapeGroup() {
			super();
			this.labelWidth = 100;
			
			this.addHorizontalGroup();
			this.addControl(new Label("Min"));
			this.minx = this.addControl(new Spinner()) as Spinner;
			this.miny = this.addControl(new Spinner()) as Spinner;
			this.minz = this.addControl(new Spinner()) as Spinner;
			this.endGroup();
			this.addHorizontalGroup();
			this.addControl(new Label("Max"));
			this.maxx = this.addControl(new Spinner()) as Spinner;
			this.maxy = this.addControl(new Spinner()) as Spinner;
			this.maxz = this.addControl(new Spinner()) as Spinner;
			this.endGroup();
			this.smooth = this.addControl(new CheckBox(), "Smooth") as CheckBox;
			this.random = this.addControl(new CheckBox(), "Random") as CheckBox;
			
			this.maxHeight = 100;
			this.minHeight = 100;
			
			this.minx.addEventListener(ControlEvent.CHANGE, change);
			this.miny.addEventListener(ControlEvent.CHANGE, change);
			this.minz.addEventListener(ControlEvent.CHANGE, change);
			this.maxx.addEventListener(ControlEvent.CHANGE, change);
			this.maxy.addEventListener(ControlEvent.CHANGE, change);
			this.maxz.addEventListener(ControlEvent.CHANGE, change);
			this.smooth.addEventListener(ControlEvent.CHANGE, change);
			this.random.addEventListener(ControlEvent.CHANGE, change);
		}
		
		private function change(event:Event) : void {
			this.box.min.x  = minx.value;
			this.box.min.y  = miny.value;
			this.box.min.z  = minz.value;
			this.box.max.x  = maxx.value;
			this.box.max.y  = maxy.value;
			this.box.max.z  = maxz.value;
			this.box.smooth = this.smooth.value;
			this.box.random = this.random.value;
			this.particle.build();
		}
		
		public function update(shape : BoxShape, particle : ParticleSystem) : void {
			this.box = shape;
			this.particle = particle;
			this.minx.value = box.min.x
			this.miny.value = box.min.y;
			this.minz.value = box.min.z;
			this.maxx.value = box.max.x
			this.maxy.value = box.max.y;
			this.maxz.value = box.max.z;
			this.smooth.value = box.smooth;
			this.random.value = box.random;
		}
		
	}
}
