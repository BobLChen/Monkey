package monkey.core.entities.particles.shape {
	
	import flash.geom.Vector3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.Vector3DUtils;
	import monkey.core.utils.deg2rad;
	
	/**
	 * Cone发射器 
	 * @author Neil
	 * 
	 */	
	public class ConeShape extends ParticleShape {
		
		/** 高度 */
		public var height : Number = 10;
		/** 角度 */
		public var angle  : Number = 25;
		/** 半径 */
		public var radius : Number = 1;
		/** 从表面发射 */
		public var shell  : Boolean;
		/** 按照体积发射 */
		public var volume : Boolean;
		
		private var start : Vector3D;		// 起点
		private var end   : Vector3D;		// 结束点
		
		public function ConeShape() {
			super();
			this.start = new Vector3D();
			this.end   = new Vector3D();
		}
		
		override protected function createVerticesVelecityOffset(i:int, particle:ParticleSystem, vertices:Vector.<Number>, velocity:Vector.<Number>, offsets:Vector.<Number>):void {
			
			var modeVertices : Vector.<Number> = mode.getVertexVector(Surface3D.POSITION);
			
			vec3.x = Math.random() - 0.5;
			vec3.z = Math.random() - 0.5;
			vec3.y = 0;
			vec3.normalize();
			
			var rad : Number = deg2rad(angle);
			
			if (shell) {
				vec3.scaleBy(radius);						// 从表面发射
			} else {
				vec3.scaleBy(radius * Math.random());		// 随机散装发射
				rad = Math.random() * rad;
			}
			
			start.copyFrom(vec3);							// 粒子起点
			end.copyFrom(start);							// 方向
			end.normalize();
			var dist : Number = Math.tan(rad) * height;
			end.scaleBy(dist);								// 偏移量
			Vector3DUtils.add(start, end, end);				// 偏移angle角度
			end.y = height;									// 结束点
			
			var tx : Number = start.x;
			var ty : Number = start.y;
			var tz : Number = start.z;
			
			Vector3DUtils.sub(end, start, vec3);			// 起点到结束点矢量
			var len : Number = vec3.length;					// 长度
			vec3.normalize();								// 获取单位向量
			// 按照体积来发射
			if (volume) {
				dist = Math.random() * len;
				tx += vec3.x * dist;
				ty += vec3.y * dist;
				tz += vec3.z * dist;
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
