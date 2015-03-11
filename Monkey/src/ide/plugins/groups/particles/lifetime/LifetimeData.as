package ide.plugins.groups.particles.lifetime {
	
	import flash.geom.Point;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.Linears;
	
	public class LifetimeData {
		
		public var speedX 	: Linears;
		public var speedY 	: Linears;
		public var speedZ 	: Linears;
		public var axisX   	: Linears;
		public var axisY   	: Linears;
		public var axisZ   	: Linears;
		public var angle	: Linears;
		public var size   	: Linears;
		public var lifetime : Number;
		
		public function LifetimeData() {
			
		}
		
		public function init() : void {
			// 生成默认的lifetime数据，只适用于编辑器
			var lifetimes : Array = [];
			var step : Number = 1 / (ParticleSystem.MAX_KEY_NUM - 1);
			for (var i:int = 0; i < 8; i++) {
				var curve : Linears = new Linears();
				var value : Number  = i >= 6 ? 1 : 0;
				// 5个关键帧
				for (var j:int = 0; j < ParticleSystem.MAX_KEY_NUM; j++) {
					curve.datas.push(new Point(j * step, value));
				}
				lifetimes.push(curve);
			}
			this.lifetime = 5;				// 初始时默认lifetime为5
			this.speedX = lifetimes[0];
			this.speedY = lifetimes[1];
			this.speedZ = lifetimes[2];
			this.axisX = lifetimes[3];
			this.axisY = lifetimes[4];
			this.axisZ = lifetimes[5];
			this.angle = lifetimes[6];
			this.size = lifetimes[7];
		}
		
	}
}
