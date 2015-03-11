package ide.plugins.groups.particles.lifetime {

	import flash.events.Event;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleLifetimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.GradientColor;
	
	import ui.core.controls.GradientColorBar;
	import ui.core.controls.Image;
	import ui.core.controls.Layout;
	import ui.core.event.ControlEvent;
	import ui.core.type.ColorMode;

	public class LifetimeColor extends ParticleLifetimeGroup {
		
		private var _colors  : GradientColorBar;
		private var _alphas  : GradientColorBar;
		private var _texture : Image;
		private var layout   : Layout;
		
		public function LifetimeColor() {
			super("LifetimeColor");
			this.removeAllControls();
			this.layout = new Layout();
			this.contentHeight = 80;
			this.addControl(this.layout);
			this._colors = layout.addControl(new GradientColorBar(), "Colors:") as GradientColorBar;
			this._alphas = layout.addControl(new GradientColorBar(), "Alphas:") as GradientColorBar;
			this._colors.mode = ColorMode.MODE_RGB;
			this._alphas.mode = ColorMode.MODE_A;
			this._alphas.addEventListener(ControlEvent.CHANGE, changeColorAndAlphas);
			this._colors.addEventListener(ControlEvent.CHANGE, changeColorAndAlphas);
		}
		
		private function changeColorAndAlphas(event:Event) : void {
			var grad : GradientColor = new GradientColor();
			grad.setColors(_colors.colors, _colors.ratios);
			grad.setAlphas(_alphas.alphas, _alphas.ratios);
			this.particle.colorLifetime = grad;
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.open = false;
			this._colors.removeAllKeys();
			this._alphas.removeAllKeys();
			var colorLifetime : GradientColor = particle.colorLifetime;
			for (var i:int = 0; i < particle.colorLifetime.colors.length; i++) {
				this._colors.addKey(colorLifetime.colors[i], 1, colorLifetime.colorRatios[i]);
			}
			for (var j:int = 0; j < particle.colorLifetime.alphas.length; j++) {
				this._alphas.addKey(0, colorLifetime.alphas[j], colorLifetime.alphaRatios[j]);
			}
		}
		
	}
}
