package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;

	public class Test_Fog extends Sprite {
		
		private var scene : Scene3D;
		
		public function Test_Fog() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -50;
			this.scene.camera.transform.y = 10;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Plane(1000, 1000, 1, "+xz"), new CustomMaterial(Color.WHITE, new Color(0xFF0000), 60)));
			
			this.scene.addChild(cube);
		}
	}
}
import monkey.core.materials.Material3D;
import monkey.core.scene.Scene3D;
import monkey.core.shader.Shader3D;
import monkey.core.shader.filters.ColorFilter;
import monkey.core.shader.filters.FogFilter;
import monkey.core.utils.Color;

class FogShader extends Shader3D {
	
	private static var _instance : FogShader;
	
	private var _fog 	: FogFilter;
	private var _color  : ColorFilter;
	
	public function FogShader() : void {
		super([]);
		this._fog = new FogFilter(100, new Color(0xFF0000));
		this._color = new ColorFilter(Color.WHITE);
		this.addFilter(_fog);
		this.addFilter(_color);
	}
	
	public static function get instance():FogShader {
		if (_instance == null) {
			_instance = new FogShader();
		}
		return _instance;
	}

	public function set fogColor(color : Color) : void {
		this._fog.fogColor = color;
	}
	
	public function set fogDistance(value : Number) : void {
		this._fog.fogDistance = value;
	}
	
	public function set color(color : Color) : void {
		this._color.color = color;
	}
}

class CustomMaterial extends Material3D {
	
	private var _color : Color;
	private var _fogColor : Color;
	private var _distance : Number;
	
	public function CustomMaterial(color : Color, fogColor : Color, distance : Number) : void {
		super(FogShader.instance);
		this.color = color;
		this.fogColor = fogColor;
		this.distance = distance;
	}
	
	public function get distance():Number {
		return _distance;
	}

	public function set distance(value:Number):void {
		_distance = value;
	}

	public function get fogColor():Color {
		return _fogColor;
	}

	public function set fogColor(value:Color):void {
		_fogColor = value;
	}

	public function get color():Color {
		return _color;
	}

	public function set color(value:Color):void {
		_color = value;
	}
	
	override public function updateMaterial(scene:Scene3D):void {
		super.updateMaterial(scene);
		
		FogShader(shader).fogColor = fogColor;
		FogShader(shader).color = color;
		FogShader(shader).fogDistance = distance;
	}
	
}