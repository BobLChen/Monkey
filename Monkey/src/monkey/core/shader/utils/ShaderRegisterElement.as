package monkey.core.shader.utils {

	public class ShaderRegisterElement {
		
		/** 寄存器名称 */
		private var _regName : String;
		/** 寄存器索引 */
		private var _index   : int;
		// 寄存器
		private var _reg  	 : String;
		
		/**
		 *  
		 * @param regName	寄存器名称
		 * @param index		寄存器索引
		 * 
		 */		
		public function ShaderRegisterElement(regName : String, index : int) {
			this._regName = regName;
			this._index   = index;
			this._reg 	  = regName + index;
		}
		
		/**
		 * 寄存器名称
		 */
		public function get regName() : String {
			return this._regName;
		}
		
		/**
		 * 寄存器索引
		 */
		public function get index() : int {
			return this._index;
		}
		
		/**
		 * 寄存器 
		 * @return 
		 * 
		 */		
		public function get reg() : String {
			return _reg;
		}
		
		/**
		 * 寄存器 
		 * @return 
		 * 
		 */		
		public function toString() : String {
			return _reg;	
		}
		
	}
}
