package monkey.core.utils {
	
	import flash.geom.Point;
	
	/**
	 * 线性数据 
	 * @author Neil
	 * 
	 */	
	public class Linears {
		
		public var datas : Vector.<Point>;
		public var yValue: Number = 1;
		
		public function Linears() {
			this.datas = Vector.<Point>([]);
		}
		
		/**
		 * 获取Y轴值 
		 * @param x
		 * @return 
		 * 
		 */		
		public function getY(x : Number) : Number {
			// 二分法查找关键帧
			var left  : int = 0;
			var len	  : Number = datas.length;
			var right : int = len;
			var mid   : int = 0;
			var lp 	  : Point = null;
			var rp 	  : Point = null;
			while (left < right) {
				mid = int((left + right) / 2);
				if (datas[mid].x == x) {
					lp = datas[mid];
					rp = datas[mid];
					return datas[mid].y;
					break;
				}
				var less : Boolean = x < datas[mid].x;
				if (less && mid - 1 < 0) {
					rp = datas[mid];
					lp = null;
					break;
				}
				if (less && x > datas[mid-1].x) {
					rp = datas[mid];
					lp = datas[mid - 1];
					break;
				}
				if (!less && mid + 1 >= len) {
					lp = datas[mid];
					rp = null;
					break;
				}
				if (!less && x < datas[mid + 1].x) {
					lp = datas[mid];
					rp = datas[mid + 1];
					break;
				}
				if (less) {
					right = mid;
				} else {
					left = mid;
				}
			}
			if (lp == null) {
				return datas[0].y;
			}
			if (rp == null) {
				return datas[len - 1].y;
			}
			// 插值
			len = rp.x - lp.x;
			return lp.y + (rp.y - lp.y) * (x - lp.x) / len;
		}
		
	}
}
