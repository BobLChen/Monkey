package monkey.core.entities.particles.shape {
	import flash.geom.Vector3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;
	
	/**
	 * box 
	 * @author Neil
	 * 
	 */	
	public class BoxShape extends ParticleShape {
		
		public var min : Vector3D;
		public var max : Vector3D;
		/** 是否平滑 */
		public var smooth : Boolean = false;
		public var random : Boolean = false;
				
		public function BoxShape() {
			super();
			this.min = new Vector3D(-1, -1, -1);
			this.max = new Vector3D( 1,  1,  1);
		}
		
		override protected function createVerticesVelecityOffset(i:int, particle : ParticleSystem, vertices:Vector.<Number>, velocity:Vector.<Number>, offsets:Vector.<Number>):void {
			// mode顶点数据
			var modeVertices : Vector.<Number> = mode.getVertexVector(Surface3D.POSITION);
			
			var tx : Number = 0;
			var ty : Number = 0;
			var tz : Number = 0;
			
			if (smooth) {
				var ratio : Number = i * 1.0 / (particle.maxParticles - 1);
				tx = min.x + (max.x - min.x) * ratio;
				ty = min.y + (max.y - min.y) * ratio;
				tz = min.z + (max.z - min.z) * ratio;
			} else {
				tx = min.x + (max.x - min.x) * Math.random();
				ty = min.y + (max.y - min.y) * Math.random();
				tz = min.z + (max.z - min.z) * Math.random();
			}
			
			vec3.x = 0;
			vec3.y = 1;
			vec3.z = 0;
			
			if (random) {
				vec3.x = Math.random() - 0.5;
				vec3.y = Math.random() - 0.5;
				vec3.z = Math.random() - 0.5;
				vec3.normalize();
			}
			
			for (var j:int = 0; j < vertNum; j++) {
				// 位置
				var step : int = j * 3;
				vertices.push(modeVertices[step + 0]);
				vertices.push(modeVertices[step + 1]);
				vertices.push(modeVertices[step + 2]);
				// 方向
				velocity.push(vec3.x, vec3.y, vec3.z);
				// 位移
				offsets.push(tx, ty, tz);
			}
		}
		
	}
}
