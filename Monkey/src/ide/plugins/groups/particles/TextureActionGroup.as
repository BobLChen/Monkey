package ide.plugins.groups.particles {

	import flash.events.Event;
	import flash.net.FileFilter;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	
	import ide.App;
	import ui.core.controls.Image;
	import ui.core.event.ControlEvent;
	import ui.core.utils.FileUtils;

	public class TextureActionGroup extends ParticlesProperties {

		private var _texture : Image;
		
		public function TextureActionGroup() {
			super("TextureAction");
			layout.space = 0;
			layout.margins = 0;
			layout.maxHeight = 100;
			_texture = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100), "Texture:") as Image;
			_texture.addEventListener(ControlEvent.CLICK, changeTexture);
		}
		
		protected function changeTexture(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, function(e:Event):void{
				_particles.texture = new Texture3D(file.bitmap);
				_texture.source = file.bitmap;
				_particles.userData.textureID = file.name;
			});
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}		
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			_texture.source = particles.texture.bitmapData;
		}
				
		
	}
}
