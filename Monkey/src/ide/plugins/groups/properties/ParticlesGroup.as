package ide.plugins.groups.properties {

	import flash.events.Event;
	
	import ide.App;
	import ide.events.LogEvent;
	import ide.plugins.groups.particles.BurstsGroup;
	import ide.plugins.groups.particles.DurationGroup;
	import ide.plugins.groups.particles.LoopsGroup;
	import ide.plugins.groups.particles.MaxParticleGroup;
	import ide.plugins.groups.particles.ParticleAttribute;
	import ide.plugins.groups.particles.RateGroup;
	import ide.plugins.groups.particles.StartColorGroup;
	import ide.plugins.groups.particles.StartDelayGroup;
	import ide.plugins.groups.particles.StartLifetimeGroup;
	import ide.plugins.groups.particles.StartRotationXGroup;
	import ide.plugins.groups.particles.StartRotationYGroup;
	import ide.plugins.groups.particles.StartRotationZGroup;
	import ide.plugins.groups.particles.StartSizeXGroup;
	import ide.plugins.groups.particles.StartSizeYGroup;
	import ide.plugins.groups.particles.StartSizeZGroup;
	import ide.plugins.groups.particles.StartSpeedGroup;
	import ide.plugins.groups.particles.TimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.controls.Separator;
	
	/**
	 * 粒子系统 
	 * @author Neil
	 * 
	 */	
	public class ParticlesGroup extends PropertiesGroup {

		private var _app 	    : App;
		private var _particles  : ParticleSystem;
		private var groups 		: Vector.<ParticleAttribute>;
		private var time		: TimeGroup;
				
		public function ParticlesGroup() {
			super("Particles", true);
			this.groups = new Vector.<ParticleAttribute>();
			this.accordion.contentHeight = 1800;
			this.layout.margins = 2.5;
			this.layout.space = 1;
			this.time = this.layout.addControl(new TimeGroup()) as TimeGroup;
			this.groups.push(time);
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new MaxParticleGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new RateGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new BurstsGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new DurationGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new LoopsGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartDelayGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartLifetimeGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartSpeedGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartSizeXGroup()));
			this.groups.push(this.layout.addControl(new StartSizeYGroup()));
			this.groups.push(this.layout.addControl(new StartSizeZGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartRotationXGroup()));
			this.groups.push(this.layout.addControl(new StartRotationYGroup()));
			this.groups.push(this.layout.addControl(new StartRotationZGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartColorGroup()));
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if (app.selection.main is ParticleSystem) {
				this._particles = _app.selection.main as ParticleSystem;
				this._particles.addEventListener(ParticleSystem.BUILD, onBuildParticle);
				for each (var group : ParticleAttribute in this.groups) {
					group.updateGroup(app, _particles);
				}
				this.layout.draw();
				return true;
			}
			return false;
		}
		
		private function onBuildParticle(event:Event) : void {
			this._app.dispatchEvent(new LogEvent("Particle Build Success"));
		}
		
	}
}
