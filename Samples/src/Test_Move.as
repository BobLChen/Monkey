package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.Input3D;
	import monkey.core.utils.Object3DUtils;

	public class Test_Move extends Sprite {
		
		private var scene : Scene3D;
		private var cube  : Object3D;
		
		public function Test_Move() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -150;
			this.scene.camera.transform.y = 100;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			
			this.cube = new Object3D();
			this.cube.addComponent(new MeshRenderer(new Cube(), new ColorMaterial(Color.GRAY)));
			this.scene.addChild(cube);
			
			var plane : Object3D = new Object3D();
			plane.addComponent(new MeshRenderer(new Plane(500, 500, 1, "+xz"), new ColorMaterial(Color.WHITE)));
			this.scene.addChild(plane);
			
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, onUpdate);
		}
		
		private function onUpdate(event:Event) : void {
			if (Input3D.keyDown(Input3D.W)) {
				this.cube.transform.translateZ(1);
			}
			if (Input3D.keyDown(Input3D.S)) {
				this.cube.transform.translateZ(-1);
			}
			if (Input3D.keyDown(Input3D.A)) {
				this.cube.transform.rotateY(-3);
			}
			if (Input3D.keyDown(Input3D.D)) {
				this.cube.transform.rotateY(3);
			}
			
			Object3DUtils.setPositionWithReference(scene.camera, 0, 500, -300, cube, 0.025);
			Object3DUtils.lookAtWithReference(scene.camera, 0, 0, 0, cube);
		}
	}
}
