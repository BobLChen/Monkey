package ide.plugins.groups.particles.shape {

	import flash.events.Event;
	
	import ide.App;
	import ide.panel.PivotTree;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.shape.MeshShape;
	
	import ui.core.controls.ComboBox;
	import ui.core.controls.InputText;
	import ui.core.controls.Layout;
	import ui.core.controls.Window;
	import ui.core.event.ControlEvent;

	public class MeshShapeGroup extends Layout {
		
		private var type 	 : ComboBox;
		private var mesh 	 : InputText;
		private var meshShape: MeshShape;
		private var particle : ParticleSystem;
		private var tree	 : PivotTree;
		
		public function MeshShapeGroup() {
			super();
			
			this.type = this.addControl(
				new ComboBox(
					["Vertex", "Triangle", "Edge"], 
					[MeshShape.TYPE_VERTEX, MeshShape.TYPE_TRIANGLE, MeshShape.TYPE_EDGE]), 
				"Emit from") as ComboBox;
			this.mesh = this.addControl(new InputText("Choose"), "Mesh") as InputText;
			this.mesh.textField.selectable = false;
			this.tree = new PivotTree();
			this.tree.width  	= 250;
			this.tree.height 	= 500;
			this.tree.minHeight = 500
			this.tree.addEventListener(ControlEvent.CLICK, choosedMesh);
			
			this.type.addEventListener(ControlEvent.CHANGE, change);
			this.mesh.addEventListener(ControlEvent.CLICK, chooseMesh);
		}
		
		private function choosedMesh(event:Event) : void {
			if (this.tree.selected.length >= 1) {
				var obj : Object3D = this.tree.selected[0];
				if (obj.renderer && obj.renderer.mesh && obj.renderer.mesh.surfaces.length >= 1) {
					Window.popWindow.visible = false;
					this.meshShape.surf = obj.renderer.mesh.surfaces[0].clone();
					this.particle.build();
				}
			}
		}
		
		private function chooseMesh(event:Event) : void {
			Window.popWindow.window  = tree;
			Window.popWindow.visible = true;
			this.tree.pivot = App.core.scene;
			Window.popWindow.draw();
		}
		
		private function change(event:Event) : void {
			this.meshShape.type = this.type.selectData as int;
			this.particle.build();
		}
		
		public function update(shape : MeshShape, particle : ParticleSystem) : void {
			this.particle  = particle;
			this.meshShape = shape;
			if (shape.type == MeshShape.TYPE_VERTEX) {
				this.type.text = "Vertex";
			} else if (shape.type == MeshShape.TYPE_TRIANGLE) {
				this.type.text = "Triangle";
			} else if (shape.type == MeshShape.TYPE_EDGE) {
				this.type.text = "Edge";
			}
		}
		
	}
}
