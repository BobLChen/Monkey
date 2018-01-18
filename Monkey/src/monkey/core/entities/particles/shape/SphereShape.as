package monkey.core.entities.particles.shape {

	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;

	/**
	 * sphere发射器
	 * @author Neil
	 *
	 */
	public class SphereShape extends ParticleShape {
		
		/** 半径 */
		public var radius 	: Number = 1;
		/** 从表面发射 */
		public var shell 	: Boolean;
		/** 随机方向 */
		public var random 	: Boolean;
		/** 半圆 */
		public var hemi		: Boolean;
		
		public function SphereShape() {
			super();
		}
		
		override protected function createVerticesVelecityOffset(i:int, particle : ParticleSystem, vertices:Vector.<Number>, velocity:Vector.<Number>, offsets:Vector.<Number>):void {
			// mode顶点数据
			var modeVertices : Vector.<Number> = mode.getVertexVector(Surface3D.POSITION);
			// 位置
			vec3.x = Math.random() - 0.5;
			vec3.y = Math.random() - 0.5;
			vec3.z = Math.random() - 0.5;
			vec3.normalize();
			vec3.scaleBy(radius * (shell ? 1 : Math.random()));
			// 是否为半圆
			if (hemi && vec3.y < 0) {
				vec3.y *= -1;
			}
			var tx : Number = vec3.x;
			var ty : Number = vec3.y;
			var tz : Number = vec3.z;
			// 是否随机方向
			if (random) {
				vec3.x = Math.random() - 0.5;
				vec3.y = Math.random() - 0.5;
				vec3.z = Math.random() - 0.5;
			}
			vec3.normalize();
			// 半圆
			if (hemi && vec3.y < 0) {
				vec3.y *= -1;
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
