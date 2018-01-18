package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.DiffuseMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.Texture3DUtils;

	public class Test_CustomMesh3D extends Sprite {
		
		private var scene : Scene3D;
		
		public function Test_CustomMesh3D() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.setPosition(0, 20, -30);
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			
			var surf : Surface3D = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
				-10, 0, 10,
				10, 0, 10,
				-10, 0, -10,
				10, 0, -10
			]), 3);
			surf.setVertexVector(Surface3D.UV0, Vector.<Number>([
				0, 0,
				1, 0,
				0, 1,
				1, 1
			]), 2);
			surf.setVertexVector(Surface3D.NORMAL, Vector.<Number>([
				0, 1, 0,
				0, 1, 0,
				0, 1, 0,
				0, 1, 0
			]), 3);
			
			surf.indexVector = Vector.<uint>([0, 1, 2, 1, 3, 2]);
			
			var obj : Object3D = new Object3D();
			obj.addComponent(new MeshRenderer(new Mesh3D([surf]), new DiffuseMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData))));
			
			this.scene.addChild(obj);
		}
	}
}
