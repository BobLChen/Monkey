package monkey.core.shader {

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import monkey.core.base.Surface3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.shader.filters.Filter3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FilterQuickSortUtils;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.utils.AGALMiniAssembler;
	import monkey.core.utils.Device3D;
	
	/**
	 * shader 
	 * @author Neil
	 */	
	public class Shader3D extends EventDispatcher {
				
		/** 名称 */
		public var name 			: String;
		public var scene			: Scene3D;
		
		private var regCache 		: ShaderRegisterCache;					// 寄存器
		private var _filters 		: Vector.<Filter3D>;					// filters
		private var _program 		: Program3D;							// GPU指令
		private var _sourceFactor	: String;								// 混合模式
		private var _destFactor		: String;								// 混合模式
		private var _depthWrite 	: Boolean;								// 开启深度
		private var _depthCompare 	: String;								// 测试条件
		private var _cullFace 		: String;								// 裁剪
		private var _programDirty	: Boolean = true;						// GPU指令
		private var _disposed		: Boolean = false;						// 是否已经被dispose
		private var _initWithBytes  : Boolean = false;						// 通过bytes初始化shader
		private var _vertAgalCode   : ByteArray;							// agal code
		private var _fragAgalCode   : ByteArray;							// agal code
		
		public function Shader3D(filters : Array) {
			super(null);
			this.name 			= "Shader3D";
			this._filters  	 	= Vector.<Filter3D>(filters);
			this._depthWrite  	= Device3D.defaultDepthWrite;
			this._depthCompare	= Device3D.defaultCompare;
			this._cullFace	 	= Device3D.defaultCullFace;
			this._sourceFactor	= Device3D.defaultSourceFactor;
			this._destFactor	= Device3D.defaultDestFactor;
			this._programDirty 	= true;
		}
		
		/**
		 * 片段着色器指令 
		 * @return 
		 * 
		 */		
		public function get fragAgalCode() : ByteArray {
			return _fragAgalCode;
		}
		
		/**
		 * 顶点着色器指令 
		 * @return 
		 * 
		 */		
		public function get vertAgalCode() : ByteArray {
			return _vertAgalCode;
		}
		
		/**
		 * 通过bytes初始化shader
		 */
		public function initWithBytes(vert : ByteArray, frag : ByteArray) : void {
			this._vertAgalCode = vert;
			this._fragAgalCode = frag;
			this._initWithBytes= true;
		}
		
		/**
		 * 是否已经被释放 
		 * @return 
		 * 
		 */		
		public function get disposed() : Boolean {
			return _disposed;
		}
		
		/**
		 * 获取所有的filter 
		 * @return 
		 * 
		 */		
		public function get filters() : Vector.<Filter3D> {
			return this._filters;
		}
		
		/**
		 * 通过名称获取Filter 
		 * @param name
		 * @return 
		 * 
		 */		
		public function getFilterByName(name : String) : Filter3D {
			for each (var filter : Filter3D in filters) {
				if (filter.name == name) {
					return filter;
				}
			}
			return null;
		}
		
		/**
		 * 通过类型获取Filter 
		 * @param clazz
		 * @return 
		 * 
		 */		
		public function getFilterByClass(clazz : Class) : Filter3D {
			for each (var filter : Filter3D in filters) {
				if (filter is clazz) {
					return filter;
				}
			}
			return null;
		}
		
		/**
		 * 添加一个Filter 
		 * @param filter
		 * 
		 */		
		public function addFilter(filter : Filter3D) : void {
			if (filters.indexOf(filter) == -1) {
				this.filters.push(filter);
				this._programDirty  = true;
				this._initWithBytes = false;
			}
		}
		
		/**
		 * 移除一个Filter 
		 * @param filter
		 * 
		 */		
		public function removeFilter(filter : Filter3D) : void {
			var idx : int = this.filters.indexOf(filter);
			if (idx != -1) {
				this.filters.splice(idx, 1);
				this._programDirty  = true;
				this._initWithBytes = false;
			}
		}
		
		/**
		 * 
		 * @param context		context3d
		 * @param mvp			mvp
		 * @param surface		网格数据
		 * @param firstIdx		第一个三角形索引
		 * @param count			三角形数量
		 * 
		 */		
		public function draw(scene3d : Scene3D, surface : Surface3D, firstIdx : int = 0, count : int = -1) : void {
			if (!this.scene || this._programDirty) {
				this.upload(scene3d);
			}
			if (!surface.scene) {
				surface.upload(scene3d);
			}
			for each (var filter : Filter3D in filters) {
				filter.update();
			}
			var context : Context3D = scene3d.context;
			Device3D.drawCalls++;
			Device3D.triangles += count;
			// 设置program
			context.setProgram(_program);
			setContextDatas(context, surface);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, regCache.vcMvp.index, Device3D.mvp, true);
			context.drawTriangles(surface.indexBuffer, firstIdx, count);
			// clear
			clearContextDatas(context);
		}
		
		private function clearContextDatas(context : Context3D) : void {
			for each (var va : ShaderRegisterElement in regCache.vas) {
				if (va) {
					context.setVertexBufferAt(va.index, null);
				}
			}
			for each (var fs : FsRegisterLabel in regCache.fsUsed) {
				context.setTextureAt(fs.fs.index, null);
			}
		}
		
		/**
		 * 设置context数据 
		 * @param context	context
		 * @param surface	网格数据
		 * 
		 */		
		private function setContextDatas(context : Context3D, surface : Surface3D) : void {
			var i   : int = 0;
			var len : int = regCache.vas.length;
			// 设置va数据
			for (i = 0; i < len; i++) {
				var va : ShaderRegisterElement = regCache.vas[i];
				if (va) {
					context.setVertexBufferAt(va.index, surface.vertexBuffers[i], 0, surface.formats[i]);
				}
			}
			// 设置vc数据
			for each (var vcLabel : VcRegisterLabel in regCache.vcUsed) {
				if (vcLabel.vector) {
					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vcLabel.vc.index, vcLabel.vector, vcLabel.num);
				} else if (vcLabel.matrix) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, vcLabel.vc.index, vcLabel.matrix, true);
				} else {
					context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, vcLabel.vc.index, vcLabel.num, vcLabel.bytes, 0);
				}
			}
			// 设置fc
			for each (var fcLabel : FcRegisterLabel in regCache.fcUsed) {
				if (fcLabel.vector) {
					// vector频率使用得最高
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fcLabel.fc.index, fcLabel.vector, fcLabel.num);
				} else if (fcLabel.matrix) {
					// matrix其次
					context.setProgramConstantsFromMatrix(Context3DProgramType.FRAGMENT, fcLabel.fc.index, fcLabel.matrix, true);
				} else {
					// bytes最后
					context.setProgramConstantsFromByteArray(Context3DProgramType.FRAGMENT, fcLabel.fc.index, fcLabel.num, fcLabel.bytes, 0);
				}
			}
			// 设置fs
			for each (var fsLabel : FsRegisterLabel in regCache.fsUsed) {
				context.setTextureAt(fsLabel.fs.index, fsLabel.texture.texture);
			}
		}
				
		/**
		 * 卸载 
		 */		
		public function download() : void {
			if (this.scene) {
				this.scene.removeEventListener(Scene3D.CREATE_EVENT, this.context3DEvent);
				var idx : int = scene.shaders.indexOf(this);
				if (idx != -1) {
					this.scene.shaders.splice(idx, 1);
				}
			}
			this.scene = null;
			this.downloadProgram();
		}
				
		/**
		 * 卸载program 
		 */		
		private function downloadProgram() : void {
			if (this._program) {
				this._program.dispose();
				this._program = null;
			}
			if (this.regCache) {
				this.regCache.dispose();
				this.regCache = null;
			}
			this._programDirty = true;
		}
		
		/**
		 * 上传 
		 * @param context
		 * 
		 */		
		public function upload(scene3d : Scene3D) : void {
			if (scene == scene3d) {
				return;
			}
			if (!_programDirty) {
				return;
			}
			this.scene = scene3d;
			this.context3DEvent();
		}
		
		/**
		 * context3d event 
		 * @param event
		 * 
		 */		
		private function context3DEvent(event : Event = null) : void {
			this.scene.addEventListener(Scene3D.CREATE_EVENT, context3DEvent);
			this.build();
			if (this.scene.shaders.indexOf(this) == -1) {
				this.scene.shaders.push(this);
			}
		}
		
		/**
		 * build 
		 */		
		public function build() : void {
			if (!scene || !this._programDirty) {
				return;
			}
			this.downloadProgram();							// 卸载program
			this.regCache = new ShaderRegisterCache();		// 初始化寄存器管理器
			// filter排序
			FilterQuickSortUtils.sortByPriorityAsc(filters, 0 , filters.length - 1);
			// 是否生成agal code
			var agalcode : Boolean = false;
			if (!_initWithBytes || Device3D.debug) {
				agalcode = true;
			}
			// build
			var fragCode : String = buildFragmentCode(agalcode);		// build 片段着色器
			var vertCode : String = buildVertexCode(agalcode);		// build 顶点着色器
			// 通过bytes初始化的shader不需要进行编译
			if (!this._initWithBytes) {						
				var vertAgal : AGALMiniAssembler = new AGALMiniAssembler();
				vertAgal.assemble(Context3DProgramType.VERTEX, vertCode);
				var fragAgal : AGALMiniAssembler = new AGALMiniAssembler();
				fragAgal.assemble(Context3DProgramType.FRAGMENT, fragCode);
				this._vertAgalCode = vertAgal.agalcode;
				this._fragAgalCode = fragAgal.agalcode;
			}
			// trace agal
			if (Device3D.debug) {
				trace('---------程序开始------------');
				trace('---------顶点程序------------');
				trace(vertCode);
				trace('---------片段程序------------');
				trace(fragCode);
				trace('---------程序结束------------');
			}
			// program
			this._program = scene.context.createProgram();
			this._program.upload(_vertAgalCode, _fragAgalCode);
			this._programDirty = false;
		}
		
		/**
		 * 构建片段着色程序 
		 * 最先构建片段着色程序，因为只有最先构建了片段着色程序之后，在顶点程序中才只能，片段着色程序需要使用到哪些V变量。
		 * @return 
		 * 
		 */		
		private function buildFragmentCode(agal : Boolean) : String {
			// 对oc进行初始化
			var code : String = "mov " + regCache.oc + ", " + regCache.fc0123 + ".yyyy \n";
			for each (var filter : Filter3D in filters) {
				code += filter.getFragmentCode(regCache, agal);
			}
			if (regCache.useNormal()) {
				code = "mov " + regCache.normalFt + ", " + regCache.getV(Surface3D.NORMAL) + " \n" + code;
			}
			code += "mov oc, " + regCache.oc + " \n";
			return code;
		}
		
		/**
		 * 构建顶点着色程序 
		 * @return 
		 * 
		 */		
		private function buildVertexCode(agal : Boolean) : String {
			// 对op进行初始化
			var code : String = "mov " + regCache.op + ", " + regCache.getVa(Surface3D.POSITION) + " \n"; 
			// 开始对v变量进行赋值,vs是所有在片段程序中使用到的v变量,通过getV()获取,vs数组索引就是surface3d对应数据类型
			var length : int = regCache.vs.length;		
			for (var i:int = 0; i < length; i++) {
				if (regCache.vs[i]) {
					code += "mov " + regCache.getV(i) + ", " + regCache.getVa(i) + " \n";
				}
			}
			// 转换法线
			if (regCache.vs[Surface3D.NORMAL]) {
				var vt0 : ShaderRegisterElement = regCache.getVt();
				code += "m33 " + vt0 + ".xyz, " + regCache.getVa(Surface3D.NORMAL) + ", " + regCache.vcWorld + " \n";
				code += "nrm " + regCache.getV(Surface3D.NORMAL) + ".xyz, " + vt0 + ".xyz \n";
				regCache.removeVt(vt0);
			}
			// 拼接filter的顶点shader
			for each (var filter : Filter3D in filters) {
				code += filter.getVertexCode(regCache, agal);
			}
			// 对filter拼接完成之后，将regCache.op输出到真正的op寄存器
			code += "m44 op, " + regCache.op + ", " + regCache.vcMvp + " \n";
			return code;
		}
		
		/**
		 * 释放 
		 */		
		public function dispose() : void {
			if (disposed) {
				return;
			}
			this.download();
			this._disposed= true;
			this._filters = null;
		}
		
	}
}
