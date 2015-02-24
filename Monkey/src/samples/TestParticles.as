package samples {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import monkey.core.base.Object3D;
	import monkey.core.collisions.CollisionInfo;
	import monkey.core.collisions.MouseCollision;
	import monkey.core.collisions.collider.Collider;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.prop.value.PropConst;
	import monkey.core.entities.particles.prop.value.PropCurves;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.scene.Viewer3D;

	public class TestParticles extends Sprite {
		
		private var scene : Viewer3D;
		private var mouse : MouseCollision;
		
		public function TestParticles() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.nativeWindow.maximize();
			
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;
			
			var particle : ParticleSystem = new ParticleSystem();
			particle.bursts.push(new Point(0, 100));
			particle.bursts.push(new Point(2, 100));
			particle.duration = 5;
			particle.startSpeed = new PropCurves();
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(0,   5));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(2.5, 5));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(5,   5));
			particle.rate = 50;
			particle.startLifeTime = new PropConst(5);
			particle.play();
			
			this.scene.addChild(particle);	
			
			var mesh : Cube = new Cube();
			var cube : Object3D = new Object3D();
			cube.addComponent(mesh);
			cube.addComponent(new ColorMaterial());
			cube.addComponent(new Collider(mesh));
			
			this.mouse = new MouseCollision();
			this.mouse.addCollisionWith(cube);
			
			this.scene.addChild(cube);
			
			this.stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		protected function onClick(event:MouseEvent) : void {
			var info : CollisionInfo = new CollisionInfo();
			if (this.mouse.test(event.stageX, event.stageY, info)) {
				trace("拾取到...");
			}
		}		
				
	}
}
