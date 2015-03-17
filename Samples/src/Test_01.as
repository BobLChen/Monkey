package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;

	public class Test_01 extends Sprite {
		
		private var scene : Scene3D;
		
		public function Test_01() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -50;
			this.scene.autoResize = true;
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Cube(), new ColorMaterial(Color.GRAY)));
			
			this.scene.addChild(cube);
		}
	}
}
