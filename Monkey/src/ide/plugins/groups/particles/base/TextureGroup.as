package ide.plugins.groups.particles.base {

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.utils.FileUtils;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.Texture3DUtils;
	
	import ui.core.container.Accordion;
	import ui.core.container.Box;
	import ui.core.controls.Image;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	
	/**
	 * 贴图group 
	 * @author Neil
	 * 
	 */	
	public class TextureGroup extends Accordion {
		
		private var app	 	: App;
		private var particle: ParticleSystem;
		private var image   : Image;
		private var rows    : Spinner;
		private var columns : Spinner;
		
		public function TextureGroup() {
			super("Texture");
			this.image 	= new Image(Texture3DUtils.nullBitmapData, true, 100, 100);
			this.rows  	= new Spinner(1, 1, 9999, 2, 1);
			this.columns= new Spinner(1, 1, 9999, 2, 1);
			var rowBox : Box = new Box();
			rowBox.orientation = Box.HORIZONTAL;
			rowBox.addControl(new Label("Rows:"));
			rowBox.addControl(this.rows);
			rowBox.maxHeight = 20;
			var colBox : Box = new Box();
			colBox.addControl(new Label("Columns:"));
			colBox.addControl(this.columns);
			colBox.orientation = Box.HORIZONTAL;
			colBox.maxHeight = 20;
			this.addControl(rowBox);
			this.addControl(colBox);
			this.addControl(image);
			this.contentHeight = 150;
			this.rows.addEventListener(ControlEvent.CHANGE, 	changeFrame);
			this.columns.addEventListener(ControlEvent.CHANGE, 	changeFrame);
			this.image.addEventListener(ControlEvent.CLICK,	 	changeImage);
			this.open = false;
		}
		
		private function changeImage(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.openForImage(function(bmp : BitmapData):void{
				particle.image = bmp;
				image.source = bmp;
				particle.userData.imageData = file.bytes;
				particle.userData.imageName = file.file.nativePath;
			});
		}
				
		private function changeFrame(event:Event) : void {
			this.particle.frame = new Point(this.rows.value, this.columns.value);
		}
		
		public function updateGroup(app : App, particle:ParticleSystem):void {
			this.open = false;
			this.app = app;
			this.particle = particle;
			if (particle.userData.optimize) {
				this.enabled = false;
			}
			this.rows.value    = particle.frame.x;
			this.columns.value = particle.frame.y;
			this.image.source  = particle.texture.bitmapData;
		}
		
	}
}
