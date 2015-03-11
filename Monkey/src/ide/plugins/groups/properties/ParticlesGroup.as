package ide.plugins.groups.properties {

	import flash.events.Event;
	
	import ide.App;
	import ide.events.LogEvent;
	import ide.plugins.groups.particles.TimeGroup;
	import ide.plugins.groups.particles.base.BillboardGroup;
	import ide.plugins.groups.particles.base.MaxParticleGroup;
	import ide.plugins.groups.particles.base.TextureGroup;
	import ide.plugins.groups.particles.emission.BurstsGroup;
	import ide.plugins.groups.particles.emission.DurationGroup;
	import ide.plugins.groups.particles.emission.LoopsGroup;
	import ide.plugins.groups.particles.emission.RateGroup;
	import ide.plugins.groups.particles.lifetime.LifetimeColor;
	import ide.plugins.groups.particles.lifetime.LifetimeRotAngle;
	import ide.plugins.groups.particles.lifetime.LifetimeRotAxisX;
	import ide.plugins.groups.particles.lifetime.LifetimeRotAxisY;
	import ide.plugins.groups.particles.lifetime.LifetimeRotAxisZ;
	import ide.plugins.groups.particles.lifetime.LifetimeSize;
	import ide.plugins.groups.particles.lifetime.LifetimeSpeedX;
	import ide.plugins.groups.particles.lifetime.LifetimeSpeedY;
	import ide.plugins.groups.particles.lifetime.LifetimeSpeedZ;
	import ide.plugins.groups.particles.shape.ShapeGroup;
	import ide.plugins.groups.particles.start.StartColorGroup;
	import ide.plugins.groups.particles.start.StartDelayGroup;
	import ide.plugins.groups.particles.start.StartLifetimeGroup;
	import ide.plugins.groups.particles.start.StartRotationXGroup;
	import ide.plugins.groups.particles.start.StartRotationYGroup;
	import ide.plugins.groups.particles.start.StartRotationZGroup;
	import ide.plugins.groups.particles.start.StartSizeGroup;
	import ide.plugins.groups.particles.start.StartSpeedGroup;
	
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
		private var groups 		: Array;
		private var time		: TimeGroup;
				
		public function ParticlesGroup() {
			super("Particles", true);
			this.groups = [];
			this.accordion.contentHeight = 1500;
			this.layout.margins = 2.5;
			this.layout.space = 1;
			this.time = this.layout.addControl(new TimeGroup()) as TimeGroup;
			this.groups.push(time);
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new MaxParticleGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new BillboardGroup()));
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
			this.groups.push(this.layout.addControl(new StartSizeGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartRotationXGroup()));
			this.groups.push(this.layout.addControl(new StartRotationYGroup()));
			this.groups.push(this.layout.addControl(new StartRotationZGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartColorGroup()));
			
			this.groups.push(this.layout.addControl(new TextureGroup()));
			this.groups.push(this.layout.addControl(new LifetimeColor()));
			this.groups.push(this.layout.addControl(new ShapeGroup()));
			this.groups.push(this.layout.addControl(new LifetimeSize()));
			this.groups.push(this.layout.addControl(new LifetimeSpeedX()))
			this.groups.push(this.layout.addControl(new LifetimeSpeedY()));
			this.groups.push(this.layout.addControl(new LifetimeSpeedZ()));
			this.groups.push(this.layout.addControl(new LifetimeRotAxisX()));
			this.groups.push(this.layout.addControl(new LifetimeRotAxisY()));
			this.groups.push(this.layout.addControl(new LifetimeRotAxisZ()));
			this.groups.push(this.layout.addControl(new LifetimeRotAngle()));
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if (app.selection.main is ParticleSystem) {
				this._particles = _app.selection.main as ParticleSystem;
				this._particles.addEventListener(ParticleSystem.BUILD, onBuildParticle);
				for each (var group : Object in this.groups) {
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
