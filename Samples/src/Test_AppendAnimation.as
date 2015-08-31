package {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import monkey.core.animator.Animator;
	import monkey.core.animator.Label3D;
	import monkey.core.base.Object3D;
	import monkey.core.materials.Material3D;
	import monkey.core.materials.SkeDifQuatMaterial;
	import monkey.core.renderer.SkeletonRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Mesh3DUtils;
	
	public class Test_AppendAnimation extends Sprite {
		
		[Embed(source="../assets/test_07/akali.mesh", mimeType="application/octet-stream")]
		private var MESH : Class;
		[Embed(source="../assets/test_07/akali.jpg")]
		private var IMG  : Class;
		[Embed(source="../assets/test_07/attack1.anim", mimeType="application/octet-stream")]
		private var Attack1 : Class;
		[Embed(source="../assets/test_07/attack2.anim", mimeType="application/octet-stream")]
		private var Attack2 : Class;
		[Embed(source="../assets/test_07/channel.anim", mimeType="application/octet-stream")]
		private var Channel : Class;
		[Embed(source="../assets/test_07/crit.anim", mimeType="application/octet-stream")]
		private var Crit 	: Class;
		[Embed(source="../assets/test_07/dance.anim", mimeType="application/octet-stream")]
		private var Dance : Class;
		[Embed(source="../assets/test_07/death.anim", mimeType="application/octet-stream")]
		private var Death : Class;
		[Embed(source="../assets/test_07/idle0.anim", mimeType="application/octet-stream")]
		private var Idel0 : Class;
		[Embed(source="../assets/test_07/idle1.anim", mimeType="application/octet-stream")]
		private var Idel1 : Class;
		[Embed(source="../assets/test_07/idle3.anim", mimeType="application/octet-stream")]
		private var Idel3 : Class;
		
		private var scene 	: Scene3D;
		private var keyMap  : Dictionary;
		private var akali	: Object3D;
		
		public function Test_AppendAnimation() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.stage.addChild(new FPSStats());
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -500;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			
			this.keyMap = new Dictionary();
			this.akali	= new Object3D();
			this.akali.addComponent(new SkeletonRenderer(Mesh3DUtils.readMesh(new MESH()), new SkeDifQuatMaterial(new Bitmap2DTexture(new IMG().bitmapData))));
			this.akali.renderer.material.twoSided = true;	// lol使用的逆时针索引
						
			var datas : Array = [Attack1, Attack2, Channel, Crit, Dance, Death, Idel0, Idel1, Idel3];
			var keys  : Array = [Keyboard.NUMBER_1, Keyboard.NUMBER_2, Keyboard.NUMBER_3, Keyboard.NUMBER_4, Keyboard.NUMBER_5, Keyboard.NUMBER_6, Keyboard.NUMBER_7, Keyboard.NUMBER_8, Keyboard.NUMBER_9];
			
			for (var i:int = 0; i < datas.length; i++) {
				var name : String = getQualifiedClassName(datas[i]);
				name = name.split("_")[0];
				this.keyMap[keys[i]] = name;
				var anim : Animator = AnimUtil.readAnim(new datas[i]);
				if (this.akali.animator) {
					this.akali.animator.append(anim);
				} else {
					this.akali.addComponent(anim);
				}
				this.akali.animator.addLabel(new Label3D(name, this.akali.animator.totalFrames - anim.totalFrames, this.akali.animator.totalFrames, 1));
				trace(name, anim.totalFrames, this.akali.animator.totalFrames);
			}
			this.akali.play();
			this.akali.animator.fps = 30;
			this.scene.addChild(this.akali);
			
			var text : TextField = new TextField();
			text.defaultTextFormat = new TextFormat(null, 16, 0xFFFFFF);
			text.y = 200;
			text.autoSize = TextFieldAutoSize.LEFT;
			i = 1;
			for (var key : int in this.keyMap) {
				text.text += "Key:" + (i++) + " --> " + keyMap[key] + " \n";
			}
			
			this.addChild(text);
			
			// 克隆
			for (var m:int = 0; m < 20; m++) {
				for (var n:int = 0; n < 20; n++) {
					var c : Object3D = this.akali.clone();
					c.transform.x = (m - 10) * 100;
					c.transform.y = (n - 10) * 100;
					c.transform.z = 500;
					c.play(Animator.ANIMATION_LOOP_MODE);
					c.renderer.material.cullFace = Context3DTriangleFace.FRONT;
					this.scene.addChild(c);
				}
			}
						
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent) : void {
			if (this.keyMap[event.keyCode]) {
				this.akali.animator.gotoAndPlay(this.keyMap[event.keyCode]);
			}
		}
	}
}
