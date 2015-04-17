package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Capsule;
	import monkey.core.entities.primitives.Sphere;
	import monkey.core.light.DirectionalLight;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;

	public class Test_DirectionalLight extends Sprite {
		
		private var scene : Scene3D;
		private var light : DirectionalLight;
		
		public function Test_DirectionalLight() {
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -50;
			this.scene.autoResize = true;
			
			this.light = new DirectionalLight();
			this.light.transform.y = 25;
			this.light.transform.z = -25;
			this.light.transform.lookAt(0, 0, 0);
			this.light.color     = new Color(0xFF0000);
			this.light.ambient   = new Color(0x888888);
			this.light.intensity = 1;
			
			var sphere : Object3D = new Object3D();
			sphere.addComponent(new MeshRenderer(new Sphere(5), new DirectionalLightMaterial(Color.GRAY, light)));
			sphere.transform.x = -15;
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Capsule(), new DirectionalLightMaterial(new Color(0x4578dd), light)));
			cube.transform.x = 15;
			
			this.scene.addChild(cube);
			this.scene.addChild(sphere);
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
			
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, function(e:Event):void{
				light.transform.y = Math.sin(getTimer() / 1000) * 50;
				light.transform.z = Math.cos(getTimer() / 1000) * 50;
				light.transform.lookAt(0, 0, 0);
			});
		}
		
		private function onCreate(event:Event) : void {
			this.scene.context.enableErrorChecking = true;		
		}
	}
}

import monkey.core.light.DirectionalLight;
import monkey.core.materials.Material3D;
import monkey.core.scene.Scene3D;
import monkey.core.shader.Shader3D;
import monkey.core.shader.filters.ColorFilter;
import monkey.core.shader.filters.DirectionalLightFilter;
import monkey.core.utils.Color;

/**
 * 点光shader 
 * @author Neil
 * 
 */
class DirectionLightShader extends Shader3D {
	
	private static var _instance : DirectionLightShader;
	
	private var _light : DirectionalLightFilter;
	private var _color : ColorFilter;
	
	public function DirectionLightShader() : void {
		super([]);
		this._light = new DirectionalLightFilter(null);
		this._color = new ColorFilter(Color.GRAY);
		this.addFilter(this._light);
		this.addFilter(this._color);
	}
	
	public function set color(value : Color) : void {
		this._color.color = value;
	}
	
	public function set light(value : DirectionalLight) : void {
		this._light.light = value;
	}
	
	public static function get instance():DirectionLightShader {
		if (_instance == null) {
			_instance = new DirectionLightShader();
		}
		return _instance;
	}
}

class DirectionalLightMaterial extends Material3D {
	
	private var _color : Color;
	private var _light : DirectionalLight;
	
	public function DirectionalLightMaterial(color : Color, light : DirectionalLight) : void {
		super(DirectionLightShader.instance);
		this.color = color;
		this.light = light;
	}
	
	public function get light():DirectionalLight {
		return _light;
	}
	
	public function set light(value:DirectionalLight):void {
		_light = value;
	}
	
	public function get color():Color {
		return _color;
	}
	
	public function set color(value:Color):void {
		_color = value;
	}
	
	override public function updateMaterial(scene:Scene3D):void {
		DirectionLightShader(shader).color = color;		
		DirectionLightShader(shader).light = light;		
	}
		
}
