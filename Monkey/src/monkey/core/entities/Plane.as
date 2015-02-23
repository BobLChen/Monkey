package monkey.core.entities {

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.utils.Matrix3DUtils;
	
	public class Plane extends Mesh3D {
		
		private var _axis 	: String;			// 朝向
		private var _width 	: Number;			// 宽度
		private var _height	: Number;			// 高度
		private var _segment: int;				// 段数
		
		/**
		 *  
		 * @param width			宽度
		 * @param height		高度
		 * @param segments		段数
		 * @param axis			朝向:+xy、-xy、+xz、-xz、+yz、-yz
		 * 
		 */		
		public function Plane(width : Number = 10, height : Number = 10, segments : int = 1, axis : String = "+xy") {
			super([new Surface3D()]);
			
			this._width	  = width;
			this._height  = height;
			this._axis 	  = axis;
			this._segment = segments;
			
			var vertexs : Vector.<Number> = new Vector.<Number>();
			var normals : Vector.<Number> = new Vector.<Number>();
			var uvs		: Vector.<Number> = new Vector.<Number>();
			var indices : Vector.<uint>   = new Vector.<uint>();
			
			surfaces[0].setVertexVector(Surface3D.POSITION, vertexs, 3);
			surfaces[0].setVertexVector(Surface3D.NORMAL, normals, 3);
			surfaces[0].setVertexVector(Surface3D.UV0, uvs, 2);
			surfaces[0].indexVector = indices;
			
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
			} else {
				Matrix3DUtils.setOrientation(matrix, new Vector3D(0, 0, -1));
			}
			Matrix3DUtils.setScale(matrix, width, height, 1);
			var raw      : Vector.<Number> = matrix.rawData;
			var normal   : Vector3D  = Matrix3DUtils.getDir(matrix);
						
			var i : int = 0;
			var u : Number = 0;
			var v : Number = 0;
			var x : Number = 0;
			var y : Number = 0;
			var max : Number = 0;
			var hwidth : Number = 0;
			var hheight : Number = 0;
			
			while (v <= segments) {
				u = 0;
				while (u <= segments) {
					x = (u / segments) - 0.5;
					y = (v / segments) - 0.5;
					vertexs.push(
						(x * raw[0] + y * raw[4] + raw[12]), 
						(x * raw[1] + y * raw[5] + raw[13]), 
						(x * raw[2] + y * raw[6] + raw[14])
					);
					normals.push(normal.x, normal.y, normal.z);
					uvs.push(1 - u / segments, 1 - v / segments);
					i++;
					u++;
				}
				v++;
			}
			i = 0;
			v = 0;
			while (v < segments) {
				u = 0;
				while (u < segments) {
					indices[i++] = u + 1 + v * (segments + 1);
					indices[i++] = u + 1 + (v + 1) * (segments + 1);
					indices[i++] = u + (v + 1) * (segments + 1);
					indices[i++] = u + v * (segments + 1);
					indices[i++] = u + 1 + v * (segments + 1);
					indices[i++] = u + (v + 1) * (segments + 1);
					u++;
				}
				v++;
			}
			
			for each (var surf : Surface3D in surfaces) {
				surf.updateBoundings();
			}
						
			max     = Math.max(width, height) * 0.5;
			hwidth  = width * 0.5;
			hheight = height * 0.5;
			bounds  = new Bounds3D();
			bounds.max.setTo(hwidth, hheight, 0);
			if (this._axis.indexOf("xy") != -1) {
				bounds.min.setTo(-hwidth, -hheight, 0);
			} else if (this._axis.indexOf("xz") != -1) {
				bounds.max.setTo(hwidth, 0, hheight);
				bounds.min.setTo(-hwidth, 0, -hheight);
			} else if (this._axis.indexOf("yz") != -1) {
				bounds.max.setTo(0, hwidth, hheight);
				bounds.min.setTo(0, -hwidth, -hheight);
			}
			this.bounds.length.x = this.bounds.max.x - this.bounds.min.x;
			this.bounds.length.y = this.bounds.max.y - this.bounds.min.y;
			this.bounds.length.z = this.bounds.max.z - this.bounds.min.z;
			this.bounds.center.x = this.bounds.length.x * 0.5 + this.bounds.min.x;
			this.bounds.center.y = this.bounds.length.y * 0.5 + this.bounds.min.y;
			this.bounds.center.z = this.bounds.length.z * 0.5 + this.bounds.min.z;
			this.bounds.radius = Vector3D.distance(bounds.center, bounds.max);			
		}
		
		public function get segment():int {
			return _segment;
		}

		public function get height():Number {
			return _height;
		}

		public function get width():Number {
			return _width;
		}

		public function get axis():String {
			return _axis;
		}

	}
}
