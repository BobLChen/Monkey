package monkey.navmesh {

	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	/**
	 * 路径点 
	 * @author Neil
	 * 
	 */	
	public class WayPoint {

		public var point : Point;
		public var cell  : NavigationCell;
		public var pos	 : Vector3D;

		public function WayPoint(cell : NavigationCell, point : Point, pos : Vector3D) {
			this.point = point;
			this.cell  = cell;
			this.pos   = pos;
		}
	}
}
