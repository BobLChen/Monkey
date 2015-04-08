package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.utils.getTimer;
	
	import monkey.core.animator.Animator;
	import monkey.core.base.Object3D;
	import monkey.core.materials.SkeDifMatMaterial;
	import monkey.core.renderer.SkeletonRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Mesh3DUtils;

	public class Test_SkeletonMatrix extends Sprite {
		
		[Embed(source="../assets/test_05/xiaonan_boo1.mesh", mimeType="application/octet-stream")]
		private var DATA : Class;
		[Embed(source="../assets/test_05/xiaonan_boo1.anim", mimeType="application/octet-stream")]
		private var ANIM : Class;
		[Embed(source="../assets/test_05/xiaonan_boo1.jpg")]
		private var IMG  : Class;
		
		private var scene : Scene3D;
		
		public function Test_SkeletonMatrix() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.stage.addChild(new FPSStats());
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -1000;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true; 
			
			var t : int = getTimer();
			
			var obj : Object3D = new Object3D();
			obj.addComponent(new SkeletonRenderer(Mesh3DUtils.readMesh(new DATA()), new SkeDifMatMaterial(new Bitmap2DTexture(new IMG().bitmapData))));
			obj.addComponent(AnimUtil.readAnim(new ANIM()));
			obj.play(Animator.ANIMATION_LOOP_MODE);
						
			trace(getTimer() - t);
			
			var num : int = 30;
			for (var i:int = 0; i < num; i++) {
				for (var j:int = 0; j < num; j++) {
					var c : Object3D = obj.clone();
					c.transform.x = (i - num/2) * 20;
					c.transform.y = (j - num/2) * 30;
					c.animator.frameSpeed = Math.random();
					this.scene.addChild(c);
				}
			}
			
		}
	}
}
