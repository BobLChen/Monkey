package ide.plugins.groups.particles {
	
	import flash.events.Event;
	
	import ide.App;
	import ide.events.SelectionEvent;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.prop.color.PropConstColor;
	import monkey.core.entities.particles.prop.color.PropGradientColor;
	import monkey.core.entities.particles.prop.color.PropRandomTwoConstColor;
	
	import ui.core.container.Box;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.GradientColorBar;
	import ui.core.controls.Label;
	import ui.core.event.ControlEvent;
	import ui.core.type.ColorMode;

	/**
	 * 初始颜色 
	 * @author Neil
	 * 
	 */	
	public class StartColorGroup extends ParticleAttribute {
		
		[Embed(source="arrow.png")]
		private static var ARROW : Class;
		
		private var arrow	 : ImageButtonMenu;
		private var label	 : Label;
		private var header	 : Box;
		
		private var oneColor : ColorPicker;
		private var minColor : ColorPicker;
		private var maxColor : ColorPicker;
		
		private var gradColor : GradientColorBar;
		private var gradAlpha : GradientColorBar;
		
		public function StartColorGroup() {
			super();
			
			this.header	  = new Box();
			this.header.orientation = Box.HORIZONTAL;
			this.arrow	  = new ImageButtonMenu(new ARROW());
			this.label	  = new Label("StartColor:", 160);
			this.header.addControl(this.arrow);
			this.header.addControl(this.label);
			this.header.maxHeight = 20;
			
			this.oneColor = new ColorPicker(0, 1, ColorMode.MODE_RGBA);
			this.minColor = new ColorPicker(0, 1, ColorMode.MODE_RGBA);
			this.maxColor = new ColorPicker(0, 1, ColorMode.MODE_RGBA);
						
			this.gradColor = new GradientColorBar();
			this.gradAlpha = new GradientColorBar();
			
			this.gradColor.mode = ColorMode.MODE_RGB;
			this.gradAlpha.mode = ColorMode.MODE_A;
			
			this.oneColor.addEventListener(ControlEvent.CHANGE, changeOne);
			this.minColor.addEventListener(ControlEvent.CHANGE, changeRandomTwoConst);
			this.maxColor.addEventListener(ControlEvent.CHANGE, changeRandomTwoConst);
			this.gradColor.addEventListener(ControlEvent.CHANGE, changeGradient);
			this.gradAlpha.addEventListener(ControlEvent.CHANGE, changeGradient);
			
			this.arrow.addMenu("Const", changeToConst);
			this.arrow.addMenu("Gradient", changeToGradient);
			this.arrow.addMenu("RandomTwoConst", changeToRandomTwoConst);
		}
		
		private function changeGradient(event:Event) : void {
			var gradient : PropGradientColor = new PropGradientColor();
			gradient.color.setColors(gradColor.colors, gradColor.ratios);
			gradient.color.setAlphas(gradAlpha.alphas, gradAlpha.ratios);
			this.particle.startColor = gradient;
		}
		
		private function changeRandomTwoConst(event:Event) : void {
			this.particle.startColor = new PropRandomTwoConstColor(this.minColor.color, this.minColor.alpha, this.maxColor.color, this.maxColor.alpha);
		}
		
		private function changeOne(event:Event) : void {
			this.particle.startColor = new PropConstColor(this.oneColor.color, this.oneColor.alpha);
		}
		
		private function changeToRandomTwoConst(e : Event) : void {
			this.particle.startColor = new PropRandomTwoConstColor();
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		private function changeToGradient(e : Event) : void {
			this.particle.startColor = new PropGradientColor();
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		private function changeToConst(e : Event) : void {
			this.particle.startColor = new PropConstColor();
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.removeAllControls();
			this.addControl(this.header);
			
			this.minHeight = 20;
			this.maxHeight = 20;
			
			if (particle.startColor is PropConstColor) {
				this.orientation = HORIZONTAL;
				this.addControl(oneColor);
				this.oneColor.color = (particle.startColor as PropConstColor).color;
				this.oneColor.alpha = (particle.startColor as PropConstColor).alpha;
			} else if (particle.startColor is PropRandomTwoConstColor) {
				var propColor : PropRandomTwoConstColor = particle.startColor as PropRandomTwoConstColor;
				this.orientation = HORIZONTAL;
				this.addControl(this.minColor);
				this.addControl(this.maxColor);
				this.minColor.color = propColor.minColor;
				this.maxColor.color = propColor.maxColor;
				this.minColor.alpha = propColor.minAlpha;
				this.maxColor.alpha = propColor.maxAlpha;
			} else if (particle.startColor is PropGradientColor) {
				var propGrad : PropGradientColor = particle.startColor as PropGradientColor;
				this.minHeight = 40;
				this.maxHeight = 40;
				this.orientation = HORIZONTAL;
				this.addControl(this.gradColor);
				this.addControl(this.gradAlpha);
				this.gradColor.removeAllKeys();
				this.gradAlpha.removeAllKeys();
				for (var i:int = 0; i < propGrad.color.colors.length; i++) {
					this.gradColor.addKey(propGrad.color.colors[i], 1, propGrad.color.colorRatios[i]);
				}
				for (i = 0; i < propGrad.color.alphas.length; i++) {
					this.gradAlpha.addKey(0, propGrad.color.alphas[i], propGrad.color.alphaRatios[i]);
				}
			}
		}
		
	}
}
