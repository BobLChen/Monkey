package monkey.core.entities {
	
	import flash.display3D.Context3DCompareMode;
	
	import monkey.core.renderer.MeshRenderer;
	
	public class Axis3D extends Lines3D {
				
		public function Axis3D() {
			super();
			this.lineStyle(1, 0xFF0000);
			this.moveTo(0, 0, 0);
			this.lineTo(20, 0, 0);
			this.lineStyle(1, 0x00FF00);
			this.moveTo(0, 0, 0);
			this.lineTo(0, 20, 0);
			this.lineStyle(1, 0x0000ff);
			this.moveTo(0, 0, 0);
			this.lineTo(0, 0, 20);
			var renderer : MeshRenderer = getComponent(MeshRenderer) as MeshRenderer;
			renderer.material.depthWrite = false;
			renderer.material.depthCompare = Context3DCompareMode.ALWAYS;
		}
		
	}
}
