package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.light.DirectionalLight;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.Mesh3DUtils;

	public class Test_NormalMap extends Sprite {
		
		[Embed(source="../assets/test_04/xiaonan_boo1.jpg")]
		private var DIFFUSE : Class;
		[Embed(source="../assets/test_normalmap/normal.jpg")]
		private var NORMALMAP : Class;
		
		[Embed(source="../assets/test_normalmap/xiaonan_boo1.mesh", mimeType="application/octet-stream")]
		private var DATA : Class;
		
		private var scene : Scene3D;
		
		public function Test_NormalMap() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.setPosition(0, 30, -50);
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			
			var light : DirectionalLight = new DirectionalLight();
			light.transform.setPosition(0, 0, -1);
			light.transform.lookAt(0, 0, 0);
			
			var obj : Object3D = new Object3D();
			obj.addComponent(new MeshRenderer(Mesh3DUtils.readMesh(new DATA()), new NormalMapMaterial(
				light,
				new Bitmap2DTexture(new NORMALMAP().bitmapData),
				new Bitmap2DTexture(new DIFFUSE().bitmapData)
			)));
			
			this.scene.addChild(obj);
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
		}
		
		protected function onCreate(event:Event) : void {
			this.scene.context.enableErrorChecking = true;			
		}
		
	}
}
import monkey.core.light.DirectionalLight;
import monkey.core.materials.Material3D;
import monkey.core.scene.Scene3D;
import monkey.core.shader.Shader3D;
import monkey.core.shader.filters.DirectionalLightFilter;
import monkey.core.shader.filters.NormalMapFilter;
import monkey.core.shader.filters.TextureMapFilter;
import monkey.core.textures.Texture3D;

class NormalmapShader extends Shader3D {
	
	private static var _instance : NormalmapShader;
	
	private var _light 	: DirectionalLightFilter;
	private var _bump  	: NormalMapFilter;
	private var _diff	: TextureMapFilter;
	
	public function NormalmapShader() : void {
		super([]);
		this._light = new DirectionalLightFilter(null);
		this._bump  = new NormalMapFilter(null);
		this._diff  = new TextureMapFilter(null);
		this.addFilter(this._light);
		this.addFilter(this._bump);
		this.addFilter(this._diff);
	}
	
	public static function get instance():NormalmapShader {
		if (_instance == null) {
			_instance = new NormalmapShader();
		}
		return _instance;
	}

	public function set light(light : DirectionalLight) : void {
		this._light.light = light;
	}
	
	public function set normalmap(texture : Texture3D) : void {
		this._bump.texture = texture;
	}
	
	public function set diffuse(texture : Texture3D) : void {
		this._diff.texture = texture;
	}
	
}


class NormalMapMaterial extends Material3D {
	
	private var _light  	: DirectionalLight;
	private var _normal 	: Texture3D;
	private var _diffuse	: Texture3D;
	
	public function NormalMapMaterial(light : DirectionalLight, normalmap : Texture3D, diffuse : Texture3D) : void {
		super(NormalmapShader.instance);
		this.light = light;
		this.normal = normalmap;
		this.diffuse = diffuse;
	}
	
	override public function updateMaterial(scene:Scene3D):void {
		NormalmapShader(shader).diffuse = diffuse;
		NormalmapShader(shader).normalmap = normal;
		NormalmapShader(shader).light = light;
	}
	
	public function get diffuse():Texture3D {
		return _diffuse;
	}

	public function set diffuse(value:Texture3D):void {
		_diffuse = value;
	}

	public function get normal():Texture3D {
		return _normal;
	}

	public function set normal(value:Texture3D):void {
		_normal = value;
	}

	public function get light():DirectionalLight {
		return _light;
	}

	public function set light(value:DirectionalLight):void {
		_light = value;
	}
}