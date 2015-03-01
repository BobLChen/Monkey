package ide.plugins.groups.properties {

	import ide.App;
	import ide.plugins.groups.particles.DurationGroup;
	import ide.plugins.groups.particles.LoopsGroup;
	import ide.plugins.groups.particles.ParticleAttribute;
	import ide.plugins.groups.particles.StartDelay;
	import ide.plugins.groups.particles.StartLifetime;
	
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
				
		public function ParticlesGroup() {
			super("Particles", true);
			this.groups = new Vector.<ParticleAttribute>();
			this.accordion.contentHeight = 500;
			this.layout.margins = 2.5;
			this.layout.space = 1;
			this.groups.push(this.layout.addControl(new DurationGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new LoopsGroup()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartDelay()));
			this.layout.addControl(new Separator());
			this.groups.push(this.layout.addControl(new StartLifetime()));
			this.layout.addControl(new Separator());
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if (app.selection.main is ParticleSystem) {
				this._particles = _app.selection.main as ParticleSystem;
				for each (var group : ParticleAttribute in this.groups) {
					group.updateGroup(app, _particles);
				}
				this.layout.draw();
				return true;
			}
			return false;
		}
		
	}
}
