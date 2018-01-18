package monkey.core.shader.utils {

	import monkey.core.shader.filters.Filter3D;

	public class FilterQuickSortUtils {

		/**
		 * 快排，决定绘制顺序,asc
		 * @param data
		 * @param left
		 * @param right
		 */
		public static function sortByPriorityAsc(data : Vector.<Filter3D>, left : int, right : int) : void {
			var i : int = 0;
			var j : int = 0;
			var e : int = 0;
			var priority : int;
			var pivot : Filter3D;
			var temp : Filter3D;
			if (right - left < 20) {
				i = left + 1;
				right++;
				while (i < right) {
					pivot = data[i];
					j = (i - 1);
					e = i;
					priority = pivot.priority;
					while ((j >= left) && (data[j].priority < priority)) {
						data[e--] = data[j--];
					}
					data[e] = pivot;
					i++;
				}
			} else {
				i = left;
				j = right;
				pivot = data[((left + right) >>> 1)];
				priority = pivot.priority;
				while (i <= j) {
					while (data[j].priority < priority) {
						j--;
					}
					while (data[i].priority > priority) {
						i++;
					}
					if (i <= j) {
						temp = data[i];
						data[i] = data[j];
						i++;
						data[j] = temp;
						j--;
					}
				}
				if (left < j) {
					sortByPriorityAsc(data, left, j);
				}
				if (i < right) {
					sortByPriorityAsc(data, i, right);
				}
			}
		}
	}
}
