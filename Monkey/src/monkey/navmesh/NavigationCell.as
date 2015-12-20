package monkey.navmesh {

	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import monkey.core.utils.Vector3DUtils;

	/**
	 * navigation中网格的一个单元网格。类似2d的格子、六边形、圆形等单元。
	 * navigation的单元必须为三角形。且该三角形拥有面积（某些三角形呈线条）
	 * navigation的单元必须为顺时针方式存储。
	 *
	 * @author neil
	 *
	 */
	public class NavigationCell {

		/** 顶点a */
		public static const VERT_A : int = 0;
		/** 顶点b */
		public static const VERT_B : int = 1;
		/** 顶点c */
		public static const VERT_C : int = 2;

		/** ab边，A->B */
		public static const SIDE_AB : int = 0;
		/** bc边，B->C */
		public static const SIDE_BC : int = 1;
		/** ca边，C->A */
		public static const SIDE_CA : int = 2;
		
		private static const temp2 : Point = new Point();
		
		/** 父单元 */
		public  var parent			: NavigationCell;
		private var _vertives 		: Vector.<Vector3D>; 			// 顶点
		private var _id 			: int; 							// id
		private var _open 			: int; 							// 是否处于open表中
		private var _link 			: Vector.<NavigationCell>; 		// 单元邻接平面		
		private var _center 		: Vector3D; 					// 三角形中心点
		private var _arrivalCost	: Number; 						// 达到该单元格的花费。
		private var _heuristic 		: Number; 						// 启发式消耗
		private var _arrivalWall	: int;							// 穿入边
		private var _wallMidPoint 	: Vector.<Vector3D>; 			// 三边中心点
		private var _wallDistance 	: Vector.<Number>; 				// 中心点之间的距离
		
		public function NavigationCell(v0 : Vector3D, v1 : Vector3D, v2 : Vector3D) {
			this._vertives = new Vector.<Vector3D>();
			this._link = new Vector.<NavigationCell>();
			this._wallMidPoint = new Vector.<Vector3D>();
			this._wallDistance = new Vector.<Number>();
			this._open = -1;
			this._link[SIDE_AB] = null;
			this._link[SIDE_BC] = null;
			this._link[SIDE_CA] = null;
			this._vertives[VERT_A] = new Vector3D(v0.x, v0.y, v0.z);
			this._vertives[VERT_B] = new Vector3D(v1.x, v1.y, v1.z);
			this._vertives[VERT_C] = new Vector3D(v2.x, v2.y, v2.z);
			this.initCellData();
		}

		public function get arrivalWall():int {
			return _arrivalWall;
		}
		
		/**
		 * 穿入边 
		 * @param value
		 * 
		 */		
		public function set arrivalWall(value:int):void {
			_arrivalWall = value;
		}
		
		/**
		 * 启发式消耗 
		 * @return 
		 * 
		 */		
		public function get heuristic() : Number {
			return _heuristic;
		}

		public function set heuristic(value : Number) : void {
			_heuristic = value;
		}
		
		/**
		 * 路径消耗 
		 * @return 
		 * 
		 */		
		public function get arrivalCost() : Number {
			return _arrivalCost;
		}

		public function set arrivalCost(value : Number) : void {
			_arrivalCost = value;
		}
		
		/**
		 * 路径距离 
		 * @return 
		 * 
		 */		
		public function get wallDistance() : Vector.<Number> {
			return _wallDistance;
		}

		public function get wallMidPoint() : Vector.<Vector3D> {
			return _wallMidPoint;
		}
		
		/**
		 * 中心 
		 * @return 
		 * 
		 */		
		public function get center() : Vector3D {
			return _center;
		}
		
		/**
		 * 邻接三角形 
		 * @return 
		 * 
		 */		
		public function get link() : Vector.<NavigationCell> {
			return _link;
		}
		
		/**
		 * 是否处于open表 
		 * @return 
		 * 
		 */		
		public function get open() : int {
			return _open;
		}
		
		/**
		 * -1:既不处于开启列表，也不处于关闭列表
		 *  1:处于开启列表
		 * 	0:处于关闭列表 
		 * @param value
		 * 
		 */		
		public function set open(value : int) : void {
			_open = value;
		}
		
		public function get id() : int {
			return _id;
		}
		
		/**
		 * id 
		 * @param value
		 * 
		 */		
		public function set id(value : int) : void {
			_id = value;
		}
		
		/**
		 * 顶点 
		 * @return 
		 * 
		 */		
		public function get vertives() : Vector.<Vector3D> {
			return _vertives;
		}
		
		private function initCellData() : void {

			var p1 : Point = new Point(_vertives[VERT_A].x, _vertives[VERT_A].z);
			var p2 : Point = new Point(_vertives[VERT_B].x, _vertives[VERT_B].z);
			var p3 : Point = new Point(_vertives[VERT_C].x, _vertives[VERT_C].z);
			// 计算中心点
			this._center = new Vector3D();
			this._center.x = (_vertives[VERT_A].x + _vertives[VERT_B].x + _vertives[VERT_C].x) / 3;
			this._center.y = (_vertives[VERT_A].y + _vertives[VERT_B].y + _vertives[VERT_C].y) / 3;
			this._center.z = (_vertives[VERT_A].z + _vertives[VERT_B].z + _vertives[VERT_C].z) / 3;
			// 计算三边中心点
			this._wallMidPoint[SIDE_AB] = new Vector3D();
			this._wallMidPoint[SIDE_AB].x = (_vertives[VERT_A].x + _vertives[VERT_B].x) / 2;
			this._wallMidPoint[SIDE_AB].y = (_vertives[VERT_A].y + _vertives[VERT_B].y) / 2;
			this._wallMidPoint[SIDE_AB].z = (_vertives[VERT_A].z + _vertives[VERT_B].z) / 2;
			// bc边
			this._wallMidPoint[SIDE_BC] = new Vector3D();
			this._wallMidPoint[SIDE_BC].x = (_vertives[VERT_B].x + _vertives[VERT_C].x) / 2;
			this._wallMidPoint[SIDE_BC].y = (_vertives[VERT_B].y + _vertives[VERT_C].y) / 2;
			this._wallMidPoint[SIDE_BC].z = (_vertives[VERT_B].z + _vertives[VERT_C].z) / 2;
			// va边
			this._wallMidPoint[SIDE_CA] = new Vector3D();
			this._wallMidPoint[SIDE_CA].x = (_vertives[VERT_C].x + _vertives[VERT_A].x) / 2;
			this._wallMidPoint[SIDE_CA].y = (_vertives[VERT_C].y + _vertives[VERT_A].y) / 2;
			this._wallMidPoint[SIDE_CA].z = (_vertives[VERT_C].z + _vertives[VERT_A].z) / 2;
			// 计算三边中心点之间的距离
			this._wallDistance[0] = Vector3DUtils.length(_wallMidPoint[SIDE_AB], _wallMidPoint[SIDE_BC]);
			this._wallDistance[1] = Vector3DUtils.length(_wallMidPoint[SIDE_BC], _wallMidPoint[SIDE_CA]);
			this._wallDistance[2] = Vector3DUtils.length(_wallMidPoint[SIDE_CA], _wallMidPoint[SIDE_AB]);
		}

		/**
		 * 赋值
		 * @param src
		 *
		 */
		public function copyFrom(src : NavigationCell) : void {
			if (this != src) {
				this._center	= src._center;
				this._id 	= src.id;
				this._open 	= src.open;
				this._heuristic = src.heuristic;
				this._arrivalCost = src.arrivalCost;
				for (var i : int = 0; i < 3; i++) {
					this._link[i] = src.link[i];
					this._vertives[i] = src.vertives[i];
					this._wallMidPoint[i] = src.wallMidPoint[i];
					this._wallDistance[i] = src.wallDistance[i];
				}
			}
		}

		/**
		 * 查询该单元格是否与三角形有公共边，即该单元格与三角形邻接。
		 * 若存在，则该单元格记录三角形信息。
		 *
		 * @param v0				顶点0
		 * @param v1				顶点1
		 * @param adjacent		单元格
		 * @return
		 *
		 */
		public function requestLink(pa : Vector3D, pb : Vector3D, adjacent : NavigationCell) : Boolean {
			
			var va : Vector3D = _vertives[VERT_A];
			var vb : Vector3D = _vertives[VERT_B];
			var vc : Vector3D = _vertives[VERT_C];
			
			if (va.equals(pa) && vb.equals(pb)) {
				_link[SIDE_AB] = adjacent;
				return true;
			} else if (va.equals(pb) && vb.equals(pa)) {
				_link[SIDE_AB] = adjacent;
				return true;
			} else if (vb.equals(pa) && vc.equals(pb)) {
				_link[SIDE_BC] = adjacent;
				return true;
			} else if (vb.equals(pb) && vc.equals(pa)) {
				_link[SIDE_BC] = adjacent;
				return true;
			} else if (va.equals(pa) && vc.equals(pb)) {
				_link[SIDE_CA] = adjacent;
				return true;
			} else if (va.equals(pb) && vc.equals(pa)) {
				_link[SIDE_CA] = adjacent;
				return true;
			}
			
			// 无邻接边
			return false;
		}
		
		/**
		 * 设置邻接单元格
		 * @param SIDE_AB
		 * @param cellB
		 *
		 */
		public function setLink(side : int, cellB : NavigationCell) : void {
			this._link[side] = cellB;
		}
		
		/**
		 * 获取与cell公边 
		 * @param cell
		 * @return 
		 * 
		 */		
		public function getSide(cell : NavigationCell) : int {
			if (_link[SIDE_AB] == cell) {
				return SIDE_AB;
			} else if (_link[SIDE_BC] == cell) {
				return SIDE_BC;
			} else if (_link[SIDE_CA] == cell) {
				return SIDE_CA;
			}
			return -1;
		}
		
		/**
		 * 判断单元格是否与三角形相等 
		 * @param v0
		 * @param v1
		 * @param v2
		 * @return 
		 * 
		 */		
		public function equal(v0 : Vector3D, v1 : Vector3D, v2 : Vector3D) : Boolean {
			if (_vertives[0].equals(v0) && _vertives[1].equals(v1) && _vertives[2].equals(v2)) {
				return true;
			}
			return false;
		}
		
		/**
		 * 获取路径花费 
		 * @return 
		 * 
		 */		
		public function get pathCost() : Number {
			return _arrivalCost + _heuristic;
		}
		
	}
}
