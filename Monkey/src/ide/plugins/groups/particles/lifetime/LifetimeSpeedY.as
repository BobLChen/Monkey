package ide.plugins.groups.particles.lifetime {
	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleLifetimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;

	/**
	 * lifetime speed x 
	 * @author Neil
	 * 
	 */	
	public class LifetimeSpeedY extends ParticleLifetimeGroup {
		
		public function LifetimeSpeedY() {
			super("LifetimeSpeedY");
		}
		
		override protected  function onChangeLifetime(e : Event) : void {
			this.data.speedY.datas = new Vector.<Point>();
			for each (var p : Point in this.curve.points) {
				this.data.speedY.datas.push(p.clone());
			}
			super.onChangeLifetime(e);
		}
		
		override public function updateGroup(app : App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.open = false;
			this.data = particle.userData.lifetime;
			this.curve.points = this.data.speedY.datas;
		}
		
	}
}
