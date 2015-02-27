package monkey.navmesh {

	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Vector3DUtils;
	
	/**
	 * navigation mesh数据
	 * @author neil
	 *
	 */
	public class NavigationMesh extends Object3D {

		public static const EPSILON : Number = 0; //精度
		
		private var _cells 	: Vector.<NavigationCell>;
		private var _heap 	: BinaryHeap;
		private var _mesh	: Mesh3D;
				
		public function NavigationMesh() {
			this.name   = "NavigationMesh";
		}
		
		public function build(mesh : Mesh3D) : void {
			
			this._cells = new Vector.<NavigationCell>();
			this._heap  = new BinaryHeap(compare);
			this._mesh  = mesh;
			this.addComponent(new MeshRenderer(this._mesh, new ColorMaterial(0xFFCB00)));
			
			var geo : Surface3D = mesh.surfaces[0];
			var vertexVector	: Vector.<Number> = geo.getVertexVector(Surface3D.POSITION);
			var indexVector 	: Vector.<uint>   = geo.indexVector;
			var indexLen 		: int = indexVector.length;
			var v0 : Vector3D = new Vector3D();
			var v1 : Vector3D = new Vector3D();
			var v2 : Vector3D = new Vector3D();
			var i  : int = 0;
			while (i < indexLen) {
				var px : int = indexVector[i++] * 3;
				var py : int = indexVector[i++] * 3;
				var pz : int = indexVector[i++] * 3;
				v0.setTo(vertexVector[px], vertexVector[(px + 1)], vertexVector[(px + 2)]);
				v1.setTo(vertexVector[py], vertexVector[(py + 1)], vertexVector[(py + 2)]);
				v2.setTo(vertexVector[pz], vertexVector[(pz + 1)], vertexVector[(pz + 2)]);
				this.addCell(v0, v1, v2);
			}
			this.linkCells();
		}
		
		/**
		 * 二叉堆比较函数 
		 * @param a
		 * @param b
		 * @return 
		 * 
		 */		
		private function compare(a : NavigationCell, b : NavigationCell) : Number {
			return a.pathCost - b.pathCost;
		}

		/** 所有单元格 */
		public function get cells() : Vector.<NavigationCell> {
			return _cells;
		}
		
		public function set cells(value : Vector.<NavigationCell>) : void {
			_cells = value;	
		}
		
		/**
		 * 添加一个单元格, 当单元格添加完成之后，需要手动调用linkCells()建立单元格之间的关系
		 * @param pa
		 * @param pb
		 * @param pc
		 *
		 */
		public function addCell(pa : Vector3D, pb : Vector3D, pc : Vector3D) : void {
			var cell : NavigationCell = new NavigationCell(pa, pb, pc);
			_cells.push(cell);
		}

		/**
		 * 当单元格添加完成之后，需要调用该方法
		 *  维护单元格之间的关系
		 */
		public function linkCells() : void {
			for each (var cellA : NavigationCell in _cells) {
				// 判断单元格a与d单元格b之间的关系
				for each (var cellB : NavigationCell in _cells) {
					if (cellA != cellB) {
						// 如果单元格A的AB边没有邻接单元格，并且单元格A的AB边与单元格B相连
						if (cellA.link[0] == null && cellB.requestLink(cellA.vertives[0], cellA.vertives[1], cellA)) {
							cellA.setLink(NavigationCell.SIDE_AB, cellB);
						} else if (cellA.link[1] == null && cellB.requestLink(cellA.vertives[1], cellA.vertives[2], cellA)) {
							cellA.setLink(NavigationCell.SIDE_BC, cellB);
						} else if (cellA.link[2] == null && cellB.requestLink(cellA.vertives[2], cellA.vertives[0], cellA)) {
							cellA.setLink(NavigationCell.SIDE_CA, cellB);
						}
					}
				}
			}
		}

		/**
		 * 通过顶点搜寻cell
		 * @param v0
		 * @param v1
		 * @param v2
		 * @return
		 *
		 */
		public function findCell(v0 : Vector3D, v1 : Vector3D, v2 : Vector3D) : NavigationCell {
			for each (var cell : NavigationCell in _cells) {
				if (cell.equal(v0, v1, v2)) {
					return cell;
				}
			}
			return null;
		}
		
		/**
		 * 启发式函数 
		 * @param cell
		 * @param goal
		 * @return 
		 * 
		 */		
		private function computeHeuristic(cell : NavigationCell, goal : Vector3D) : Number {
			return Vector3DUtils.length(cell.center, goal);
		}

		/**
		 * 搜寻路径
		 * @param startPos		起始点
		 * @param startCell		起始单元格
		 * @param endPos			结束点
		 * @param endCell		结束单元格
		 * @return path
		 */
		public function findPath(startPos : Vector3D, startCell : NavigationCell, endPos : Vector3D, endCell : NavigationCell) : Array {

			var path : Array = [];

			for each (var cell : NavigationCell in _cells) {
				cell.open = -1;
				cell.parent = null;
			}
			// 从endCell开始搜寻
			// 将endCell加入到open表
			endCell.arrivalCost = 0;
			endCell.heuristic = 0;
			endCell.open = 1;
			endCell.arrivalWall = 0;
			// endCell加入到open表
			_heap.clear();
			_heap.push(endCell);
			var pathFount : Boolean = false;

			while (_heap.isNotEmpty() && !pathFount) {
				// 获取花费最低的单元格
				var curCell : NavigationCell = _heap.pop() as NavigationCell;
				curCell.open = 0; // 加入到关闭列表

				if (curCell == startCell) {
					pathFount = true;
					break;
				}

				// 检测所有相邻的单元格
				for (var i : int = 0; i < 3; i++) {
					var adj : NavigationCell = curCell.link[i];

					// 如果邻接单元格存在
					if (adj != null) {
						// 忽略在关闭列表或者不可通过的单元格
						if (adj.open == 0) {
							continue;
						} else if (adj.open == -1) { // 不处于开启列表，加入到开启列表
							adj.open = 1;
							adj.parent = curCell;
							adj.heuristic = computeHeuristic(adj, startPos); // 启发式花费
							adj.arrivalCost = curCell.arrivalCost + curCell.wallDistance[Math.abs(i - curCell.arrivalWall)]; // 到达的路径花费,即从curCell到达该单元的花费
							adj.arrivalWall = adj.getSide(curCell); // 设置adj的穿入边
							_heap.push(adj);
						} else if (adj.open == 1) { // 处于开启列表
							// 检测当前单元格到邻接单元格的花费是否更小
							if (curCell.arrivalCost + curCell.wallDistance[Math.abs(i - curCell.arrivalWall)] < adj.arrivalCost) {
								// 没影响
								// adj.arrivalCost = curCell.arrivalCost + curCell.wallDistance[Math.abs(i - curCell.arrivalWall)];
								adj.arrivalCost = curCell.arrivalCost;
								adj.parent = curCell;
								adj.arrivalWall = adj.getSide(curCell);
								// _heap.update(adj); // 不用更新二叉堆
							}
						}
					}

				}
			}

			if (!pathFount) {
				return path;
			}

			path.push(startCell);

			while (startCell.parent != null) {
				path.push(startCell.parent);
				startCell = startCell.parent;
			}

			return path;
		}

		/**
		 * 使用拐点法求取路径点
		 * @param path			路径
		 * @param startPos		起点
		 * @param stopPos		终点
		 * @return
		 *
		 */
		public function findWayPoint(path : Array, startPos : Vector3D, stopPos : Vector3D) : Array {

			var wayPoints : Array = [];

			if (path.length == 0) {
				return wayPoints;
			}

			var end : Point = new Point(stopPos.x, stopPos.z);
			var start : Point = new Point(startPos.x, startPos.z);
			
			wayPoints.push(startPos);
			
			if (path.length == 1) {
				wayPoints.push(stopPos);
				return wayPoints;
			}
			
			var wayP : WayPoint = new WayPoint(path[0], start);
			while (!wayP.point.equals(end)) {
				wayP = this.getFurthestWayPoint(wayP, path, end);
				var point : Vector3D = new Vector3D(wayP.point.x, wayP.cell.plane.getY(wayP.point.x, wayP.point.y), wayP.point.y);
				wayPoints.push(point);
			}
			
			return wayPoints;
		}
		
		/**
		 * 获取一个拐点 
		 * @param wayPoint
		 * @param cellPath
		 * @param end
		 * @return 
		 * 
		 */		
		private function getFurthestWayPoint(wayPoint : WayPoint, cellPath : Array, end : Point) : WayPoint {
			
			//当前所在路径点
			var startPt : Point = wayPoint.point; 
			var cell : NavigationCell = wayPoint.cell;
			var lastCell : NavigationCell = cell;
			//开始路点所在的网格索引
			var startIndex : int = cellPath.indexOf(cell); 
			//路径线在网格中的穿出边
			var outSide : Line2D = cell.side[cell.arrivalWall]; 
			var lastPtA : Point = outSide.pa;
			var lastPtB : Point = outSide.pb;
			var lastLineA : Line2D = new Line2D(startPt, lastPtA);
			var lastLineB : Line2D = new Line2D(startPt, lastPtB);
			var testPtA : Point, testPtB : Point; //要测试的点

			for (var i : int = startIndex + 1; i < cellPath.length; i++) {
				cell = cellPath[i];
				outSide = cell.side[cell.arrivalWall];

				if (i == cellPath.length - 1) {
					testPtA = end;
					testPtB = end;
				} else {
					testPtA = outSide.pa;
					testPtB = outSide.pb;
				}

				if (!lastPtA.equals(testPtA)) {
					if (lastLineB.classifyPoint(testPtA, EPSILON) == Line2D.RIGHT_SIDE) {
						//路点
						return new WayPoint(lastCell, lastPtB);
					} else {
						if (lastLineA.classifyPoint(testPtA, EPSILON) != Line2D.LEFT_SIDE) {
							lastPtA = testPtA;
							lastCell = cell;
							lastLineA.pb = lastPtA;
						}
					}
				}
				
				if (!lastPtB.equals(testPtB)) {
					if (lastLineA.classifyPoint(testPtB, EPSILON) == Line2D.LEFT_SIDE) {
						return new WayPoint(lastCell, lastPtA);
					} else {
						if (lastLineB.classifyPoint(testPtB, EPSILON) != Line2D.RIGHT_SIDE) {
							lastPtB = testPtB;
							lastCell = cell;
							lastLineB.pb = lastPtB;
						}
					}
				}
			}
			
			return new WayPoint(cellPath[cellPath.length - 1], end);
		}

	}
}
