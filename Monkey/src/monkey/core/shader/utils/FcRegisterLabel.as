package monkey.core.shader.utils {
	
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;

	/**
	 * fc寄存器标签 
	 * @author Neil
	 * 
	 */	
	public class FcRegisterLabel {
		
		public var fc 		: ShaderRegisterElement;
		private var _num 	: int;
		private var _vector : Vector.<Number>;
		private var _matrix : Matrix3D;
		private var _bytes	: ByteArray;
		
		public function FcRegisterLabel(data : Object) {
			if (data) {
				if (data is Vector.<Number>) {
					vector = data as Vector.<Number>;
				} else if (data is Matrix3D) {
					matrix = data as Matrix3D;
				} else if (data is ByteArray) {
					bytes  = data as ByteArray;
				} else {
					throw new Error("ʕ•̫͡•ʕ*̫͡*ʕ error data");
				}
			}
		}
		
		public function set bytes(value:ByteArray):void {
			_bytes = value;
			_num = _bytes.length / 4 / 4;
		}

		public function set matrix(value:Matrix3D):void {
			_matrix = value;
			_num = 1;
		}

		public function set vector(value:Vector.<Number>):void {
			_vector = value;
			_num = value.length / 4;
		}
		
		/**
		 * bytes 
		 * @return 
		 * 
		 */		
		public function get bytes()  : ByteArray {
			return _bytes;
		}
		
		/**
		 * matrix 
		 * @return 
		 * 
		 */		
		public function get matrix() : Matrix3D {
			return _matrix;
		}
		
		/**
		 * vector
		 * @return 
		 * 
		 */		
		public function get vector() : Vector.<Number> {
			return _vector;
		}
		
		/**
		 * size 
		 * @return 
		 * 
		 */		
		public function get num() : int {
			return _num;
		}
		
	}
}
