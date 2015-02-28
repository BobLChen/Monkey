package monkey.core.shader.utils {
	
	import monkey.core.base.Surface3D;
	import monkey.core.utils.Device3D;

	public class ShaderRegisterCache {
		
		/** 使用的fs寄存器 */
		public var fsUsed : Vector.<FsRegisterLabel>;
		/** 使用的vc寄存器 */
		public var vcUsed : Vector.<VcRegisterLabel>;
		/** 使用的fc寄存器 */
		public var fcUsed : Vector.<FcRegisterLabel>;
		
		private var _vtPool 	: RegisterPool;				// vt
		private var _vcPool 	: RegisterPool; 			// vc
		private var _vaPool 	: RegisterPool; 			// va
		private var _vPool		: RegisterPool; 			// v
		private var _ftPool 	: RegisterPool; 			// ft
		private var _fcPool 	: RegisterPool; 			// fc
		private var _fsPool 	: RegisterPool;				// fs
		private var _op 		: ShaderRegisterElement;	// op
		private var _oc 		: ShaderRegisterElement;	// oc
		private var _vcMvp  	: ShaderRegisterElement;	// mvp vc
		private var _vc0123 	: ShaderRegisterElement;	// 0123常量是我们最经常用到的，因此缓存
		private var _fc0123 	: ShaderRegisterElement;	// 0123常量是我们最经常用到的，因此缓存
		private var _vas 		: Vector.<ShaderRegisterElement>;	// va寄存器
		private var _vs  		: Vector.<ShaderRegisterElement>;	// vary寄存器
		private var _vcWorld	: ShaderRegisterElement;
		private var _fcWorld	: ShaderRegisterElement;
		private var _fcView		: ShaderRegisterElement;
		private var _fcProj		: ShaderRegisterElement;
		private var _fcViewProj	: ShaderRegisterElement;
		private var _vcView		: ShaderRegisterElement;
		private var _vcProj		: ShaderRegisterElement;
		private var _vcViewProj	: ShaderRegisterElement;
		private var _normalFt	: ShaderRegisterElement;
		
		public function ShaderRegisterCache() {
			this.fsUsed  = new Vector.<FsRegisterLabel>();
			this.vcUsed  = new Vector.<VcRegisterLabel>();
			this.fcUsed  = new Vector.<FcRegisterLabel>();
			this._vas 	 = new Vector.<ShaderRegisterElement>(Surface3D.LENGTH, true);
			this._vs  	 = new Vector.<ShaderRegisterElement>(Surface3D.LENGTH, true);
			this._ftPool = new RegisterPool("ft", 8);
			this._vtPool = new RegisterPool("vt", 8);
			this._vPool  = new RegisterPool("v",  8);
			this._fsPool = new RegisterPool("fs", 8);
			this._vaPool = new RegisterPool("va", 8);
			this._fcPool = new RegisterPool("fc", 28);
			this._vcPool = new RegisterPool("vc", 128);
			this._op 	 = this.getVt();
			this._oc 	 = this.getFt();
		}
		
		/**
		 * 销毁 
		 */		
		public function dispose() : void {
			this._ftPool.dispose();
			this._vtPool.dispose();
			this._vPool.dispose();
			this._fsPool.dispose();
			this._vaPool.dispose();
			this._fcPool.dispose();
			this._vcPool.dispose();
		}
		
		/**
		 * 是否使用法线寄存器 
		 * @return 
		 * 
		 */		
		public function useNormal() : Boolean {
			return _normalFt != null;
		}
		
		/**
		 * 法线临时寄存器 
		 * @return 
		 * 
		 */		
		public function get normalFt() : ShaderRegisterElement {
			if (_normalFt == null) {
				_normalFt = getFt();
			}
			return _normalFt;
		}
				
		/**
		 * 获取mvp
		 * @return 
		 * 
		 */		
		public function get vcMvp() : ShaderRegisterElement {
			if (!_vcMvp) {
				_vcMvp = getVc(4, new VcRegisterLabel(Device3D.mvp));
			}
			return _vcMvp;
		}
		
		/**
		 * vc world寄存器 
		 * @return 
		 * 
		 */		
		public function get vcWorld() : ShaderRegisterElement {
			if (!_vcWorld) {
				_vcWorld = getVc(4, new VcRegisterLabel(Device3D.world));
			}
			return _vcWorld;
		}
		
		public function get vcView() : ShaderRegisterElement {
			if (!_vcView) {
				_vcView = getVc(4, new VcRegisterLabel(Device3D.view));
			}
			return _vcView;
		}
				
		public function get vcProj() : ShaderRegisterElement {
			if (!_vcProj) {
				_vcProj = getVc(4, new VcRegisterLabel(Device3D.proj));
			}
			return _vcProj;
		}
				
		public function get vcViewProj() : ShaderRegisterElement {
			if (!_vcViewProj) {
				_vcViewProj = getVc(4, new VcRegisterLabel(Device3D.viewProjection));
			}
			return _vcViewProj;
		}
		
		public function get fcWorld() : ShaderRegisterElement {
			if (!_fcWorld) {
				_fcWorld = getFc(4, new FcRegisterLabel(Device3D.world));
			}
			return _fcWorld;
		}
		
		public function get fcView() : ShaderRegisterElement {
			if (!_fcView) {
				_fcView = getFc(4, new FcRegisterLabel(Device3D.view));
			}
			return _fcView;
		}
		
		public function get fcProj() : ShaderRegisterElement {
			if (!_fcProj) {
				_fcProj = getFc(4, new FcRegisterLabel(Device3D.proj));
			}
			return _fcProj;
		}
		
		public function get fcViewPorj() : ShaderRegisterElement {
			if (!_fcViewProj) {
				_fcViewProj = getFc(4, new FcRegisterLabel(Device3D.viewProjection));
			}
			return _fcViewProj;
		}
		
		/**
		 * fc[0, 1, 2, 3] 
		 * @return 
		 * 
		 */		
		public function get fc0123() : ShaderRegisterElement {
			if (!_fc0123) {
				_fc0123 = getFc(1, new FcRegisterLabel(Vector.<Number>([0, 1, 2, 3])));
			}
			return _fc0123;
		}
		
		/**
		 * vc[0, 1, 2, 3] 
		 * @return 
		 * 
		 */		
		public function get vc0123() : ShaderRegisterElement {
			if (!_vc0123) {
				_vc0123 = getVc(1, new VcRegisterLabel(Vector.<Number>([0, 1, 2, 3])));
			}
			return _vc0123;
		}
		
		/**
		 * 顶点输出寄存器 
		 * @return 
		 * 
		 */		
		public function get op() : ShaderRegisterElement {
			return _op;
		}
		
		/**
		 * 颜色输出寄存器 
		 * @return 
		 * 
		 */		
		public function get oc() : ShaderRegisterElement {
			return _oc;
		}
		
		/**
		 * 属性寄存器 
		 * @return 
		 * 
		 */		
		public function get vas() : Vector.<ShaderRegisterElement> {
			return _vas;
		}
		
		/**
		 * vary寄存器 
		 * @return 
		 * 
		 */		
		public function get vs() : Vector.<ShaderRegisterElement> {
			return _vs;
		}
		
		/**
		 * 申请一个vt临时寄存器 
		 * @return 
		 * 
		 */		
		public function getVt() : ShaderRegisterElement {
			return this._vtPool.requestReg();
		}
		
		/**
		 * 归还一个vt临时寄存器 
		 * @param vt
		 * 
		 */		
		public function removeVt(vt : ShaderRegisterElement) : void {
			this._vtPool.removeUsage(vt);
		}
			
		/**
		 * 申请vc寄存器 
		 * @param num		寄存器数量
		 * @param label		与寄存器关联的数据
		 * @return 
		 * 
		 */		
		public function getVc(num : int, label : VcRegisterLabel) : ShaderRegisterElement {
			var vc : ShaderRegisterElement = this._vcPool.requestReg();
			for (var i:int = 1; i < num; i++) {
				this._vcPool.requestReg();
			}
			label.vc = vc;
			vcUsed.push(label);
			return vc;
		}
		
		/**
		 * 申请fc寄存器 
		 * @param num		寄存器数量
		 * @param label		与寄存器关联的数据
		 * @return 
		 * 
		 */				
		public function getFc(num : int, label : FcRegisterLabel) : ShaderRegisterElement {
			var fc : ShaderRegisterElement = this._fcPool.requestReg();
			for (var i:int = 1; i < num; i++) {
				this._fcPool.requestReg();
			}
			label.fc = fc;
			fcUsed.push(label);
			return fc;
		}
		
		/**
		 * 申请一个ft临时寄存器 
		 * @return 
		 * 
		 */		
		public function getFt() : ShaderRegisterElement {
			return this._ftPool.requestReg();
		}
		
		/**
		 * 申请一个fs寄存器
		 * @param label		与fs寄存器绑定的纹理
		 * @return 
		 * 
		 */		
		public function getFs(label : FsRegisterLabel) : ShaderRegisterElement {
			var fs : ShaderRegisterElement = this._fsPool.requestReg();
			label.fs = fs;
			fsUsed.push(label);
			return fs;
		}
		
		/**
		 * 获取Surface3D对应的Va 
		 * @param type	Surface3D数据类型
		 * @return 
		 * 
		 */		
		public function getVa(type : int) : ShaderRegisterElement {
			if (!_vas[type]) {
				_vas[type] = getFreeVa();
			}
			return this._vas[type];
		}
		
		/**
		 * 获取Surface3D对应的V 
		 * @param type	Surface3D数据类型
		 * @return 
		 * 
		 */		
		public function getV(type : int) : ShaderRegisterElement {
			if (!_vs[type]) {
				_vs[type] = getFreeV();
			}
			return this._vs[type];
		}
		
		/**
		 * 申请一个空闲的va 
		 * @return 
		 * 
		 */		
		public function getFreeVa() : ShaderRegisterElement {
			return this._vaPool.requestReg();
		}
		
		/**
		 * 申请一个空闲的V 
		 * @return 
		 * 
		 */		
		public function getFreeV() : ShaderRegisterElement {
			return this._vPool.requestReg();
		}
		
		/**
		 * 归还一个ft临时寄存器 
		 * @param ft
		 * 
		 */		
		public function removeFt(ft : ShaderRegisterElement) : void {
			this._ftPool.removeUsage(ft);
		}
		
	}
}
