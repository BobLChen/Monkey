package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.Mesh3DUtils;

	public class Test_02 extends Sprite {
		
		[Embed(source="../assets/test_02/xiaonan_boo1.mesh", mimeType="application/octet-stream")]
		private var DATA : Class;
		
		private var scene : Scene3D;
				
		public function Test_02() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var obj : Object3D = new Object3D();
			obj.addComponent(new MeshRenderer(Mesh3DUtils.readMesh(new DATA()), new ColorMaterial(Color.GRAY)));
						
			obj.addEventListener(Object3D.ENTER_DRAW_EVENT, function(e:Event):void{
				obj.transform.rotateY(2);
			});
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -150;
			this.scene.camera.transform.y = 100;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			this.scene.addChild(obj);
		}
	}
}
