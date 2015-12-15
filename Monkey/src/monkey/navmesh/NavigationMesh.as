package monkey.navmesh {
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Color;
	import monkey.core.utils.Vector3DUtils;
	
	/**
	 * navigation mesh数据
	 * @author neil
	 *
	 */
	public class NavigationMesh extends Object3D {
		
		public static const EPSILON : Number = 0; //精度
		/** 最多尝试搜寻次数 */
		public static const MAX_TRY : int = 100;
		
		private var _cells 	: Vector.<NavigationCell>;
		private var _heap 	: BinaryHeap;
		private var _mesh	: Mesh3D;
		
		public function NavigationMesh() {
			this.name  = "NavigationMesh";
			this._heap = new BinaryHeap(compare);
		}
		
		public function build(mesh : Mesh3D) : void {
			this._cells = new Vector.<NavigationCell>();
			this._mesh  = mesh;
			var surface  : Surface3D = mesh.surfaces[0];
			var vertices : Vector.<Number> = surface.getVertexVector(Surface3D.POSITION);
			var indices  : Vector.<uint>   = surface.indexVector;
			var indexLen : int = indices.length;
			var v0 : Vector3D = new Vector3D();
			var v1 : Vector3D = new Vector3D();
			var v2 : Vector3D = new Vector3D();
			var i  : int = 0;
			while (i < indexLen) {
				var px : int = indices[i++] * 3;
				var py : int = indices[i++] * 3;
				var pz : int = indices[i++] * 3;
				v0.setTo(vertices[px], vertices[(px + 1)], vertices[(px + 2)]);
				v1.setTo(vertices[py], vertices[(py + 1)], vertices[(py + 2)]);
				v2.setTo(vertices[pz], vertices[(pz + 1)], vertices[(pz + 2)]);
				this.addCell(v2, v1, v0);
			}
			this.linkCells();
			this.addComponent(new MeshRenderer(this._mesh, new ColorMaterial(new Color(0xFFCB00))));
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
					if (adj == null) {
						continue;
					}
					// 如果邻接单元格存在 忽略在关闭列表或者不可通过的单元格
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
							adj.arrivalCost = curCell.arrivalCost;
							adj.parent = curCell;
							adj.arrivalWall = adj.getSide(curCell);
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
		public function findWayPoint(path : Array, satpos : Vector3D, endpos : Vector3D) : Array {
			var wayPoints : Array = [];
			if (path.length == 0) {
				return wayPoints;
			}
			var end : Point = new Point(endpos.x, endpos.z);
			var sat : Point = new Point(satpos.x, satpos.z);
			wayPoints.push(satpos);
			// 路径长度为1
			if (path.length == 1) {
				wayPoints.push(endpos);
				return wayPoints;
			}
			// 开始搜寻拐点
			var cel : NavigationCell = path[0];
			var sid : Line2D = cel.side[cel.arrivalWall];
			var sp2 : Point  = new Point(satpos.x, satpos.z);	
			var ll	: Line2D = new Line2D(sp2, sid.pa);
			var lr	: Line2D = new Line2D(sp2, sid.pb);
			var va	: Vector3D = cel.vertives[cel.arrivalWall];
			var vb  : Vector3D = cel.vertives[(cel.arrivalWall + 1) % 3];
			var ta  : Vector3D = null;
			var tb  : Vector3D = null;
			var mid	: Vector3D = new Vector3D();
			var pl  : Point  = null;
			var pr  : Point  = null;
			// 遍历所有的路径
			for (var i:int = 0; i < path.length; i++) {
				cel = path[i];
				sid = cel.side[cel.arrivalWall];
				pl  = sid.pa;
				pr  = sid.pb;
				ta	= cel.vertives[cel.arrivalWall];
				tb	= cel.vertives[(cel.arrivalWall + 1) % 3];
				if (i == path.length - 1) {
					pl = new Point(endpos.x, endpos.z);
					pr = new Point(endpos.x, endpos.z);
					ta = endpos;
					tb = endpos;
				}
				// 是否共点，左直线和右直线都与穿出边共点
				if (ll.pb.equals(pl) && lr.pb.equals(pr)) {
					continue;
				}
				// 左点在左直线左侧
				if (ll.classifyPoint(pl) != Line2D.RIGHT_SIDE) {
					// 如果右点在左直线上面或者在左直线左侧，则视为一个拐点。
					if (ll.classifyPoint(pr) != Line2D.RIGHT_SIDE) {
						if (!wayPoints[wayPoints.length - 1].equals(va)) {
							wayPoints.push(va);
						}
						va  = ta;
						vb  = tb;
						Vector3DUtils.interpolate(ta, tb, 0.5, mid);
						sp2 = new Point(mid.x, mid.z);
						ll  = new Line2D(sp2, pl);
						lr  = new Line2D(sp2, pr);
						continue;
					}
				} else {
					// 检测左点是否在右直线上或者右侧
					if (lr.classifyPoint(pl) != Line2D.LEFT_SIDE) {
						if (!wayPoints[wayPoints.length - 1].equals(vb)) {
							wayPoints.push(vb);
						}
						va  = ta;
						vb  = tb;
						Vector3DUtils.interpolate(ta, tb, 0.5, mid);
						sp2 = new Point(mid.x, mid.z);
						ll  = new Line2D(sp2, pl);
						lr  = new Line2D(sp2, pr);
						continue;
					} else {
						ll.pb = pl;				
						va = ta;
					}
				}
				// 右点在右直线右侧，或者点在直线上面
				if (lr.classifyPoint(pr) != Line2D.LEFT_SIDE) {
					// 如果左点在右直线上面或者右侧，则视为一个拐点。
					if (lr.classifyPoint(pl) != Line2D.LEFT_SIDE) {
						if (!wayPoints[wayPoints.length - 1].equals(vb)) {
							wayPoints.push(vb);
						}
						va  = ta;
						vb  = tb;
						Vector3DUtils.interpolate(ta, tb, 0.5, mid);
						sp2 = new Point(mid.x, mid.z);
						ll  = new Line2D(sp2, pl);
						lr  = new Line2D(sp2, pr);
						continue;
					}
				} else {
					// 检测右点是否在左直线上或者左侧
					if (ll.classifyPoint(pr) != Line2D.RIGHT_SIDE) {
						if (!wayPoints[wayPoints.length - 1].equals(va)) {
							wayPoints.push(va);
						}
						va  = ta;
						vb  = tb;
						Vector3DUtils.interpolate(ta, tb, 0.5, mid);
						sp2 = new Point(mid.x, mid.z);
						ll  = new Line2D(sp2, pl);
						lr  = new Line2D(sp2, pr);
						continue;
					} else {
						lr.pb = pr;
						vb = tb;
					}
				}
			}
			if (!wayPoints[wayPoints.length - 1].equals(endpos)) {
				wayPoints.push(endpos);
			}
			return wayPoints;
		}
		
	}
}

