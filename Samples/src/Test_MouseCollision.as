package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	
	import monkey.core.base.Object3D;
	import monkey.core.collisions.CollisionInfo;
	import monkey.core.collisions.MouseCollision;
	import monkey.core.collisions.collider.Collider;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.FPSStats;

	public class Test_MouseCollision extends Sprite {
		
		private var scene : Scene3D;
		private var mouse : MouseCollision;
		
		public function Test_MouseCollision() {
			super();
						
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -450;
			this.scene.autoResize = true;
			
			this.addChild(new FPSStats());
			
			this.mouse = new MouseCollision(this.scene.camera);
			
			for (var i:int = 0; i < 15; i++) {
				for (var j:int = 0; j < 15; j++) {
					var plane : Object3D = new Object3D();
					plane.addComponent(new MeshRenderer(new Plane(), new ColorMaterial(new Color(0xFFFFFF * Math.random()))));
					plane.transform.x = (i - 7.5) * 15;
					plane.transform.y = (j - 7.5) * 15;
					plane.name = "" + (i * 15 + j);
					this.scene.addChild(plane);
					// collision
					plane.addComponent(new Collider(plane.renderer.mesh));
					this.mouse.addCollisionWith(plane);
				}
			}
			
			this.stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private var info : CollisionInfo = new CollisionInfo();
		
		protected function onClick(event:MouseEvent) : void {
			
			if (this.mouse.test(this.stage.mouseX, this.stage.mouseY, info)) {
				trace("拾取:", info.object.name, info.point, info.surface, info.tri);
			}
		}
	}
}
