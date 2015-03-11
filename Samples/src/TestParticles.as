package  {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.FPSStats;
	import monkey.loader.ParticleLoader;
	
	public class TestParticles extends Sprite {
		
		[Embed(source="../assets/123.particle", mimeType="application/octet-stream")]
		private var DATA  : Class;
		
		private var scene : Viewer3D;
		
		public function TestParticles() {
			super();
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;  
			this.scene.camera.transform.z = -300;
			this.scene.camera.transform.y = 50;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.addChild(new FPSStats());
			var loader : ParticleLoader = new ParticleLoader();
			loader.loadBytes(new DATA());
			this.scene.addChild(loader);
			
			this.scene.addEventListener(Object3D.ENTER_FRAME, function(e:Event):void{
				loader.transform.rotateY(1);
			});
		}
		
	}
}
