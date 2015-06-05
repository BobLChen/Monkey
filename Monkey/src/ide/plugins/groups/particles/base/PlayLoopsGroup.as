package ide.plugins.groups.particles.base {

	import flash.events.Event;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleBaseGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.CheckBox;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

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
	 * @author Neil
	 * @date   May 5, 2015
	 */
	public class PlayLoopsGroup extends ParticleBaseGroup {
		
		private var playLoops : Spinner;
		
		/**
		 * 自动旋转 
		 * 
		 */		
		public function PlayLoopsGroup() {
			super();
			this.orientation = HORIZONTAL;
			this.playLoops = new Spinner(1, 1, 99999, 2, 1);
			this.addControl(new Label("PlayLoops:"));
			this.addControl(playLoops);
			this.maxHeight = 20;
			this.minHeight = 20;
			this.playLoops.addEventListener(ControlEvent.CHANGE, change);
		}
		
		private function change(event:Event) : void {
			this.particle.playLoops = this.playLoops.value;	
		}
				
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.playLoops.value = particle.playLoops;
		}
		
	}
}
