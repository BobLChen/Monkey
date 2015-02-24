package monkey.core.entities.primitives {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.utils.Matrix3DUtils;
	import monkey.core.entities.Mesh3D;

	public class Cube extends Mesh3D {

		private var _width 	 	: Number;
		private var _height 	: Number;
		private var _depth 	 	: Number;
		private var _segments	: int;
		
		public function Cube(width : Number = 10, height : Number = 10, depth : Number = 10, segments : int = 1) {
			super([]);
			
			this._segments 	= segments;
			this._depth 	= depth;
			this._height 	= height;
			this._width 	= width;
			
			this.surfaces[0] = new Surface3D();
			this.surfaces[0].setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
			this.surfaces[0].setVertexVector(Surface3D.NORMAL, new Vector.<Number>(), 3);
			this.surfaces[0].setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
			this.surfaces[0].indexVector  = new Vector.<uint>();
						
			this.createPlane(width, height, (depth * 0.5), segments, "+xy");
			this.createPlane(width, height, (depth * 0.5), segments, "-xy");
			this.createPlane(depth, height, (width * 0.5), segments, "+yz");
			this.createPlane(depth, height, (width * 0.5), segments, "-yz");
			this.createPlane(width, depth, (height * 0.5), segments, "+xz");
			this.createPlane(width, depth, (height * 0.5), segments, "-xz");
			
			this.bounds = new Bounds3D();
			this.bounds.max.setTo( width * 0.5,  height * 0.5,  depth * 0.5);
			this.bounds.min.setTo(-width * 0.5, -height * 0.5, -depth * 0.5);
			this.bounds.length.x = this.bounds.max.x - this.bounds.min.x;
			this.bounds.length.y = this.bounds.max.y - this.bounds.min.y;
			this.bounds.length.z = this.bounds.max.z - this.bounds.min.z;
			this.bounds.center.x = this.bounds.length.x * 0.5 + this.bounds.min.x;
			this.bounds.center.y = this.bounds.length.y * 0.5 + this.bounds.min.y;
			this.bounds.center.z = this.bounds.length.z * 0.5 + this.bounds.min.z;
			this.bounds.radius = Vector3D.distance(bounds.center, bounds.max);			
			
			this.surfaces[0].bounds = bounds;
		}
				
		private function createPlane(width : Number, height : Number, depth : Number, segments : int, axis : String) : void {
			
			var surf : Surface3D = surfaces[0];
			var matrix : Matrix3D = new Matrix3D();
			
			if (axis == "+xy") {
				Matrix3DUtils.setOrientation(matrix, new Vector3D(0, 0, -1));
			} else if (axis == "-xy") {
				Matrix3DUtils.setOrientation(matrix, new Vector3D(0, 0, 1));
			} else if (axis == "+xz") {
				Matrix3DUtils.setOrientation(matrix, new Vector3D(0, 1, 0));
			} else if (axis == "-xz") {
				Matrix3DUtils.setOrientation(matrix, new Vector3D(0, -1, 0));
			} else if (axis == "+yz") {
				Matrix3DUtils.setOrientation(matrix, new Vector3D(1, 0, 0));
			} else if (axis == "-yz") {
				Matrix3DUtils.setOrientation(matrix, new Vector3D(-1, 0, 0));
			}
			
			Matrix3DUtils.setScale(matrix, width, height, 1);
			Matrix3DUtils.translateZ(matrix, depth);
			
			var vertexs : Vector.<Number> = surf.getVertexVector(Surface3D.POSITION);
			var normals : Vector.<Number> = surf.getVertexVector(Surface3D.NORMAL);
			var uvs     : Vector.<Number> = surf.getVertexVector(Surface3D.UV0);
			var raw 	: Vector.<Number> = matrix.rawData;
			var normal 	: Vector3D = Matrix3DUtils.getDir(matrix);
			var i : int = 0;
			var e : int = 0;
			var u : Number = 0;
			var v : Number = 0;
			var x : Number = 0;
			var y : Number = 0;
			i = vertexs.length / 3;
			e = i;
			v = 0;
			while (v <= segments) {
				u = 0;
				while (u <= segments) {
					x = (u / segments) - 0.5;
					y = (v / segments) - 0.5;
					vertexs.push((x * raw[0]) + (y * raw[4]) + raw[12], (x * raw[1]) + (y * raw[5]) + raw[13], (x * raw[2]) + (y * raw[6]) + raw[14]);
					normals.push(normal.x, normal.y, normal.z);
					uvs.push(1 - (u /segments), 1 - (v / segments));
					i++;
					u++;
				}
				v++;
			}
			i = surf.indexVector.length;
			v = 0;
			while (v < segments) {
				u = 0;
				while (u < segments) {
					surf.indexVector[i++] = u + 1 + v * (segments + 1) + e;
					surf.indexVector[i++] = u + 1 + (v + 1) * (segments + 1) + e;
					surf.indexVector[i++] = u + (v + 1) * (segments + 1) + e;
					surf.indexVector[i++] = u + v * (segments + 1) + e;
					surf.indexVector[i++] = u + 1 + v * (segments + 1) + e;
					surf.indexVector[i++] = u + (v + 1) * (segments + 1) + e;
					u++;
				}
				v++;
			}
			
		}
		
		public function get segments() : int {
			return this._segments;
		}
		
		public function get depth() : Number {
			return this._depth;
		}
		
		public function get height() : Number {
			return this._height;
		}
		
		public function get width() : Number {
			return this._width;
		}
				
	}
}
