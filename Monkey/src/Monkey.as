package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import monkey.core.entities.Water3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.textures.BitmapCubeTexture;
	import monkey.core.utils.FPSStats;
	
	public class Monkey extends Sprite {
		
		[Embed(source="3.png")]
		private var IMG0 : Class;
		[Embed(source="2.jpg")]
		private var IMG1 : Class;
		
		private var scene : Viewer3D;
		
		public function Monkey() {
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
//			this.addChild(new Studio());	
			this.stage.nativeWindow.maximize();
			
			this.scene = new Viewer3D(this);
			this.scene.camera.transform.setPosition(9.91862964630127,166.78111267089844,-156.79806518554688);
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;
			this.scene.addEventListener(Scene3D.CREATE, onCreate);
			
			var water : Water3D = new Water3D(new BitmapCubeTexture(new IMG0().bitmapData), new Bitmap2DTexture(new IMG1().bitmapData));
			this.scene.addChild(water);
//			this.scene.addChild(new Grid3D());
			
			setTimeout(function():void{
				water.dispose();
			}, 5000);
			
			addChild(new FPSStats());
		}
		
		protected function onCreate(event:Event) : void {
			this.scene.context.enableErrorChecking = true;		
		}
		
	}
}
