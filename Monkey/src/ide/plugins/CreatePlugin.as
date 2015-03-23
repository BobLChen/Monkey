package ide.plugins {
	
	import com.adobe.images.PNGEncoder;
	
	import flash.events.Event;
	
	import ide.App;
	import ide.plugins.groups.particles.lifetime.LifetimeData;
	
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.camera.lens.PerspectiveLens;
	import monkey.core.entities.SkyBox;
	import monkey.core.entities.Water3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.primitives.Capsule;
	import monkey.core.entities.primitives.Cone;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.entities.primitives.Cylinder;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.entities.primitives.Sphere;
	import monkey.core.light.DirectionalLight;
	import monkey.core.light.PointLight;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Color;
	import monkey.core.utils.GradientColor;
	import monkey.core.utils.Texture3DUtils;
	import monkey.core.utils.UUID;
	
	import ui.core.interfaces.IPlugin;
	
	/**
	 * create panel 
	 * @author Neil
	 * 
	 */	
	public class CreatePlugin implements IPlugin {
		
		private var _app : App;
		
		public function CreatePlugin() {
			
		}
		
		public function start():void {
			
		}
		
		public function init(app : App) : void {
			this._app = app;
			this._app.addMenu("Create/Object3D", 	createObject3D);
			this._app.addMenu("Create/Particles",	createParticles);
			this._app.addMenu("Create/Camera3D",	createCamera);
			this._app.addMenu("Create/Cube", 		createCube);
			this._app.addMenu("Create/Capsule", 	createCapsule);
			this._app.addMenu("Create/Cone",		createCone);
			this._app.addMenu("Create/Cylinder",	createCylinder);
			this._app.addMenu("Create/Sphere",		createSphere);
			this._app.addMenu("Create/Plane +xz",	createPlaneXZ);
			this._app.addMenu("Create/Plane +xy",	createPlaneXY);
			this._app.addMenu("Create/Plane +zy",	createPlaneZY);
			this._app.addMenu("Create/Water",		createWater);
			this._app.addMenu("Create/SkyBox",		createSkyBox);
			this._app.addMenu("Create/PointLight",	createPointLight);
			this._app.addMenu("Create/DirecLight",	createDirecLight);
		}
		
		private function createCamera(e : Event) : void {
			var camera : Camera3D = new Camera3D(new PerspectiveLens());
			camera.name = "Camera3D";
			camera.viewPort = this._app.scene.viewPort;
			this._app.scene.addChild(camera);
			this._app.selection.objects = [camera];
		}
		
		private function createDirecLight(e : Event) : void {
			var light : DirectionalLight = new DirectionalLight();
			light.name = "DirectionalLight";
			this._app.scene.addChild(light);
			this._app.selection.objects = [light];
		}
		
		private function createPointLight(e : Event) : void {
			var light : PointLight = new PointLight();
			light.name = "PointLight";
			this._app.scene.addChild(light);
			this._app.selection.objects = [light];
		}
		
		private function createSkyBox(e : Event) : void {
			var skybox : SkyBox = new SkyBox(Texture3DUtils.nullBitmapData);
			this._app.scene.addChild(skybox);
			this._app.selection.objects = [skybox];
		}
		
		private function createWater(e : Event) : void {
			var water : Water3D = new Water3D(
				Texture3DUtils.nullBitmapData, 
				Texture3DUtils.nullBitmapData
			);
			this._app.scene.addChild(water);
			this._app.selection.objects = [water];
		}
		
		private function createParticles(e : Event) : void {
			var particle : ParticleSystem = new ParticleSystem();
			particle.init();
			particle.build();
			particle.play();
						
			var data : LifetimeData = new LifetimeData();
			data.init();
			particle.userData.lifetime  = data;
			particle.userData.uuid 		= UUID.generate();		
			particle.userData.imageData = PNGEncoder.encode(particle.image);
			particle.userData.imageName = "default_image";
				
			this._app.scene.addChild(particle);
			this._app.selection.objects = [particle];
		}
		
		private function createSphere(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Sphere"
			obj.addComponent(new MeshRenderer(new Sphere(), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
						
		private function createPlaneZY(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Plane"
			obj.addComponent(new MeshRenderer(new Plane(10, 10, 1, "+yz"), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
		
		private function createPlaneXY(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Plane"
			obj.addComponent(new MeshRenderer(new Plane(10, 10, 1, "+xy"), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
		
		private function createPlaneXZ(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Plane";
			obj.addComponent(new MeshRenderer(new Plane(10, 10, 1, "+xz"), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
		
		private function createCylinder(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Cylinder";
			obj.addComponent(new MeshRenderer(new Cylinder(), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
		
		private function createCone(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Cone";
			obj.addComponent(new MeshRenderer(new Cone(), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
		
		private function createCapsule(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Capsule";
			obj.addComponent(new MeshRenderer(new Capsule(), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
		
		private function createCube(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Cube";
			obj.addComponent(new MeshRenderer(new Cube(), new ColorMaterial(Color.GRAY)));
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
		
		private function createObject3D(e : Event) : void {
			var obj : Object3D = new Object3D();
			obj.name = "Object3D";
			this._app.scene.addChild(obj);
			this._app.selection.objects = [obj];
		}
	}
	
}
