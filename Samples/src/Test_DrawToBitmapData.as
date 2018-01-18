package {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.FPSStats;
	import monkey.loader.ParticleLoader;

	/**
	 *　　　　　　　　┏┓　　　┏┓+ +
	 *　　　　　　　┏┛┻━━━┛┻┓ + +
	 *　　　　　　　┃　　　　　　　┃ 　
	 *　　　　　　　┃　　　━　　　┃ ++ + + +
	 *　　　　　　 ████━████ ┃+
	 *　　　　　　　┃　　　　　　　┃ +
	 *　　　　　　　┃　　　┻　　　┃
	 *　　　　　　　┃　　　　　　　┃ + +
	 *　　　　　　　┗━┓　　　┏━┛
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + + + +
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + 　　　　　　
	 *　　　　　　　　　┃　　　┃
	 *　　　　　　　　　┃　　　┃　　+　　　　　　　　　
	 *　　　　　　　　　┃　 　　┗━━━┓ + +
	 *　　　　　　　　　┃ 　　　　　　　┣┓
	 *　　　　　　　　　┃ 　　　　　　　┏┛
	 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
	 *　　　　　　　　　　┃┫┫　┃┫┫
	 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
	 * 绘制到BitmapData
	 * @author Neil
	 * @date   Jun 4, 2015
	 */
	public class Test_DrawToBitmapData extends Sprite {
		
		[Embed(source="../assets/test_06/test_optimize.particle", mimeType="application/octet-stream")]
		private var DATA  : Class;
		
		private var scene : Scene3D;
		
		public function Test_DrawToBitmapData() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;  
			this.stage.addChild(new FPSStats());
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.z = -50;
			this.scene.camera.transform.x = -25;
			this.scene.autoResize = true;
			
			var loader : ParticleLoader = new ParticleLoader();
			loader.loadBytes(new DATA());
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			
			this.scene.addChild(loader);
		} 
		
		protected function onLoadComplete(event:Event) : void {
			var loader : ParticleLoader = event.target as ParticleLoader;
			loader.forEach(function(p:ParticleSystem):void{
				p.renderer.material.blendMode = Material3D.BLEND_ADDITIVE;
			}, ParticleSystem);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent) : void {
			if (event.keyCode == Keyboard.ENTER) {
				this.scene.context.clear(0, 0, 0, 0);
				this.scene.render();
				var bmp : BitmapData = new BitmapData(this.stage.stageWidth, this.stage.stageHeight);
				this.scene.context.drawToBitmapData(bmp);
				var bitmap : Bitmap = new Bitmap(bmp);
				this.addChild(bitmap);
				this.scene.camera.transform.x = -50;
			}
		}
		
	}
}
