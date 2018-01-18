package monkey.core.utils {
	
	import flash.geom.Point;
	
	/**
	 * 曲线数据 
	 * @author Neil
	 * 
	 */	
	public class Curves {
				
		public var datas : Vector.<Point>;
		
		public function Curves() {
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
			var tx : Number = 0;
			var h  : Number = lp.y - rp.y;
			if (h < 0) {
				h *= -1;
				tx = Math.PI;
			}
			len = rp.x - lp.x;
			return lp.y - Math.sin((x - lp.x) / len * Math.PI / 2 + tx) * h;
		}
		
	}
}
