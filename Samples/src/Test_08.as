package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import monkey.core.animator.Animator;
	import monkey.core.base.Object3D;
	import monkey.core.components.AvatarComponent;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.materials.SkeDifQuatMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.renderer.SkeletonRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.Color;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Mesh3DUtils;
	import monkey.loader.ParticleLoader;

	public class Test_08 extends Sprite {
		
		[Embed(source="../assets/test_07/akali.mesh", mimeType="application/octet-stream")]
		private var MESH : Class;
		[Embed(source="../assets/test_07/akali.jpg")]
		private var IMG  : Class;
		[Embed(source="../assets/test_08/dance.anim", mimeType="application/octet-stream")]
		private var Dance : Class;
		[Embed(source="../assets/test_08/test_08_optimize.particle", mimeType="application/octet-stream")]
		private var DATA : Class;
				
		private var scene 	: Scene3D;
		private var akali	: Object3D;
		
		public function Test_08() {
			super();
			
			// 使用FBX导入时，在Mount栏目输入:weapon,weapon_b
			// 挂节点骨骼名称:weapon weapon_b
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.stage.addChild(new FPSStats());
			 
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -500;
			this.scene.camera.transform.lookAt(0, 0, 0); 
			this.scene.autoResize = true;
			
			this.akali	= new Object3D();
			this.akali.addComponent(new SkeletonRenderer(Mesh3DUtils.readMesh(new MESH()), new SkeDifQuatMaterial(new Bitmap2DTexture(new IMG().bitmapData))));
			this.akali.renderer.material.twoSided = true;	// lol使用的逆时针索引
			this.akali.addComponent(AnimUtil.readAnim(new Dance()));
			this.akali.animator.fps = 15;
			
			this.scene.addChild(this.akali);
			this.akali.animator.play(Animator.ANIMATION_LOOP_MODE);
			
			//  挂接装备0
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Cube(100, 10, 10), new ColorMaterial(Color.WHITE)));
			this.akali.addComponent(new AvatarComponent("weapon", cube));
			// 挂接装备1
			var particle : ParticleLoader = new ParticleLoader();
			particle.loadBytes(new DATA());
			this.akali.addComponent(new AvatarComponent("weapon_b", particle));
		}
	}
}
