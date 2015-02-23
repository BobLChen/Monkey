package monkey.navmesh {

	import flash.geom.Point;
	
	/**
	 * 路径点 
	 * @author Neil
	 * 
	 */	
	public class WayPoint {

		public var point : Point;
		public var cell  : NavigationCell;

		public function WayPoint(cell : NavigationCell, point : Point) {
			this.point = point;
			this.cell  = cell;
		}
	}
}
