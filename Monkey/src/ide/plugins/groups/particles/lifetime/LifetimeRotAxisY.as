package ide.plugins.groups.particles.lifetime {

	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleLifetimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;

	/**
	 * 运行期旋转关键帧旋转轴Y
	 * @author Neil
	 *
	 */
	public class LifetimeRotAxisY extends ParticleLifetimeGroup {

		public function LifetimeRotAxisY() {
			super("LifetimeRotAxisY");
		}

		override protected function onChangeLifetime(e : Event) : void {
			this.data.axisY.datas = new Vector.<Point>();

			for each (var p : Point in this.curve.points) {
				this.data.axisY.datas.push(p.clone());
			}
			this.data.axisY.yValue = this.curve.axisYValue;
			super.onChangeLifetime(e);
		}

		override public function updateGroup(app : App, particle : ParticleSystem) : void {
			super.updateGroup(app, particle);
			this.data = particle.userData.lifetime;
			this.curve.axisYValue = this.data.axisY.yValue;
			this.curve.points = this.data.axisY.datas;
		}

	}
}
