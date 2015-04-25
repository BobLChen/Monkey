package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.Object3DUtils;

	public class Test_Rect3D extends Sprite {
		
		private var scene : Scene3D;
		
		public function Test_Rect3D() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.setPosition(0, 20, -30);
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Cube(), new ColorMaterial(Color.GRAY)));
			
			this.scene.addChild(cube);
			
			cube.addEventListener(Object3D.ENTER_DRAW_EVENT, function(e:Event):void {
				cube.transform.rotateY(1);
				graphics.clear();
				var rect : Rectangle = Object3DUtils.getScreenRect(cube.renderer.mesh.bounds, cube.transform.world);
				graphics.lineStyle(1, 0xFF0000);
				graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			});
		}
	}
}
