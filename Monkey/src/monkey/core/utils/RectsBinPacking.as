package monkey.core.utils {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;


	/**
	 * 使用二叉树进行排列。算法参考:
	 * @see 				http://www.blackpawn.com/texts/lightmaps/default.html
	 * 用法：
	 * packer = new RectsBinPacking(1024, 1024);
	 * packer.addEventListener("complete", completeHandler);
	 * for(var i:uint = 0; i < 100; i++) {
	 * 		rects.push(new Rectangle(
	 *				0,
	 *				0,
	 *				Math.round(10 + Math.random() * 90),
	 *				Math.round(10 + Math.random() * 90)
	 *			));
	 *		}
	 *
	 * packer.insertBulk(rects, RectsBinPacking.RECT_BEST_LONG_SIDE_FIT);
	 *
	 * @author neil
	 *
	 */
	public class RectsBinPacking extends EventDispatcher {

		public static const RECT_BEST_SHORT_SIDE_FIT : uint = 1;
		public static const RECT_BOTTOM_LEFT_RULE : uint = 2;
		public static const RECT_CONTACT_POINT_RULE : uint = 3;
		public static const RECT_BEST_LONG_SIDE_FIT : uint = 4;
		public static const RECT_BEST_AREA_FIT : uint = 5;

		public var allowFlip : Boolean = false;
		public var timeLimit : Number = 5000;

		public var usedRectangles : Vector.<Rectangle>;
		public var freeRectangles : Vector.<Rectangle>;

		private var resultRectangles : Vector.<Rectangle>;

		private var binWidth : Number = 0;
		private var binHeight : Number = 0;

		private var tmpRects : Vector.<Rectangle>;
		private var type : uint;

		/**
		 * 最大封闭矩形的宽高
		 * @param width
		 * @param height
		 *
		 */
		public function RectsBinPacking(width : Number, height : Number) {
			init(width, height);
		}

		/**
		 * 初始化
		 * @param width
		 * @param height
		 *
		 */
		private function init(width : Number, height : Number) : void {
			binWidth = width;
			binHeight = height;

			resultRectangles = new Vector.<Rectangle>();
			usedRectangles = new Vector.<Rectangle>();
			freeRectangles = new Vector.<Rectangle>();
			freeRectangles.push(new Rectangle(0, 0, width, height));
		}

		/**
		 * @param width
		 * @param height
		 * @param method
		 * @return
		 */
		public function insert(width : Number, height : Number, method : uint) : Rectangle {
			var newNode : Rectangle;
			switch (method) {
				case RECT_BEST_SHORT_SIDE_FIT:
					newNode = findPositionForNewNodeBestShortSideFit(width, height);
					break;
				case RECT_BOTTOM_LEFT_RULE:
					newNode = findPositionForNewNodeBottomLeft(width, height);
					break;
				case RECT_CONTACT_POINT_RULE:
					newNode = findPositionForNewNodeContactPoint(width, height);
					break;
				case RECT_BEST_LONG_SIDE_FIT:
					newNode = findPositionForNewNodeBestLongSideFit(width, height);
					break;
				case RECT_BEST_AREA_FIT:
					newNode = findPositionForNewNodeBestAreaFit(width, height);
					break;
				default:
					throw(new Error("Invalid method."));
					break;
			}
			if (newNode.height == 0) {
				return newNode;
			}
			var numRectanglesToProcess : uint = freeRectangles.length;
			for (var i : uint = 0; i < numRectanglesToProcess; ++i) {
				if (splitFreeNode(freeRectangles[i], newNode)) {
					freeRectangles.splice(i, 1);
					--numRectanglesToProcess;
					--i;
				}
			}
			pruneFreeList();
			usedRectangles.push(newNode);
			return newNode;
		}


		/**
		 * insert所有的矩行框
		 * @param rects			矩形集合
		 * @param method			排序模式
		 *
		 */
		public function insertBulk(rects : Vector.<Rectangle>, method : uint = RECT_BEST_SHORT_SIDE_FIT) : Boolean {
			tmpRects = rects;
			type = method;
			return insertBulkWorker();
		}

		/**
		 * 开始执行插入的操作,为防止flash 15超时，将任务分配到每一帧里面
		 * @param event
		 *
		 */
		private function insertBulkWorker() : Boolean {
			var t : int = getTimer();
			while (tmpRects.length > 0) {
				// 插入失败
				if (getTimer() - timeLimit > t)
					return false;

				var bestScore : Score = new Score();
				var bestRectIndex : int = -1;
				var bestNode : Rectangle = rectFactory();
				for (var i : uint = 0; i < tmpRects.length; ++i) {
					var score : Score = new Score();
					var newNode : Rectangle = scoreRect(tmpRects[i].width, tmpRects[i].height, type, score);
					if (score.score1 < bestScore.score1 || (score.score1 == bestScore.score1 && score.score2 < bestScore.score2)) {
						bestScore.score1 = score.score1;
						bestScore.score2 = score.score2;
						bestNode = newNode;
						bestRectIndex = i;
					}
				}
				if (bestRectIndex == -1) {
					break;
				}
				placeRect(bestNode);

				var resultRect : Rectangle = tmpRects[bestRectIndex];
				resultRect.x = bestNode.x;
				resultRect.y = bestNode.y;
				resultRectangles.push(resultRect);
				tmpRects.splice(bestRectIndex, 1);
			}

			for each (var rect : Rectangle in resultRectangles) {
				tmpRects.push(rect);
			}

			dispatchEvent(new Event("complete"));
			return true;
		}

		/**
		 * 对矩阵进行排序
		 * @param width
		 * @param height
		 * @param method
		 * @param score
		 * @return
		 *
		 */
		private function scoreRect(width : Number, height : Number, method : uint, score : Score) : Rectangle {
			var newNode : Rectangle = rectFactory();
			score.score1 = Number.MAX_VALUE;
			score.score2 = Number.MAX_VALUE;
			switch (method) {
				case RECT_BEST_SHORT_SIDE_FIT:
					newNode = findPositionForNewNodeBestShortSideFit(width, height, score);
					break;
				case RECT_BOTTOM_LEFT_RULE:
					newNode = findPositionForNewNodeBottomLeft(width, height, score);
					break;
				case RECT_CONTACT_POINT_RULE:
					newNode = findPositionForNewNodeContactPoint(width, height, score);
					score.score1 = -score.score1;
					break;
				case RECT_BEST_LONG_SIDE_FIT:
					newNode = findPositionForNewNodeBestLongSideFit(width, height, score);
					break;
				case RECT_BEST_AREA_FIT:
					newNode = findPositionForNewNodeBestAreaFit(width, height, score);
					break;
				default:
					throw(new Error("Invalid method."));
					break;
			}
			if (newNode.isEmpty()) {
				score.score1 = Number.MAX_VALUE;
				score.score2 = Number.MAX_VALUE;
			}
			return newNode;
		}

		/**
		 * inert into result
		 * @param node
		 *
		 */
		private function placeRect(node : Rectangle) : void {
			var numRectanglesToProcess : uint = freeRectangles.length;
			for (var i : uint = 0; i < numRectanglesToProcess; ++i) {
				if (splitFreeNode(freeRectangles[i], node)) {
					freeRectangles.splice(i, 1);
					--numRectanglesToProcess;
					--i;
				}
			}
			pruneFreeList();
			usedRectangles.push(node);
		}

		private function findPositionForNewNodeBestShortSideFit(width : Number, height : Number, score : Score = null) : Rectangle {
			if (score == null) {
				score = new Score();
			}
			score.score1 = Number.MAX_VALUE;
			var bestNode : Rectangle = rectFactory();
			for (var i : uint = 0; i < freeRectangles.length; ++i) {
				if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
					var leftoverHoriz : Number = Math.abs(freeRectangles[i].width - width);
					var leftoverVert : Number = Math.abs(freeRectangles[i].height - height);
					var shortSideFit : Number = Math.min(leftoverHoriz, leftoverVert);
					var longSideFit : Number = Math.max(leftoverHoriz, leftoverVert);
					if (shortSideFit < score.score1 || (shortSideFit == score.score1 && longSideFit < score.score2)) {
						bestNode.x = freeRectangles[i].x;
						bestNode.y = freeRectangles[i].y;
						bestNode.width = width;
						bestNode.height = height;
						score.score1 = shortSideFit;
						score.score2 = longSideFit;
					}
				}
				if (allowFlip && height != width) {
					if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
						var flippedLeftoverHoriz : Number = Math.abs(freeRectangles[i].width - height);
						var flippedLeftoverVert : Number = Math.abs(freeRectangles[i].height - width);
						var flippedShortSideFit : Number = Math.min(flippedLeftoverHoriz, flippedLeftoverVert);
						var flippedLongSideFit : Number = Math.max(flippedLeftoverHoriz, flippedLeftoverVert);
						if (flippedShortSideFit < score.score1 || (flippedShortSideFit == score.score1 && flippedLongSideFit < score.score2)) {
							bestNode.x = freeRectangles[i].x;
							bestNode.y = freeRectangles[i].y;
							bestNode.width = height;
							bestNode.height = width;
							score.score1 = flippedShortSideFit;
							score.score2 = flippedLongSideFit;
						}
					}
				}
			}
			return bestNode;
		}

		private function findPositionForNewNodeBottomLeft(width : Number, height : Number, score : Score = null) : Rectangle {
			if (score == null) {
				score = new Score();
			}
			score.score1 = Number.MAX_VALUE;
			var topSideY : Number;
			var bestNode : Rectangle = rectFactory();
			for (var i : uint = 0; i < freeRectangles.length; ++i) {
				if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
					topSideY = freeRectangles[i].y + height;
					if (topSideY < score.score1 || (topSideY == score.score1 && freeRectangles[i].x < score.score2)) {
						bestNode.x = freeRectangles[i].x;
						bestNode.y = freeRectangles[i].y;
						bestNode.width = width;
						bestNode.height = height;
						score.score1 = topSideY;
						score.score2 = freeRectangles[i].x;
					}
				}
				if (allowFlip && height != width) {
					if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
						topSideY = freeRectangles[i].y + width;
						if (topSideY < score.score1 || (topSideY == score.score1 && freeRectangles[i].x < score.score2)) {
							bestNode.x = freeRectangles[i].x;
							bestNode.y = freeRectangles[i].y;
							bestNode.width = height;
							bestNode.height = width;
							score.score1 = topSideY;
							score.score2 = freeRectangles[i].x;
						}
					}
				}
			}
			return bestNode;
		}

		private function findPositionForNewNodeContactPoint(width : Number, height : Number, score : Score = null) : Rectangle {
			if (score == null) {
				score = new Score();
			}
			score.score1 = -1;
			var bestContactScore : Number;
			var bestNode : Rectangle = rectFactory();
			for (var i : uint = 0; i < freeRectangles.length; ++i) {
				if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
					bestContactScore = contactPointScoreNode(freeRectangles[i].x, freeRectangles[i].y, width, height);
					if (bestContactScore > score.score1) {
						bestNode.x = freeRectangles[i].x;
						bestNode.y = freeRectangles[i].y;
						bestNode.width = width;
						bestNode.height = height;
						score.score1 = bestContactScore;
					}
				}
				if (allowFlip && height != width) {
					if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
						bestContactScore = contactPointScoreNode(freeRectangles[i].x, freeRectangles[i].y, width, height);
						if (bestContactScore > score.score1) {
							bestNode.x = freeRectangles[i].x;
							bestNode.y = freeRectangles[i].y;
							bestNode.width = height;
							bestNode.height = width;
							score.score1 = bestContactScore;
						}
					}
				}
			}
			return bestNode;
		}

		private function findPositionForNewNodeBestLongSideFit(width : Number, height : Number, score : Score = null) : Rectangle {
			if (score == null) {
				score = new Score();
			}
			score.score2 = Number.MAX_VALUE;
			var shortSideFit : Number, longSideFit : Number;
			var leftoverHoriz : Number, leftoverVert : Number;
			var bestNode : Rectangle = rectFactory();
			for (var i : uint = 0; i < freeRectangles.length; ++i) {
				if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
					leftoverHoriz = Math.abs(freeRectangles[i].width - width);
					leftoverVert = Math.abs(freeRectangles[i].height - height);
					shortSideFit = Math.min(leftoverHoriz, leftoverVert);
					longSideFit = Math.max(leftoverHoriz, leftoverVert);
					if (longSideFit < score.score2 || (longSideFit == score.score2 && shortSideFit < score.score1)) {
						bestNode.x = freeRectangles[i].x;
						bestNode.y = freeRectangles[i].y;
						bestNode.width = width;
						bestNode.height = height;
						score.score1 = shortSideFit;
						score.score2 = longSideFit;
					}
				}
				if (allowFlip && height != width) {
					if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
						leftoverHoriz = Math.abs(freeRectangles[i].width - height);
						leftoverVert = Math.abs(freeRectangles[i].height - width);
						shortSideFit = Math.min(leftoverHoriz, leftoverVert);
						longSideFit = Math.max(leftoverHoriz, leftoverVert);
						if (longSideFit < score.score2 || (longSideFit == score.score2 && shortSideFit < score.score1)) {
							bestNode.x = freeRectangles[i].x;
							bestNode.y = freeRectangles[i].y;
							bestNode.width = height;
							bestNode.height = width;
							score.score1 = shortSideFit;
							score.score2 = longSideFit;
						}
					}
				}
			}
			return bestNode;
		}

		private function findPositionForNewNodeBestAreaFit(width : Number, height : Number, score : Score = null) : Rectangle {
			if (score == null) {
				score = new Score();
			}
			score.score1 = Number.MAX_VALUE;
			var areaFit : Number;
			var shortSideFit : Number;
			var leftoverHoriz : Number, leftoverVert : Number;
			var bestNode : Rectangle = rectFactory();
			for (var i : uint = 0; i < freeRectangles.length; ++i) {
				areaFit = freeRectangles[i].width * freeRectangles[i].height - width * height;
				if (freeRectangles[i].width >= width && freeRectangles[i].height >= height) {
					leftoverHoriz = Math.abs(freeRectangles[i].width - width);
					leftoverVert = Math.abs(freeRectangles[i].height - height);
					shortSideFit = Math.min(leftoverHoriz, leftoverVert);
					if (areaFit < score.score1 || (areaFit == score.score1 && shortSideFit < score.score2)) {
						bestNode.x = freeRectangles[i].x;
						bestNode.y = freeRectangles[i].y;
						bestNode.width = width;
						bestNode.height = height;
						score.score1 = areaFit;
						score.score2 = shortSideFit;
					}
				}
				if (allowFlip && height != width) {
					if (freeRectangles[i].width >= height && freeRectangles[i].height >= width) {
						leftoverHoriz = Math.abs(freeRectangles[i].width - height);
						leftoverVert = Math.abs(freeRectangles[i].height - width);
						shortSideFit = Math.min(leftoverHoriz, leftoverVert);
						if (areaFit < score.score1 || (areaFit == score.score1 && shortSideFit < score.score2)) {
							bestNode.x = freeRectangles[i].x;
							bestNode.y = freeRectangles[i].y;
							bestNode.width = height;
							bestNode.height = width;
							score.score1 = areaFit;
							score.score2 = shortSideFit;
						}
					}
				}
			}
			return bestNode;
		}

		private function contactPointScoreNode(x : Number, y : Number, width : Number, height : Number) : Number {
			var score : Number = 0;
			if (x == 0 || x + width == binWidth) {
				score += height;
			}
			if (y == 0 || y + height == binHeight) {
				score += width;
			}
			for (var i : uint = 0; i < usedRectangles.length; ++i) {
				if (usedRectangles[i].x == x + width || usedRectangles[i].x + usedRectangles[i].width == x) {
					score += commonIntervalLength(usedRectangles[i].y, usedRectangles[i].y + usedRectangles[i].height, y, y + height);
				}
				if (usedRectangles[i].y == y + height || usedRectangles[i].y + usedRectangles[i].height == y) {
					score += commonIntervalLength(usedRectangles[i].x, usedRectangles[i].x + usedRectangles[i].width, x, x + width);
				}
			}
			return score;
		}

		private function commonIntervalLength(i1start : Number, i1end : Number, i2start : Number, i2end : Number) : Number {
			if (i1end < i2start || i2end < i1start) {
				return 0;
			}
			return Math.min(i1end, i2end) - Math.max(i1start, i2start);
		}

		private function splitFreeNode(freeNode : Rectangle, usedNode : Rectangle) : Boolean {
			var newNode : Rectangle;
			if (usedNode.x >= freeNode.x + freeNode.width || usedNode.x + usedNode.width <= freeNode.x || usedNode.y >= freeNode.y + freeNode.height || usedNode.y + usedNode.height <= freeNode.y) {
				return false;
			}
			if (usedNode.x < freeNode.x + freeNode.width && usedNode.x + usedNode.width > freeNode.x) {
				if (usedNode.y > freeNode.y && usedNode.y < freeNode.y + freeNode.height) {
					newNode = freeNode.clone();
					newNode.height = usedNode.y - newNode.y;
					freeRectangles.push(newNode);
				}
				if (usedNode.y + usedNode.height < freeNode.y + freeNode.height) {
					newNode = freeNode.clone();
					newNode.y = usedNode.y + usedNode.height;
					newNode.height = freeNode.y + freeNode.height - (usedNode.y + usedNode.height);
					freeRectangles.push(newNode);
				}
			}
			if (usedNode.y < freeNode.y + freeNode.height && usedNode.y + usedNode.height > freeNode.y) {
				if (usedNode.x > freeNode.x && usedNode.x < freeNode.x + freeNode.width) {
					newNode = freeNode.clone();
					newNode.width = usedNode.x - newNode.x;
					freeRectangles.push(newNode);
				}
				if (usedNode.x + usedNode.width < freeNode.x + freeNode.width) {
					newNode = freeNode.clone();
					newNode.x = usedNode.x + usedNode.width;
					newNode.width = freeNode.x + freeNode.width - (usedNode.x + usedNode.width);
					freeRectangles.push(newNode);
				}
			}
			return true;
		}

		private function pruneFreeList() : void {
			for (var i : uint = 0; i < freeRectangles.length; ++i) {
				for (var j : uint = i + 1; j < freeRectangles.length; ++j) {
					if (freeRectangles[j].containsRect(freeRectangles[i])) {
						freeRectangles.splice(i, 1);
						--i;
						break;
					}
					if (freeRectangles[i].containsRect(freeRectangles[j])) {
						freeRectangles.splice(j, 1);
						--j;
					}
				}
			}
		}

		private function rectFactory() : Rectangle {
			return new Rectangle();
		}
	}
}

class Score {
	public var score1 : Number;
	public var score2 : Number;

	public function Score(score1 : Number = Number.MAX_VALUE, score2 : Number = Number.MAX_VALUE) {
		this.score1 = score1;
		this.score2 = score2;
	}
}
