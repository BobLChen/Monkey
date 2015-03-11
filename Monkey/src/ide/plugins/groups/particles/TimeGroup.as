package ide.plugins.groups.particles {
	
	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.Button;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class TimeGroup extends ParticleBaseGroup {
		
		private var play : Button;
		private var stop : Button;
		private var time : Spinner;
		
		public function TimeGroup() {
			super();
			this.play = new Button("Play");
			this.stop = new Button("Stop");
			this.time = new Spinner();
			this.orientation = HORIZONTAL;
			this.minHeight = 18;
			this.maxHeight = 18;
			this.time.maxHeight = 18;
			this.time.minHeight = 18;
			this.addControl(play);
			this.addControl(stop);
			this.addControl(time);
			
			this.play.addEventListener(ControlEvent.CLICK, onClickPlay);
			this.stop.addEventListener(ControlEvent.CLICK, onClickStop);
			this.time.addEventListener(ControlEvent.CHANGE,	onChangeTime);
		}
		
		private function onChangeTime(event:Event) : void {
			this.play.text = "Play";
			this.particle.animator.gotoAndStop(this.time.value);
		}
		
		private function onClickStop(event:Event) : void {
			this.particle.animator.gotoAndStop(0);
			this.time.value = 0;
			this.play.text = "Play";
		}
		
		private function onClickPlay(event:Event) : void {
			if (this.play.text == "Play") {
				this.play.text = "Pause";
				this.particle.animator.play();
			} else {
				this.play.text = "Play";
				this.particle.animator.stop();
			}
		}		
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.play.text  = particle.animator.playing ? "Pause" : "Play";
			this.time.value = particle.animator.currentFrame;
			this.particle.addEventListener(Object3D.ENTER_DRAW, onUpdate);
		}
		
		private function onUpdate(event:Event) : void {
			this.time.value = this.particle.animator.currentFrame;
		}
		
	}
}
