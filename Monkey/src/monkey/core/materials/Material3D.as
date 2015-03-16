package monkey.core.materials {
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DTriangleFace;
	
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.utils.Device3D;
	
	/**
	 * 材质组件 
	 * @author Neil
	 * 
	 */	
	public class Material3D {
		
		public static const BLEND_NONE 			: String = 'BLEND_NONE';
		public static const BLEND_ADDITIVE 		: String = 'BLEND_ADDITIVE';
		public static const BLEND_ALPHA_BLENDED : String = 'BLEND_ALPHA_BLENDED';
		public static const BLEND_MULTIPLY 		: String = 'BLEND_MULTIPLY';
		public static const BLEND_SCREEN 		: String = 'BLEND_SCREEN';
		public static const BLEND_ALPHA 		: String = 'BLEND_ALPHA';
		
		protected var _sourceFactor	: String;								// 混合模式
		protected var _destFactor	: String;								// 混合模式
		protected var _depthWrite 	: Boolean;								// 开启深度
		protected var _depthCompare : String;								// 测试条件
		protected var _cullFace 	: String;								// 裁剪
		protected var _blendMode 	: String = BLEND_NONE;					// 混合模式
		protected var _stateDirty	: Boolean = false;						// context状态
		protected var _shader 		: Shader3D;								// shader
		
		public function Material3D(shader : Shader3D = null) {
			this._shader 		= shader;
			this._stateDirty	= false;
			this._depthWrite  	= Device3D.defaultDepthWrite;
			this._depthCompare	= Device3D.defaultCompare;
			this._cullFace	 	= Device3D.defaultCullFace;
			this._sourceFactor	= Device3D.defaultSourceFactor;
			this._destFactor	= Device3D.defaultDestFactor;
		}
				
		/**
		 * 材质使用的shader 
		 * @return 
		 * 
		 */		
		public function get shader():Shader3D {
			return _shader;
		}
		
		/**
		 * 开始绘制 
		 * @param scene
		 * 
		 */		
		public function draw(scene : Scene3D, mesh : Mesh3D) : void {
			// 设置shader当前数据
			setShaderDatas(scene);
			// 修改混合、深度测试、裁减
			if (_stateDirty) {
				scene.context.setBlendFactors(sourceFactor, destFactor);
				scene.context.setDepthTest(depthWrite, depthCompare);
				scene.context.setCulling(cullFace);
			}
			for each (var surf : Surface3D in mesh.surfaces) {
				shader.draw(scene, surf, 0, surf.numTriangles);
			}
			// 重置回默认状态
			if (_stateDirty) {
				scene.context.setBlendFactors(Device3D.defaultSourceFactor, Device3D.defaultDestFactor);
				scene.context.setDepthTest(Device3D.defaultDepthWrite, Device3D.defaultCompare);
				scene.context.setCulling(Device3D.defaultCullFace);
			}
		}
				
		/**
		 * 克隆材质 
		 * @return 
		 * 
		 */		
		public function clone():Material3D {
			var c : Material3D = new Material3D();
			c._shader = shader;
			return c;
		}
		
		/**
		 * 销毁材质 
		 * 
		 */		
		public function dispose():void {
			this._shader = null;
		}
		
		/**
		 * 更新材质 
		 * 
		 */		
		protected function setShaderDatas(scene : Scene3D) : void {
			
		}
		
		/** 裁剪 */
		public function get cullFace() : String {
			return _cullFace;
		}
		
		/**
		 * @private
		 */
		public function set cullFace(value:String):void {
			_cullFace = value;
			this.validateState();
		}
		
		/** 深度测试条件 */
		public function get depthCompare():String {
			return _depthCompare;
		}
		
		/**
		 * @private
		 */
		public function set depthCompare(value:String):void {
			_depthCompare = value;
			this.validateState();
		}
		
		/** 深度测试 */
		public function get depthWrite():Boolean {
			return _depthWrite;
		}
		
		/**
		 * @private
		 */
		public function set depthWrite(value:Boolean):void {
			_depthWrite = value;
			this.validateState();
		}
		
		/** 混合模式->destFactor */
		public function get destFactor():String {
			return _destFactor;
		}
		
		/**
		 * @private
		 */
		public function set destFactor(value:String):void {
			_destFactor = value;
			this.validateState();
		}
		
		/** 混合模式->sourceFactor */
		public function get sourceFactor():String {
			return _sourceFactor;
		}
		
		/**
		 * @private
		 */
		public function set sourceFactor(value:String):void {
			_sourceFactor = value;
			this.validateState();
		}
		
		/**
		 * 透明 
		 * @return 
		 */		
		public function get transparent() : Boolean {
			return blendMode == BLEND_ALPHA ? true : false;
		}
		
		/**
		 * 透明 
		 * @param value
		 */		
		public function set transparent(value : Boolean) : void {
			if (value) {
				this.blendMode = BLEND_ALPHA;
			} else {
				this.blendMode = BLEND_NONE;
			}
		}
		
		/**
		 * 双面显示 
		 * @return 
		 */		
		public function get twoSided() : Boolean {
			return this.cullFace == Context3DTriangleFace.NONE;
		}
		
		/**
		 * 双面显示
		 * @param value
		 */
		public function set twoSided(value : Boolean) : void {
			if (value) {
				this.cullFace = Context3DTriangleFace.NONE;
			} else {
				this.cullFace = Context3DTriangleFace.BACK;
			}
			this.validateState();
		}
		
		/**
		 * 混合模式 
		 * @return 
		 * 
		 */		
		public function get blendMode() : String {
			return this._blendMode;
		}
		
		/**
		 * 设置混合模式
		 * @param value
		 */
		public function set blendMode(value : String) : void {
			if (_blendMode == value) {
				return;
			}
			this._blendMode = value;
			switch (this._blendMode) {
				case BLEND_NONE:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ZERO;
					break;
				case BLEND_ADDITIVE:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ONE;
					break;
				case BLEND_ALPHA_BLENDED:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BLEND_MULTIPLY:
					this.sourceFactor 	= Context3DBlendFactor.DESTINATION_COLOR;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BLEND_SCREEN:
					this.sourceFactor 	= Context3DBlendFactor.ONE;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
					break;
				case BLEND_ALPHA:
					this.sourceFactor 	= Context3DBlendFactor.SOURCE_ALPHA;
					this.destFactor 	= Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
			}
			this.validateState();
		}
		
		private function validateState() : void {
			this._stateDirty = true;
			if (this.sourceFactor 	== Device3D.defaultSourceFactor &&
				this.destFactor		== Device3D.defaultDestFactor	&&
				this.depthCompare	== Device3D.defaultCompare		&&
				this.depthWrite		== Device3D.defaultDepthWrite	&&
				this.cullFace		== Device3D.defaultCullFace) {
				this._stateDirty = false;
			}
		}
		
	}
}
