package  {
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
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
			this.scene.camera.transform.z = -1000;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.addChild(new FPSStats());
			
			var loader : ParticleLoader = new ParticleLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.loadBytes(new DATA());
		}
		
		private var list : Vector.<Object3D> = new Vector.<Object3D>();
		
		protected function onComplete(event:Event) : void {
			var loader : ParticleLoader = event.target as ParticleLoader;
			list.push(loader);
			for (var i:int = 0; i < 20; i++) {
				for (var j:int = 0; j < 20; j++) {
					var c : Object3D = loader.clone();
					c.transform.x = (i - 10) * 25;
					c.transform.y = (j - 10) * 25;
					this.scene.addChild(c);
					list.push(c);
				}
			}
			
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent) : void {
			var obj : Object3D = list.shift();
			if (obj) {
				obj.dispose();
			}
			trace(list.length);
		}
		
	}
}
