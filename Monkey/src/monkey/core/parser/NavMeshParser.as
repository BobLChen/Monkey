package monkey.core.parser {

	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.navmesh.NavigationCell;
	import monkey.navmesh.NavigationMesh;

	public class NavMeshParser extends EventDispatcher {
		
		public function NavMeshParser() {
			
		}
		
		public function parse(bytes : ByteArray) : NavigationMesh {
			var navmesh : NavigationMesh = new NavigationMesh();
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.uncompress();
			
			var len   : int = bytes.readInt();
			var cells : Vector.<NavigationCell> = new Vector.<NavigationCell>();
			for (var i:int = 0; i < len; i++) {
				var v0 : Vector3D = new Vector3D();
				var v1 : Vector3D = new Vector3D();
				var v2 : Vector3D = new Vector3D();
				// 顶点0
				v0.x = bytes.readFloat();
				v0.y = bytes.readFloat();
				v0.z = bytes.readFloat();
				// 顶点1
				v1.x = bytes.readFloat();
				v1.y = bytes.readFloat();
				v1.z = bytes.readFloat();
				// 顶点2
				v2.x = bytes.readFloat();
				v2.y = bytes.readFloat();
				v2.z = bytes.readFloat();
				var cell : NavigationCell = new NavigationCell(v0, v1, v2);
				cells.push(cell);
			}
			
			for (i = 0; i < len; i++) {
				var oriCell : NavigationCell = cells[i];
				for (var j:int = 0; j < 3; j++) {
					var adjIdx : int = bytes.readInt();
					if (adjIdx == -1) {
						oriCell.link[j] = null;
					} else {
						oriCell.link[j] = cells[adjIdx];
					}
				}
			}
			navmesh.cells = cells;
			return navmesh;
		}
		
	}
}
