package blog.samples {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import monkey.core.animator.SkeletonAnimator;
	import monkey.core.base.Object3D;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.ColorFilter;
	import monkey.core.shader.filters.SkeletonFilter34;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.Color;
	import monkey.core.utils.Mesh3DUtils;

	public class Stage3d16 extends Sprite {
		
		private var scene : Scene3D;
		
		[Embed(source="xiaonan_boo1.mesh", mimeType="application/octet-stream")]
		private var MESH : Class;
		[Embed(source="xiaonan_boo1.anim", mimeType="application/octet-stream")]
		private var ANIM : Class;
		
		public function Stage3d16() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 15;
			
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;
			this.scene.camera.transform.z = -150;
			
			var skeleton : SkeletonFilter34 = new SkeletonFilter34();
			var shader : Shader3D = new Shader3D([]);
			shader.addFilter(skeleton);
			shader.addFilter(new ColorFilter(Color.GRAY));
			var material : Material3D = new Material3D(shader);
			
			var obj  : Object3D = Mesh3DUtils.readMesh(new MESH());
			obj.renderer.material = material;
			var anim : SkeletonAnimator = AnimUtil.readAnim(new ANIM()) as SkeletonAnimator; 
			obj.addComponent(anim);
			anim.fps = 15;
			anim.play();
			
			obj.addEventListener(Object3D.ENTER_FRAME_EVENT, function(e:Event):void{
				trace(anim.currentFrame);
//				skeleton.data = anim.getBoneBytes(0, int(anim.currentFrame));
			});
			
			trace(anim.totalFrames);
			
			this.scene.addChild(obj);
		}
	}
}
