package monkey.core.entities.primitives.particles.shape {

	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Surface3D;
	import monkey.core.entities.primitives.particles.ParticleSystem;

	/**
	 * shape
	 * @author Neil
	 *
	 */
	public class ParticleShape {
		
		/** 临时变量 */
		protected static const vec3 : Vector3D = new Vector3D();

		private var _mode 	 : Surface3D; 	// mode数据
		private var _vertNum : int = 0;		// 顶点数量
		
		public function ParticleShape() {

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
		 * 粒子mode
		 * @return
		 *
		 */
		public function get mode() : Surface3D {
			return _mode;
		}

		/**
		 * @private
		 */
		public function set mode(value : Surface3D) : void {
			this._mode 	  = value;
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
		}

		/**
		 * 生成索引
		 * @param particle
		 *
		 */
		public function generateIndices(particle : ParticleSystem) : void {
			var indices : Vector.<uint> = new Vector.<uint>();
			var idxSize : int = mode.indexVector.length;
			for (var i  : int = 0; i < particle.num; i++) {
				for (var j : int = 0; j < idxSize; j++) {
					indices.push(mode.indexVector[j] + vertNum * i);
				}
			}
			particle.surface.indexVector = indices;
		}
		
		/**
		 * 生成uv
		 * @param particle
		 *
		 */
		public function generateUV(particle : ParticleSystem) : void {
			// 粒子uv数据
			var uvBytes : ByteArray = new ByteArray();
			uvBytes.endian = Endian.LITTLE_ENDIAN;
			// shape UV数据
			var modeUV : Vector.<Number> = mode.getVertexVector(Surface3D.UV0);
			// 组装uv数据
			var step : int = 0;
			// 遍历所有的粒子
			for (var i : int = 0; i < particle.num; i++) {
				// 遍历shape的所有顶点
				for (var j : int = 0; j < vertNum; j++) {
					step = 2 * j;
					uvBytes.writeFloat(modeUV[step + 0]);
					uvBytes.writeFloat(modeUV[step + 1]);
				}
			}
			particle.surface.setVertexBytes(Surface3D.UV0, uvBytes, 2);
		}
		
	}
}
