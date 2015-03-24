package blog.samples {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import monkey.core.animator.Animator;
	import monkey.core.base.Object3D;
	import monkey.core.materials.SkeDifQuatMaterial;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.Mesh3DUtils;
	import monkey.core.utils.Texture3DUtils;

	public class Stage3d16 extends Sprite {
		
		private var scene : Scene3D;
		
		[Embed(source="irelia_transformIrelia.mesh", mimeType="application/octet-stream")]
		private var MESH : Class;
		[Embed(source="irelia_transformIrelia.anim", mimeType="application/octet-stream")]
		private var ANIM : Class; 
		  
		public function Stage3d16() {  
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 15;
			
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;
			this.scene.camera.transform.z = -1000;
			
			var obj : Object3D = Mesh3DUtils.readMesh(new MESH());
			obj.renderer.material = new SkeDifQuatMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData));
			obj.addComponent(AnimUtil.readAnim(new ANIM()));
			obj.play(Animator.ANIMATION_LOOP_MODE);
			
			this.scene.addChild(obj);
		}
	}
}
