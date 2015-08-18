package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Sphere;
	import monkey.core.light.PointLight;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D; 
	import monkey.core.utils.Color;

	public class Test_PointLight extends Sprite {
		
		private var scene : Scene3D;
		private var light : PointLight;
		
		public function Test_PointLight() {
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -50;
			this.scene.autoResize = true;
			
			this.light = new PointLight();
			this.light.transform.y = 25;
			this.light.radius = 5;
			this.light.color = new Color(0xFFFF00);
			this.light.ambient = new Color(0x444444);
			this.light.intensity = 2;
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Sphere(5), new PointLightMaterial(Color.GRAY, light)));
			
			this.scene.addChild(cube);
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
			
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, function(e:Event):void{
				light.transform.y = Math.sin(getTimer() / 1000) * 25;
				light.transform.z = Math.cos(getTimer() / 1000) * 25;
				light.transform.lookAt(0, 0, 0);
			});
		}
		
		private function onCreate(event:Event) : void {
			this.scene.context.enableErrorChecking = true;		
		}
	}
}
import monkey.core.light.PointLight;
import monkey.core.materials.Material3D;
import monkey.core.scene.Scene3D;
import monkey.core.shader.Shader3D;
import monkey.core.shader.filters.ColorFilter;
import monkey.core.shader.filters.PointLightFilter;
import monkey.core.utils.Color;

/**
 * 点光shader 
 * @author Neil
 * 
 */
class PointLightShader extends Shader3D {
	
	private static var _instance : PointLightShader;
	
	private var _light : PointLightFilter;
	private var _color : ColorFilter;
	
	public function PointLightShader() : void {
		super([]);
		this._light = new PointLightFilter(null);
		this._color = new ColorFilter(Color.GRAY);
		this.addFilter(this._light);
		this.addFilter(this._color);
	}
	
	public function set color(value : Color) : void {
		this._color.color = value;
	}
	
	public function set light(value : PointLight) : void {
		this._light.light = value;
	}
	
	public static function get instance():PointLightShader {
		if (_instance == null) {
			_instance = new PointLightShader();
		}
		return _instance;
	}
}

class PointLightMaterial extends Material3D {
	
	private var _color : Color;
	private var _light : PointLight;
	
	public function PointLightMaterial(color : Color, light : PointLight) : void {
		super(PointLightShader.instance);
		this.color = color;
		this.light = light;
	}

	public function get light():PointLight {
		return _light;
	}

	public function set light(value:PointLight):void {
		_light = value;
	}

	public function get color():Color {
		return _color;
	}

	public function set color(value:Color):void {
		_color = value;
	}
	
	override public function updateMaterial(scene:Scene3D):void {
		PointLightShader(shader).color = color;		
		PointLightShader(shader).light = light;		
	}
	
	
}