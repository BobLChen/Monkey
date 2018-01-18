package {

	import com.adobe.images.PNGEncoder;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import ide.plugins.groups.particles.lifetime.LifetimeData;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.UUID;
	import monkey.loader.ParticleLoader;

	public class Test_Particles extends Sprite {
		
		[Embed(source="../assets/test_08/test_08_optimize.particle", mimeType="application/octet-stream")]
//		[Embed(source="../assets/test_06/test_optimize.particle", mimeType="application/octet-stream")]
		private var DATA  : Class;
		
		private var scene : Scene3D;
		
		public function Test_Particles() {
			super();  
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;  
			this.stage.addChild(new FPSStats());
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -50;
			this.scene.autoResize = true;
			
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
			
			this.scene.addChild(particle);
			
//			var loader : ParticleLoader = new ParticleLoader();
//			loader.loadBytes(new DATA());
//			loader.addEventListener(Event.COMPLETE, loadComplete);	
//			
//			this.scene.addChild(loader);
//			
//			this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, function(e:Event):void{
//				loader.transform.x = Math.sin(getTimer() / 5000) * 100;
//				loader.transform.y = Math.cos(getTimer() / 5000) * 100;
//			});
		}
		
		protected function loadComplete(event:Event) : void {
			var p : Object3D = event.target as ParticleLoader;
			var num : int = 10;
			for (var i:int = 0; i < num; i++) {
				for (var j:int = 0; j < num; j++) {
					var tx: Number = (i - num/2) * 25;
					var ty: Number = (j - num/2) * 25;
					var c : Object3D = p.clone();
					c.transform.x = tx;
					c.transform.y = ty;
					scene.addChild(c);
					onClone(c, tx, ty);
				}
			}
		}
		
		private function onClone(c : Object3D, tx : Number, ty : Number) : void {
			c.addEventListener(Object3D.ENTER_DRAW_EVENT, function(e : Event):void{
				c.transform.x = Math.sin(getTimer() / 5000) * 50 + tx;
				c.transform.y = Math.cos(getTimer() / 5000) * 50 + ty;
			});	
		}
		
	}
}
