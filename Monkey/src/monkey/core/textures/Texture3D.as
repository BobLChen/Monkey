package monkey.core.textures {
	
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	
	import monkey.core.base.Ref;
	import monkey.core.scene.Scene3D;
	
	public class Texture3D {
		
		/** 倍增常量插值 */
		public static const MAG_NEAREST 	: String = 'nearest';
		/** 倍增线性插值 */
		public static const MAG_LINEAR 		: String = 'linear';
		/** clamp寻址模式 */
		public static const WRAP_CLAMP 		: String = 'clamp';
		/** repeat寻址模式 */
		public static const WRAP_REPEAT 	: String = 'repeat';
		/** 2d纹理格式 */
		public static const TYPE_2D 		: String = '2d';
		/** cube纹理格式 */
		public static const TYPE_CUBE 		: String = 'cube';
		/** 不启用MIP */
		public static const MIP_NONE 		: String = 'mipnone';
		/** 常量MIP插值 */
		public static const MIP_NEAREST 	: String = 'mipnearest';
		/** 线性MIP插值 */
		public static const MIP_LINEAR 		: String = 'miplinear';
		
		/** 纹理 */
		public var texture 		: TextureBase;
		/** scene */
		public var scene   		: Scene3D;
		/** 倍增模式 */
		public var magMode  	: String = MAG_LINEAR;
		/** 寻址模式 */
		public var wrapMode		: String = WRAP_REPEAT;
		/** 缩减模型 */
		public var mipMode		: String = MIP_LINEAR;
		/** 纹理格式 */
		public var typeMode		: String = TYPE_2D;
		/** 名称 */
		public var name			: String = "";
		
		protected var ref		: Ref;				// 引用计数
		protected var _disposed	: Boolean;			// 是否已经被销毁
		protected var _width	: int;				// 宽度
		protected var _height	: int;				// 高度
		
		public function Texture3D() {
			this.ref = new Ref();
			this._disposed = false;
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		public function clone() : Texture3D {
			var c : Texture3D = new Texture3D();
			c.texture	= texture;
			c.scene		= scene;
			c.magMode= magMode;
			c.wrapMode	= wrapMode;
			c.mipMode	= mipMode;
			c.typeMode		= typeMode;
			c.name		= name;
			c.ref		= ref;
			c._disposed	= _disposed;
			c._width	= _width;
			c._height	= _height;
			ref.ref++;
			return c;
		}
		
		public function get disposed() : Boolean {
			return _disposed;
		}
		
		/**
		 * 纹理高度 
		 * @return 
		 * 
		 */		
		public function get height() : int {
			return _height;
		}
				
		/**
		 * 纹理宽度 
		 * @return 
		 * 
		 */		
		public function get width() : int {
			return _width;
		}
		
		/**
		 * 上传贴图 
		 * @param scene
		 * 
		 */		
		public function upload(scene3d : Scene3D) : void {
			if (this.scene == scene3d) {
				return;
			}
			this.scene = scene3d;
			this.contextEvent();
		}
		
		protected function contextEvent(e : Event = null) : void {
			if (this.scene.textures.indexOf(this) == -1) {
				this.scene.textures.push(this);
			}
			this.scene.addEventListener(Scene3D.CREATE, contextEvent, false, 0, true);
			this.unloadTexture();
		}
		
		/**
		 * 卸载 
		 * @param force	是否强制卸载
		 * 
		 */		
		public function download(force : Boolean) : void {
			if (disposed) {
				return;
			}
			if (ref.ref > 0 && !force) {
				return;
			}
			if (scene) {
				scene.removeEventListener(Scene3D.CREATE, contextEvent);
				var idx : int = scene.textures.indexOf(this);
				if (idx != -1) {
					scene.textures.splice(idx, 1);
				}
			}
			scene = null;
			unloadTexture();
		}
		
		/**
		 * 卸载texture 
		 * 
		 */		
		private function unloadTexture() : void {
			if (texture) {
				texture.dispose();
			}
			texture = null;
		}
		
		/**
		 * 销毁texture 
		 * 
		 */		
		public function dispose(force : Boolean = false) : void {
			if (disposed) {
				return;
			}
			this._disposed = true;
			if (ref.ref > 0 && !force) {
				ref.ref--;
				return;
			}
			this.download(true);
		}
		
	}
}
