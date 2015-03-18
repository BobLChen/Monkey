package monkey.core.entities {

	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.LinesMesh;
	import monkey.core.materials.LineMaterial;
	import monkey.core.renderer.MeshRenderer;

	public class Lines3D extends Object3D {
		
		private var linesMesh : LinesMesh;
		
		public function Lines3D() {
			super();
			this.linesMesh = new LinesMesh();
			this.addComponent(new MeshRenderer(linesMesh, new LineMaterial()));
			this.setLayer(1000);
		}
		
		public function clear() : void {
			this.linesMesh.clear();
		}
		
		public function lineStyle(thickness : Number = 1, color : uint = 0xFFFFFF, alpha : Number = 1) : void {
			this.linesMesh.lineStyle(thickness, color, alpha);
		}
		
		public function moveTo(x : Number, y : Number, z : Number) : void { 
			this.linesMesh.moveTo(x, y, z);
		}
		
		public function lineTo(x : Number, y : Number, z : Number) : void {
			this.linesMesh.lineTo(x, y, z);
		}
		
	}
}
