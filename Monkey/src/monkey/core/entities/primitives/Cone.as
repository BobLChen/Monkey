package monkey.core.entities.primitives {
	
	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;

	public class Cone extends Mesh3D {
		
		private var _radius1	: Number;
		private var _radius2	: Number;
		private var _height 	: Number;
		private var _segments 	: int;
		
		public function Cone(radius1 : Number = 5, radius2 : Number = 0, height : Number = 10, segments : int = 12) {
			super([]);
			
			this._segments 	= segments;
			this._height 	= height;
			this._radius2 	= radius2;
			this._radius1 	= radius1;
			
			this.surfaces[0] = new Surface3D();
			this.surfaces[0].setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
			this.surfaces[0].setVertexVector(Surface3D.NORMAL, new Vector.<Number>(), 3);
			this.surfaces[0].setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
			this.surfaces[0].indexVector = new Vector.<uint>();
			
			var surf 	: Surface3D = surfaces[0];
			var vertexs : Vector.<Number> = this.surfaces[0].getVertexVector(Surface3D.POSITION);
			var normals : Vector.<Number> = this.surfaces[0].getVertexVector(Surface3D.NORMAL);
			var uvs 	: Vector.<Number> = this.surfaces[0].getVertexVector(Surface3D.UV0);
			
			var normal : Vector3D = new Vector3D();
			var sy  : int = segments;
			var i 	: int = 0;
			var d 	: int = 0;
			var v 	: Number = 0;
			var x 	: Number = 0;
			var y 	: Number = 0;
			var z 	: Number = 0;
			var r1  : int = 0;
			var r2  : int = 0;
			var max : Number = 0;
			
			while (v <= sy) {
				y = 0;
				x = Math.cos((((v / sy) * Math.PI) * 2));
				z = -(Math.sin((((v / sy) * Math.PI) * 2)));
				normal.x = x;
				normal.y = ((radius1 - radius2) / height);
				normal.z = z;
				normal.normalize();
				vertexs.push(x * radius1, 0, z * radius1, x * radius2, height, z * radius2);
				normals.push(normal.x, normal.y, normal.z, normal.x, normal.y, normal.z);
				uvs.push(v / segments, 1, v / segments, 0);
				i++;
				v++;
			}
			if (radius1 > 0) {
				r1 = vertexs.length / 3;
				v = 0;
				while (v <= sy) {
					x = (Math.cos((((v / sy) * Math.PI) * 2)) * radius1);
					z = (-(Math.sin((((v / sy) * Math.PI) * 2))) * radius1);
					vertexs.push(x, 0, z);
					normals.push(0, -1, 0);
					uvs.push(x / _radius1 * 0.5, z / _radius1 * 0.5);
					v++;
				}
			}
			if (radius2 > 0) {
				r2 = vertexs.length / 3;
				v = 0;
				while (v <= sy) {
					x = (Math.cos((((v / sy) * Math.PI) * 2)) * radius2);
					z = (-(Math.sin((((v / sy) * Math.PI) * 2))) * radius2);
					vertexs.push(x, height, z);
					normals.push(0, 1, 0);
					uvs.push(x / _radius2 * 0.5);
					uvs.push(z / _radius2 * 0.5);
					v++;
				}
			}
			i = 0;
			v = 0;
			while (v < sy) {
				surf.indexVector[i++] = ((v * 2) + 2);
				surf.indexVector[i++] = ((v * 2) + 1);
				surf.indexVector[i++] = (v * 2);
				surf.indexVector[i++] = ((v * 2) + 2);
				surf.indexVector[i++] = ((v * 2) + 3);
				surf.indexVector[i++] = ((v * 2) + 1);
				v++;
			}
			if (radius1 > 0) {
				v = 1;
				while (v < (sy - 1)) {
					surf.indexVector[i++] = ((r1 + v) + 1);
					surf.indexVector[i++] = (r1 + v);
					surf.indexVector[i++] = r1;
					v++;
				}
			}
			if (radius2 > 0) {
				v = 1;
				while (v < (sy - 1)) {
					surf.indexVector[i++] = r2;
					surf.indexVector[i++] = (r2 + v);
					surf.indexVector[i++] = ((r2 + v) + 1);
					v++;
				}
			}
			
			max = Math.max(radius1, radius2);
			this.bounds = new Bounds3D();
			this.bounds.center.y = (height * 0.5);
			this.bounds.max.setTo(max, height, max);
			this.bounds.min.setTo(-(max), 0, -(max));
			this.bounds.length.x = this.bounds.max.x - this.bounds.min.x;
			this.bounds.length.y = this.bounds.max.y - this.bounds.min.y;
			this.bounds.length.z = this.bounds.max.z - this.bounds.min.z;
			this.bounds.center.x = this.bounds.length.x * 0.5 + this.bounds.min.x;
			this.bounds.center.y = this.bounds.length.y * 0.5 + this.bounds.min.y;
			this.bounds.center.z = this.bounds.length.z * 0.5 + this.bounds.min.z;
			this.bounds.radius = Vector3D.distance(bounds.center, bounds.max);
			
			surf.bounds = bounds;
			
		}
		
		public function get radius1() : Number {
			return this._radius1;
		}
		
		public function get radius2() : Number {
			return this._radius2;
		}
		
		public function get height() : Number {
			return this._height;
		}
		
		public function get segments() : int {
			return this._segments;
		}
		
	}
}
