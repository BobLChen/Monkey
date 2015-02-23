package monkey.navmesh {

	/**
	 * 二叉堆
	 * @author neil
	 *
	 */
	public class BinaryHeap {
		
		/** 二叉堆，默认1个元素占位，新建元素索引从1开始 */
		public var heap 		: Array = [null];
		
		private var compare 	: Function;
		private var length 	: int = 0;

		/**
		 * 比较函数
		 * @param compare
		 *
		 */
		public function BinaryHeap(compare : Function) {
			this.compare = compare;
		}
		
		/**
		 * 不为空 
		 * @return 
		 * 
		 */		
		public function isNotEmpty() : Boolean {
			return length > 0;
		}
		
		/**
		 * size 
		 * @return 
		 * 
		 */		
		public function get size() : int {
			return length;
		}

		/**
		 * 弹出一个元素
		 * @param i		第i个元素
		 * @return
		 *
		 */
		public function pop(i : int = 1) : Object {
			var result : Object;
			if (length > 0) {
				result = heap[i];
				var tmp : Object = heap[length];
				heap[length--] = null;
				heap[i] = tmp;
				heapify(i);
			}
			return result;
		}

		/**
		 * 压入一个元素
		 * @param obj
		 *
		 */
		public function push(obj : Object) : void {
			var index : int = ++length;
			if (index == heap.length) {
				heap.push(obj);
			} else {
				heap[index] = obj;
			}
			var parent : int = int(index / 2);
			while (parent > 0) {
				if (compare(heap[index], heap[parent]) < 0) {
					swap(index, parent)
					index = parent;
					parent = int(index / 2);
				} else {
					break;
				}
			}
		}
		
		public function indexOf(element : Object) : int {
			return heap.indexOf(element);
		}
		
		public function element(index : int) : Object {
			return heap[index + 1];
		}

		public function update(value : Object) : void {
			for (var i : int = 1; i <= length; ++i) {
				if (heap[i] == value) {
					pop(i);
					push(value);
					return;
				}
			}
		}

		public function clear() : void {
			heap = [null];
			length = 0;
		}

		private function swap(lhs : int, rhs : int) : void {
			var tmp : Object = heap[lhs];
			heap[lhs] = heap[rhs];
			heap[rhs] = tmp;
		}

		public function heapify(index : int) : void {
			var left 	: int = 2 * index;
			var right 	: int = 2 * index + 1;
			var smallest	: int = index;
			if (left <= length && compare(heap[left], heap[smallest]) < 0) {
				smallest = left;
			}
			if (right <= length && compare(heap[right], heap[smallest]) < 0) {
				smallest = right;
			}
			if (smallest != index) {
				swap(smallest, index);
				heapify(smallest);
			}
		}

	}
}
