package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.utils.getTimer;
	
	import monkey.core.animator.Animator;
	import monkey.core.base.Object3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.SkeDifQuatMaterial;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Mesh3DUtils;

	public class Test_04 extends Sprite {
		
		[Embed(source="../assets/test_04/xiaonan_boo1.mesh", mimeType="application/octet-stream")]
		private var DATA : Class;
		[Embed(source="../assets/test_04/xiaonan_boo1.anim", mimeType="application/octet-stream")]
		private var ANIM : Class;
		[Embed(source="../assets/test_04/xiaonan_boo1.jpg")]
		private var IMG  : Class;
		
		private var scene : Scene3D;
		
		public function Test_04() {
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
			
			var obj  : Object3D = Mesh3DUtils.readMesh(new DATA());
			var mesh : Mesh3D = obj.renderer.mesh;
						
			obj.renderer.material = new SkeDifQuatMaterial(new Bitmap2DTexture(new IMG().bitmapData));
			obj.addComponent(AnimUtil.readAnim(new ANIM()));
			obj.play(Animator.ANIMATION_LOOP_MODE);
			
			var num : int = 50;
			for (var i:int = 0; i < num; i++) {
				for (var j:int = 0; j < num; j++) {
					var c : Object3D = obj.clone();
					c.transform.x = (i - num/2) * 20;
					c.transform.y = (j - num/2) * 30;
					c.animator.frameSpeed = Math.random();
					this.scene.addChild(c);
				}
			}
			trace(getTimer() - t);
		}
		
	}
}
