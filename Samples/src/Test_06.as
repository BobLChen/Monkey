package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import monkey.core.base.Object3D;
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
			loader.addEventListener(Event.COMPLETE, loadComplete);	
			
			this.scene.addChild(loader);
			
			this.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, function(e:Event):void{
				loader.transform.x = Math.sin(getTimer() / 5000) * 100;
				loader.transform.y = Math.cos(getTimer() / 5000) * 100;
			});
			
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
