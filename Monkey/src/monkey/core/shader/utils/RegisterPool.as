package monkey.core.shader.utils {

	public class RegisterPool {
		
		private var _registers : Vector.<ShaderRegisterElement>;
		
		/**
		 * 初始化pool 
		 * @param regName	寄存器名称
		 * @param count		寄存器数量
		 * 
		 */		
		public function RegisterPool(regName : String, count : int) {
			this._registers = new Vector.<ShaderRegisterElement>(count);
			for (var i:int = 0; i < count; i++) {
				this._registers[i] = new ShaderRegisterElement(regName, i);
			}
		}
		
		/**
		 * 申请临时寄存器 
		 * @return 
		 * 
		 */		
		public function requestReg() : ShaderRegisterElement {
			if (this._registers.length == 0) {
				throw new Error("Register overflow!");
			}
			return this._registers.shift();
		}
		
		/**
		 * 回收寄存器 
		 * @param register	register
		 * 
		 */		
		public function removeUsage(register : ShaderRegisterElement) : void {
			this._registers.push(register);
		}
		
		/**
		 *  销毁
		 */		
		public function dispose() : void {
			this._registers = null;
		}
		
	}
}
