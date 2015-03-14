package ide.plugins.groups.particles.shape {

	import flash.events.Event;
	
	import ide.App;
	import ide.panel.PivotTree;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.shape.BoxShape;
	import monkey.core.entities.particles.shape.ConeShape;
	import monkey.core.entities.particles.shape.MeshShape;
	import monkey.core.entities.particles.shape.ParticleShape;
	import monkey.core.entities.particles.shape.SphereShape;
	import monkey.core.entities.primitives.Plane;
	
	import ui.core.container.Accordion;
	import ui.core.controls.ComboBox;
	import ui.core.controls.InputText;
	import ui.core.controls.Layout;
	import ui.core.controls.Window;
	import ui.core.event.ControlEvent;
	
	/**
	 * shape 
	 * @author Neil
	 * 
	 */	
	public class ShapeGroup extends Accordion {
		
		private static const SPHERE : String = "Sphere";
		private static const BOX	: String = "Box";
		private static const CONE   : String = "Cone";
		private static const MESH	: String = "Mesh";
		
		public var app		: App;
		public var particle	: ParticleSystem;
		
		private var shapes	: ComboBox;
		private var mode	: InputText;
		private var header  : Layout;
		private var tree	: PivotTree;
		
		private var type	: String;
		private var sphere  : SphereShapeGroup;
		private var box		: BoxShapeGroup;
		private var cone	: ConeShapeGroup;
		private var mesh	: MeshShapeGroup;
		
		public function ShapeGroup() {
			super("Shape");
			this.header = new Layout();
			this.header.labelWidth = 100;
			this.shapes = new ComboBox([SPHERE, BOX, CONE, MESH], [SPHERE, BOX, CONE, MESH]);
			this.header.addControl(this.shapes, "Shape");
			this.mode = this.header.addControl(new InputText("Choose"), "Mode") as InputText;
			this.mode.textField.selectable = false;
			this.addControl(this.header);
			this.tree = new PivotTree();
			this.tree.width  	= 250;
			this.tree.height 	= 500;
			this.tree.minHeight = 500
			this.tree.addEventListener(ControlEvent.CLICK, choosedMode);
				
			this.sphere = new SphereShapeGroup();
			this.box	= new BoxShapeGroup();
			this.cone	= new ConeShapeGroup();
			this.mesh	= new MeshShapeGroup();
			
			this.open   = false;
			this.contentHeight = 200;
			this.mode.addEventListener(ControlEvent.CLICK, chooseMode);
			this.shapes.addEventListener(ControlEvent.CHANGE, onSelected);
		}
		
		private function onSelected(event:Event) : void {
			if (this.type == this.shapes.selectData) {
				return;
			}
			this.type = shapes.selectData as String;
			var mode : Surface3D = this.particle.shape.mode;
			var shape: ParticleShape = null;
			if (this.type == SPHERE) {
				shape = new SphereShape();
			} else if (this.type == BOX) {
				shape = new BoxShape();
			} else if (this.type == CONE) {
				shape = new ConeShape();
			} else if (this.type == MESH) {
				shape = new MeshShape();
				(shape as MeshShape).surf = new Plane(1, 1, 1, "+xz").surfaces[0];
			}
			if (shape) {
				shape.mode = mode;
				this.particle.shape = shape;
				this.particle.build();
				this.updateGroup(this.app, this.particle);
				this.open = true;
			}
		}
		
		private function choosedMode(event:Event) : void {
			if (this.tree.selected.length >= 1) {
				var obj : Object3D = this.tree.selected[0];
				if (obj.renderer && obj.renderer.mesh && obj.renderer.mesh.surfaces.length >= 1) {
					Window.popWindow.visible = false;
					var surf : Surface3D = obj.renderer.mesh.surfaces[0].clone();
					this.particle.shape.mode = surf;
					this.particle.build();
				}
			}
		}
		
		private function chooseMode(event:Event) : void {
			Window.popWindow.window  = tree;
			Window.popWindow.visible = true;
			this.tree.pivot = App.core.scene;
			Window.popWindow.draw();
		}
		
		public function updateGroup(app : App, particle : ParticleSystem) : void {
			this.open 	  = false;
			this.app 	  = app;
			this.particle = particle;
			this.removeAllControls();
			this.addControl(this.header);
			
			if (particle.shape is SphereShape) {
				this.sphere.update(particle.shape as SphereShape, particle);
				this.addControl(this.sphere);
				this.type = SPHERE;
			} else if (particle.shape is BoxShape) {
				this.box.update(particle.shape as BoxShape, particle);
				this.addControl(this.box);
				this.type = BOX;
			} else if (particle.shape is ConeShape) {
				this.cone.update(particle.shape as ConeShape, particle);
				this.addControl(this.cone);
				this.type = CONE;
			} else if (particle.shape is MeshShape) {
				this.mesh.update(particle.shape as MeshShape, particle);
				this.addControl(this.mesh);
				this.type = MESH;
			}
			this.shapes.text = this.type;
		}
		
	}
}
