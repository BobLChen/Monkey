package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.materials.Material3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color; 

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
	 * 透明贴图穿插问题
	 * @author Neil
	 * @date   Jul 9, 2015
	 */
	public class Test_AlphaThread extends Sprite {
		
		[Embed(source="../assets/testAlphaThread/tree.png")]
		private var IMG : Class;
		
		private var scene : Scene3D;
		
		public function Test_AlphaThread() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -50;
			this.scene.autoResize = true;
			
			var plane : Object3D = new Object3D();
			plane.addComponent(new MeshRenderer(new Plane(10, 10), new AlphaThreadMaterial(new Bitmap2DTexture(new IMG().bitmapData))));
			plane.renderer.material.blendMode = Material3D.BLEND_ALPHA;
			
			var plane1 : Object3D = new Object3D();
			plane.addComponent(new MeshRenderer(new Plane(10, 10, 1, "+xz"), new AlphaThreadMaterial(new Bitmap2DTexture(new IMG().bitmapData))));
			plane.renderer.material.blendMode = Material3D.BLEND_ALPHA;
			
			this.scene.addChild(plane);
			this.scene.addChild(plane1);
		}
		
	}
}
import monkey.core.materials.DiffuseMaterial;
import monkey.core.materials.shader.DiffuseShader;
import monkey.core.scene.Scene3D;
import monkey.core.shader.filters.AlphaThreadFilter;
import monkey.core.textures.Texture3D;

class AlphaThreadShader extends DiffuseShader {
	
	private static var _instance : AlphaThreadShader;
	
	private var _filter : AlphaThreadFilter;
			
	public function AlphaThreadShader() : void {
		super();
		this._filter = new AlphaThreadFilter(0.5);
		this.addFilter(this._filter);
	}

	public static function get instance():AlphaThreadShader {
		if (!_instance) {
			_instance = new AlphaThreadShader();
		}
		return _instance;
	}

	public function get alpha():Number {
		return _filter.alpha;
	}

	public function set alpha(value:Number):void {
		_filter.alpha = value;
	}
	
}

class AlphaThreadMaterial extends DiffuseMaterial {
	
	private var _alpha : Number = 1;
	
	public function AlphaThreadMaterial(texture : Texture3D, alpha : Number = 0.5) : void {
		super(texture);
		this._shader = AlphaThreadShader.instance;
	}

	public function get alpha():Number {
		return _alpha;
	}
	
	public function set alpha(value:Number):void {
		_alpha = value;
	}
	
	override public function updateMaterial(scene:Scene3D):void {
		AlphaThreadShader(shader).texture = this.texture;	
		AlphaThreadShader(shader).tillingOffset(repeatX, repeatY, offsetX, offsetY);
		AlphaThreadShader(shader).alpha = alpha;
	}
	
}
