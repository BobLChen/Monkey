package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import monkey.core.animator.Animator;
	import monkey.core.base.Object3D;
	import monkey.core.renderer.SkeletonRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.Color;
	import monkey.core.utils.Mesh3DUtils;

	/**
	 *　　　　　　　　┏┓　　　┏┓+ +
	 *　　　　　　　┏┛┻━━━┛┻┓ + +
	 *　　　　　　　┃　　　　　　　┃ 　
	 *　　　　　　　┃　　　━　　　┃ ++ + + +
	 *　　　　　　 ████━████ ┃+
	 *　　　　　　　┃　　　　　　　┃ +
	 *　　　　　　　┃　　　┻　　　┃
	 *　　　　　　　┃　　　　　　　┃ + +
	 *　　　　　　　┗━┓　　　┏━┛
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + + + +
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + 　　　　　　
	 *　　　　　　　　　┃　　　┃
	 *　　　　　　　　　┃　　　┃　　+　　　　　　　　　
	 *　　　　　　　　　┃　 　　┗━━━┓ + +
	 *　　　　　　　　　┃ 　　　　　　　┣┓
	 *　　　　　　　　　┃ 　　　　　　　┏┛
	 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
	 *　　　　　　　　　　┃┫┫　┃┫┫
	 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
	 * @author Neil
	 * @date   May 18, 2015
	 */
	public class Test_Rim extends Sprite {
		
		private var scene : Scene3D;
		
		[Embed(source="../assets/test_07/akali_attack1_transformAkali.mesh", mimeType="application/octet-stream")]
		private var MESH : Class;
		[Embed(source="../assets/test_07/akali.jpg")]
		private var IMG  : Class;
		[Embed(source="../assets/test_08/dance.anim", mimeType="application/octet-stream")]
		private var Dance : Class;
		
		private var akali	: Object3D;
		
		public function Test_Rim() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -700;
			this.scene.autoResize = true;
			
			this.akali	= new Object3D();
			this.akali.addComponent(new SkeletonRenderer(Mesh3DUtils.readMesh(new MESH()), new CustomMaterial(new Bitmap2DTexture(new IMG().bitmapData))));
			this.akali.renderer.material.twoSided = true;	// lol使用的逆时针索引
			this.akali.addComponent(AnimUtil.readAnim(new Dance()));
			this.akali.animator.fps = 15;
			this.akali.animator.play(Animator.ANIMATION_LOOP_MODE);
			this.scene.addChild(this.akali);
			
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
		}
		
		protected function onCreate(event:Event) : void {
			this.scene.context.enableErrorChecking = true;			
		}
		
	}
}
import monkey.core.materials.SkeDifQuatMaterial;
import monkey.core.materials.shader.SkeDifQuatShader;
import monkey.core.scene.Scene3D;
import monkey.core.shader.filters.RimFilter;
import monkey.core.textures.Texture3D;
import monkey.core.utils.Color;

class CustomShader extends SkeDifQuatShader {

	private static var _instance : CustomShader;
	
	private var rim : RimFilter;
			
	public function CustomShader() : void {
		super();
		this.rim = new RimFilter(new Color(0xFF0000), 5);
		this.addFilter(rim);
	}
	
	public function set rimPower(value : Number) : void {
		this.rim.power = value;
	}
	
	public static function get instance():CustomShader {
		if (!_instance) {
			_instance = new CustomShader();
		}
		return _instance;
	}
	
}


class CustomMaterial extends SkeDifQuatMaterial {
	
	private var _rimPower : Number = 100.0;
	
	public function CustomMaterial(texture : Texture3D) : void {
		super(texture);	
		this._shader = CustomShader.instance;
	}
	
	public function get rimPower():Number {
		return _rimPower;
	}
	
	public function set rimPower(value:Number):void {
		_rimPower = value;
	}
	
	override public function updateMaterial(scene:Scene3D):void {
		super.updateMaterial(scene);
		CustomShader(shader).rimPower = this.rimPower;
	}
	

}
