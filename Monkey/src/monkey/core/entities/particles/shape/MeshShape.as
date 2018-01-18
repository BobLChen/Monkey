package monkey.core.entities.particles.shape {

	import flash.geom.Vector3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.base.Triangle3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.Vector3DUtils;

	public class MeshShape extends ParticleShape {
		
		/** 顶点发射 */
		public static const TYPE_VERTEX 	: int = 0;
		/** 面发射 */
		public static const TYPE_TRIANGLE	: int = 1;
		/** 边发射 */
		public static const TYPE_EDGE		: int = 2;
		
		public var type : int = TYPE_VERTEX;
				
		public var surf : Surface3D;
		
		public function MeshShape() {
			super();
		}
		
		override protected function createVerticesVelecityOffset(i : int, particle : ParticleSystem, vertices : Vector.<Number>, velocity : Vector.<Number>, offsets : Vector.<Number>) : void {
			
			var tx : Number = 0;
			var ty : Number = 0;
			var tz : Number = 0;
						
			var vertexs : Vector.<Number> = surf.getVertexVector(Surface3D.POSITION);
			var tris	: Vector.<Triangle3D> = surf.ploys;
			
			var idx : int = 0;
			
			if (type == TYPE_VERTEX) {
				idx = Math.random() * (vertexs.length / 3 - 1);
				tx = vertexs[idx * 3 + 0];
				ty = vertexs[idx * 3 + 1];
				tz = vertexs[idx * 3 + 2];
				var normals : Vector.<Number> = surf.getVertexVector(Surface3D.NORMAL);
				if (normals) {
					vec3.x = normals[idx * 3 + 0];
					vec3.y = normals[idx * 3 + 1];
					vec3.z = normals[idx * 3 + 2];
				} else {
					vec3.x = Math.random() - 0.5;
					vec3.y = Math.random() - 0.5;
					vec3.z = Math.random() - 0.5;
				}
			} else if (type == TYPE_TRIANGLE) {
				idx = Math.random() * (tris.length - 1);
				var tri : Triangle3D = tris[idx];
				Vector3DUtils.interpolate(tri.v0, tri.v1, Math.random(), vec3);
				Vector3DUtils.interpolate(vec3, tri.v2, Math.random(), vec3);
				tx = vec3.x;
				ty = vec3.y;
				tz = vec3.z;
				vec3.setTo(tri.normal.x, tri.normal.y, tri.normal.z);
			} else if (type == TYPE_EDGE) {
				idx = Math.random() * (tris.length - 1);
				tri = tris[idx];
				var edges : Array = [tri.v0, tri.v1, tri.v2];
				idx = int(Math.random() * (edges.length - 1));
				var pa : Vector3D = edges[idx];
				edges.splice(idx, 1);
				var pb : Vector3D = edges[int(Math.random() * (edges.length - 1))];
				Vector3DUtils.interpolate(pa, pb, Math.random(), vec3);
				tx = vec3.x;
				ty = vec3.y;
				tz = vec3.z;
				vec3.setTo(tri.normal.x, tri.normal.y, tri.normal.z);
			}
			vec3.normalize();
			
			var modeVertices : Vector.<Number> = mode.getVertexVector(Surface3D.POSITION);
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
