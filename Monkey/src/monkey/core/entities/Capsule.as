package monkey.core.entities {
	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;

	public class Capsule extends Mesh3D {
		
		private var _radius   : Number;
		private var _height   : Number;
		private var _segments : int;
		
		public function Capsule(radius : Number = 3, height : Number = 10, segments : int = 12) {
			super([]);
			
			this._segments 	= segments;
			this._radius 	= radius;
			this._height 	= height;
			
			this.surfaces[0]= new Surface3D();
			this.surfaces[0].setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
			this.surfaces[0].setVertexVector(Surface3D.NORMAL, new Vector.<Number>(), 3);
			this.surfaces[0].setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
			this.surfaces[0].indexVector = new Vector.<uint>();
			
			var surf   : Surface3D = surfaces[0];
			var normal : Vector3D  = new Vector3D();
			var sx 	: int 		= segments;
			var sy 	: int 		= segments + 1;
			var h 	: Number	= height - radius * 2;
			var i 	: int   	= 0;
			var u 	: Number	= 0;
			var v 	: Number	= 0;
			var x 	: Number	= 0;
			var y 	: Number	= 0;
			var z 	: Number	= 0;
			var offset : Number = 0;
			
			while (v <= sy) {
				y = -Math.cos(v / sy * Math.PI) * radius;
				offset = (v > sy / 2) ? h / 2 : -h / 2;
				u = 0;
				while (u <= sx) {
					x = (Math.cos((((u / sx) * Math.PI) * 2)) * radius) * Math.sin(((v / sy) * Math.PI));
					z = (-(Math.sin((((u / sx) * Math.PI) * 2))) * radius) * Math.sin(((v / sy) * Math.PI));
					normal.x = x;
					normal.y = y;
					normal.z = z;
					normal.normalize();
					surf.getVertexVector(Surface3D.POSITION).push(x, y + offset, z);
					surf.getVertexVector(Surface3D.NORMAL).push(normal.x, normal.y, normal.z);
					surf.getVertexVector(Surface3D.UV0).push((1 - (u / segments)), (1 - (v / segments)));
					i++;
					u++;
				}
				v++;
			}
			i = 0;
			v = 0;
			while (v < sy) {
				u = 0;
				while (u < sx) {
					surf.indexVector[i++] = u + (v * (sx + 1));
					surf.indexVector[i++] = (u + 1) + (v * (sx + 1));
					surf.indexVector[i++] = u + ((v + 1) * (sx + 1));
					surf.indexVector[i++] = (u + 1) + (v * (sx + 1));
					surf.indexVector[i++] = (u + 1) + ((v + 1) * (sx + 1));
					surf.indexVector[i++] = u + ((v + 1) * (sx + 1));
					u++;
				}
				v++;
			}
			bounds = new Bounds3D();
			var halfH : Number = (this._height * 0.5);
			this.bounds.max.setTo(radius, halfH, radius);
			this.bounds.min.setTo(-radius, -halfH, -radius);
			this.bounds.length.x = this.bounds.max.x - this.bounds.min.x;
			this.bounds.length.y = this.bounds.max.y - this.bounds.min.y;
			this.bounds.length.z = this.bounds.max.z - this.bounds.min.z;
			this.bounds.center.x = this.bounds.length.x * 0.5 + this.bounds.min.x;
			this.bounds.center.y = this.bounds.length.y * 0.5 + this.bounds.min.y;
			this.bounds.center.z = this.bounds.length.z * 0.5 + this.bounds.min.z;
			this.bounds.radius = Vector3D.distance(bounds.center, bounds.max);
			
			surf.bounds = bounds;
		}
		
		public function get segments() : int {
			return this._segments;
		}
		
		public function get height() : Number {
			return this._height;
		}
		
		public function get radius() : Number {
			return this._radius;
		}
		
	}
}
