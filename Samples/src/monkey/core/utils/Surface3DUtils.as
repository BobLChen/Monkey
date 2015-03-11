package monkey.core.utils {
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.base.Triangle3D;

	public class Surface3DUtils {
		
		/**
		 * 生成三角形 
		 * @param surface
		 * @return 
		 */		
		public static function buildPolys(surface : Surface3D) : Vector.<Triangle3D> {
			var ploys   : Vector.<Triangle3D> = new Vector.<Triangle3D>();
			var indices : Vector.<uint> = surface.indexVector;
			var vertexs : Vector.<Number> = surface.getVertexVector(Surface3D.POSITION);
			var uvs		: Vector.<Number> = surface.getVertexVector(Surface3D.UV0);
			var i   	: int = 0;
			var len 	: int = indices.length;
			while (i < len) {
				var idx0 : uint = indices[i++];
				var idx1 : uint = indices[i++];
				var idx2 : uint = indices[i++];
				var step0 : int = idx0 * 3;
				var step1 : int = idx1 * 3;
				var step2 : int = idx2 * 3;
				// 逆时针
				var v0 : Vector3D = new Vector3D(vertexs[step2], vertexs[step2 + 1], vertexs[step2 + 2]);
				var v1 : Vector3D = new Vector3D(vertexs[step1], vertexs[step1 + 1], vertexs[step1 + 2]);
				var v2 : Vector3D = new Vector3D(vertexs[step0], vertexs[step0 + 1], vertexs[step0 + 2]);
				var tri: Triangle3D = new Triangle3D(v0, v1, v2);
				ploys.push(tri);
				if (uvs) {
					step0 = idx0 * 2;
					step1 = idx1 * 2;
					step2 = idx2 * 2;
					tri.uv0 = new Point(uvs[step2], uvs[step2 + 1]);
					tri.uv1 = new Point(uvs[step1], uvs[step1 + 1]);
					tri.uv2 = new Point(uvs[step0], uvs[step0 + 1]);
				}
			}
			return ploys;
		}
		
	}
}
