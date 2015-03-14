package monkey.core.entities.particles.shape {

	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;

	/**
	 * shape
	 * @author Neil
	 *
	 */
	public class ParticleShape {

		/** 临时变量 */
		protected static const vec3 : Vector3D = new Vector3D();
		
		private var _mode 	 : Surface3D; 	// mode数据
		private var _vertNum : int = 0; 	// 顶点数量
		
		public function ParticleShape() {
			
		}
		
		public function set vertNum(value:int):void {
			_vertNum = value;
		}

		/**
		 * 顶点数量
		 * @return
		 *
		 */
		public function get vertNum() : int {
			return _vertNum;
		}
		
		/**
		 * 粒子模型
		 * @return
		 *
		 */
		public function get mode() : Surface3D {
			return _mode;
		}

		/**
		 * 粒子模型 
		 * @param value
		 * 
		 */		
		public function set mode(value : Surface3D) : void {
			this._mode    = value;
			this._vertNum = value.getVertexVector(Surface3D.POSITION).length / 3;
		}
		
		/**
		 * 生成对应的顶点坐标以及线速度
		 * @param particle
		 *
		 */
		public function generate(particle : ParticleSystem) : void {
			this.generateUV(particle);
			this.generateIndices(particle);
			this.generateOffsetVelecity(particle);
		}
		
		protected function generateOffsetVelecity(particle : ParticleSystem) : void {
			var size    : int = Math.ceil(particle.maxParticles * vertNum / 65535);
			var perSize : int = 65535 / vertNum;
			for (var n  : int = 0; n < size; n++) {
				var num : int = 0;
				if (n == size - 1) {
					num = particle.maxParticles - perSize * n;
				} else {
					num = perSize;
				}
				var vertices : Vector.<Number> = new Vector.<Number>();						// 粒子系统顶点数据
				particle.surfaces[n].setVertexVector(Surface3D.POSITION, vertices, 3);
				var velocity : Vector.<Number> = new Vector.<Number>();						// 粒子系统线速度，速度和方向整合到一起。(速度方向使用custom1寄存器)
				particle.surfaces[n].setVertexVector(Surface3D.CUSTOM1,  velocity, 3);
				var offsets : Vector.<Number> = new Vector.<Number>();						// 偏移量
				particle.surfaces[n].setVertexVector(Surface3D.CUSTOM4,  offsets,  3);
				// 生成对应的位置数据以及方向
				for (var i : int = 0; i < num; i++) {
					createVerticesVelecityOffset(i, particle, vertices, velocity, offsets);
				}
			}
		}
		
		/**
		 * 生成顶点、速度、偏移数据 
		 * @param i			当前粒子索引
		 * @param particle	粒子
		 * @param vertices	顶点数据
		 * @param velocity	速度矢量
		 * @param offsets	偏移量
		 * 
		 */		
		protected function createVerticesVelecityOffset(i : int, particle : ParticleSystem, vertices : Vector.<Number>, velocity : Vector.<Number>, offsets : Vector.<Number>) : void {

		}

		/**
		 * 生成索引
		 * @param particle
		 *
		 */
		protected function generateIndices(particle : ParticleSystem) : void {
			var size 	: int = Math.ceil(particle.maxParticles * vertNum / 65535);
			var perSize : int = 65535 / vertNum;
			for (var n  : int = 0; n < size; n++) {
				var num : int = 0;
				if (n == size - 1) {
					num = particle.maxParticles - perSize * n;
				} else {
					num = perSize;
				}
				var indices : Vector.<uint> = new Vector.<uint>();
				var idxSize : int = mode.indexVector.length;
				for (var i  : int = 0; i < num; i++) {
					for (var j : int = 0; j < idxSize; j++) {
						indices.push(mode.indexVector[j] + vertNum * i);
					}
				}
				particle.surfaces[n].indexVector = indices;
			}

		}

		/**
		 * 生成uv
		 * @param particle
		 *
		 */
		protected function generateUV(particle : ParticleSystem) : void {
			var size    : int = Math.ceil(particle.maxParticles * vertNum / 65535);
			var perSize : int = 65535 / vertNum;
			for (var n  : int = 0; n < size; n++) {
				var num : int = 0;
				if (n == size - 1) {
					num = particle.maxParticles - perSize * n;
				} else {
					num = perSize;
				}
				// 粒子uv数据
				var uvBytes : ByteArray = new ByteArray();
				uvBytes.endian = Endian.LITTLE_ENDIAN;
				// shape UV数据
				var modeUV : Vector.<Number> = mode.getVertexVector(Surface3D.UV0);
				// 组装uv数据
				var step   : int = 0;
				for (var i : int = 0; i < num; i++) {
					// 遍历shape的所有顶点
					for (var j : int = 0; j < vertNum; j++) {
						step = 2 * j;
						uvBytes.writeFloat(modeUV[step + 0]);
						uvBytes.writeFloat(modeUV[step + 1]);
					}
				}
				particle.surfaces[n].setVertexBytes(Surface3D.UV0, uvBytes, 2);
			}
		}
	}
}
