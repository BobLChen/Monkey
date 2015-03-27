package blog.samples {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import monkey.core.animator.Animator;
	import monkey.core.animator.Label3D;
	import monkey.core.base.Object3D;
	import monkey.core.materials.SkeDifQuatMaterial;
	import monkey.core.renderer.SkeletonRenderer;
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
		
		private var obj	: Object3D;
		  
		public function Stage3d16() {  
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 15;
			
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;
			this.scene.camera.transform.z = -1000;
			
			this.obj = new Object3D();
			this.obj.addComponent(new SkeletonRenderer(Mesh3DUtils.readMesh(new MESH()), new SkeDifQuatMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData))));
			this.obj.addComponent(AnimUtil.readAnim(new ANIM()));
			this.obj.play(Animator.ANIMATION_LOOP_MODE);
			this.obj.animator.addLabel(new Label3D("1", 0, 60, 1));
			this.obj.animator.addLabel(new Label3D("2", 60, 120, 1));
			this.obj.animator.addLabel(new Label3D("3", 120, 180, 1));
			
			this.scene.addChild(obj);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent) : void {
			if (event.keyCode == Keyboard.NUMBER_1) {
				this.obj.animator.gotoAndPlay("1");
			} else if (event.keyCode == Keyboard.NUMBER_2) {
				this.obj.animator.gotoAndPlay("2");
			} else if (event.keyCode == Keyboard.NUMBER_3) {
				this.obj.animator.gotoAndPlay("3");
			}
		}
	}
}
