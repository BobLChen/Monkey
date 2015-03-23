package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.FPSStats;
	import monkey.loader.ParticleLoader;

	public class Test_06 extends Sprite {
		
		[Embed(source="../assets/test_06/test_optimize.particle", mimeType="application/octet-stream")]
		private var DATA  : Class;
		
		private var scene : Scene3D;
		
		public function Test_06() {
			super();  
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;  
			this.stage.addChild(new FPSStats());
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -500;
			this.scene.autoResize = true;
			
			var loader : ParticleLoader = new ParticleLoader();
			loader.loadBytes(new DATA());
			
			this.scene.addChild(loader);
			
			this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, function(e:Event):void{
				loader.transform.x = Math.sin(getTimer() / 5000) * 100;
				loader.transform.y = Math.cos(getTimer() / 5000) * 100;
			});
			
		}
	}
}
