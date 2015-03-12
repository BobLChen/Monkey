package ide.plugins.groups.particles.lifetime {

	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleLifetimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;

	/**
	 * 运行期关键帧旋转角度
	 * @author Neil
	 *
	 */
	public class LifetimeRotAngle extends ParticleLifetimeGroup {

		public function LifetimeRotAngle() {
			super("LifetimeRotAngle");
		}

		override protected function onChangeLifetime(e : Event) : void {
			this.data.angle.datas = new Vector.<Point>();
			for each (var p : Point in this.curve.points) {
				this.data.angle.datas.push(p.clone());
			}
			this.data.angle.yValue = this.curve.axisYValue;
			super.onChangeLifetime(e);
		}

		override public function updateGroup(app : App, particle : ParticleSystem) : void {
			super.updateGroup(app, particle);
			this.data = particle.userData.lifetime;
			this.curve.axisYValue = this.data.angle.yValue;
			this.curve.points = this.data.angle.datas;
		}

	}
}
