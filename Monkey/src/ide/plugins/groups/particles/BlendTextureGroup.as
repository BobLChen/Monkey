package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.texture.Texture3D;
	import L3D.system.Device3D;
	
	import ide.App;
	import ui.core.controls.GradientColor;
	import ui.core.controls.Image;
	import ui.core.event.ControlEvent;
	import ui.core.type.ColorMode;
	import ui.core.utils.FileUtils;

	public class BlendTextureGroup extends ParticlesProperties {
		
		private var _colors : GradientColor;
		private var _alphas : GradientColor;
		private var _texture : Image;
		
		public function BlendTextureGroup() {
			super("BlendAction");
			accordion.contentHeight = 140;
			layout.margins = 2;
			layout.space = 0;
			layout.addVerticalGroup().maxHeight = 60;
			_colors = layout.addControl(new GradientColor(), "Colors:") as GradientColor;
			_alphas = layout.addControl(new GradientColor(), "Alphas:") as GradientColor;
			_texture = layout.addControl(new Image(Device3D.nullBitmapData, true, 100, 100), "Texture:") as Image;
			
			_alphas.addEventListener(ControlEvent.CHANGE, changeColorAndAlphas);
			_alphas.mode = ColorMode.MODE_A;
			_colors.addEventListener(ControlEvent.CHANGE, changeColorAndAlphas);
			_colors.mode = ColorMode.MODE_RGB;
			_texture.addEventListener(ControlEvent.CLICK, changeTexture);
			_texture.view.addEventListener(MouseEvent.RIGHT_CLICK, removeTexture);
		}
		
		protected function removeTexture(event:Event) : void {
			_particles.blendTexture = null;
			_texture.source = Device3D.nullBitmapData;
			_particles.userData.blendTextureID = null;
		}
		
		protected function changeTexture(event:Event) : void {
			var file : FileUtils = new FileUtils();
			file.addEventListener(FileUtils.IMAGE, function(e:Event):void{
				var texture : Texture3D = new Texture3D(file.bitmap);
				_particles.blendTexture = texture;		
				_texture.source = file.bitmap;
				_particles.userData.blendTextureID = file.name;
			});
			file.openForImage([new FileFilter("Image","*.png;*.PNG;*.JPG;*.jpg;*.JPEG;*.jpeg")]);
		}
		
		protected function changeColorAndAlphas(event:Event) : void {
			_particles.setColors(_colors.colors, _colors.ratios);
			_particles.setAlphas(_alphas.alphas, _alphas.ratios);
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			var colors : Array = this._particles.getColors();
			var colorRatios : Array = this._particles.getColorRatios();
			var alphas : Array = this._particles.getAlphas();
			var alphaRatios : Array = this._particles.getAlphaRatios();
			this._colors.removeAllKeys();
			this._alphas.removeAllKeys();
			for (var i:int = 0; i < colors.length; i++) {
				this._colors.addKey(colors[i], 1, colorRatios[i]);
			}
			for (var j:int = 0; j < alphas.length; j++) {
				this._alphas.addKey(0, alphas[j], alphaRatios[j]);
			}
			if (_particles.blendTexture != null) {
				_texture.source = _particles.blendTexture.bitmapData;
			} else {
				_texture.source = Device3D.nullBitmapData;
			}
		}
		
	}
}
