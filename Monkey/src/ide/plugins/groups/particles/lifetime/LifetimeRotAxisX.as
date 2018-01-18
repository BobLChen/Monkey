package ide.plugins.groups.particles.lifetime {

	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.plugins.groups.particles.ParticleLifetimeGroup;
	
	import monkey.core.entities.particles.ParticleSystem;

	/**
	 * 运行期旋转关键帧旋转轴X
	 * @author Neil
	 *
	 */
	public class LifetimeRotAxisX extends ParticleLifetimeGroup {

		public function LifetimeRotAxisX() {
			super("LifetimeRotAxisX");
		}

		override protected function onChangeLifetime(e : Event) : void {
			this.data.axisX.datas = new Vector.<Point>();

			for each (var p : Point in this.curve.points) {
				this.data.axisX.datas.push(p.clone());
			}
			this.data.axisX.yValue = this.curve.axisYValue;
			super.onChangeLifetime(e);
		}

		override public function updateGroup(app : App, particle : ParticleSystem) : void {
			super.updateGroup(app, particle);
			this.data = particle.userData.lifetime;
			this.curve.axisYValue = this.data.axisX.yValue;
			this.curve.points = this.data.axisX.datas;
		}

	}
}
