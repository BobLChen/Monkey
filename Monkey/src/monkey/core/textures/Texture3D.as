package monkey.core.textures {
	
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import monkey.core.scene.Scene3D;
	
	public class Texture3D extends EventDispatcher {
		
		public static const DISPOSE : String = "dispose";
		protected static const disposeEvent : Event = new Event(DISPOSE);
		
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
		public var magMode  	: String;
		/** 寻址模式 */
		public var wrapMode		: String;
		/** 缩减模型 */
		public var mipMode		: String;
		/** 纹理格式 */
		public var typeMode		: String;
		/** 名称 */
		public var name			: String = "";
		
		protected var ref		: int;				// 引用计数
		protected var _disposed	: Boolean;			// 是否已经被销毁
		protected var _width	: int;				// 宽度
		protected var _height	: int;				// 高度
		
		/**
		 * 
		 * @param type	贴图格式
		 * @param mag	倍增模式
		 * @param wrap	寻址模式
		 * @param mip	缩减模式
		 * 
		 */		
		public function Texture3D(type : String = TYPE_2D, mag : String = MAG_LINEAR, wrap : String = WRAP_REPEAT, mip : String = MIP_LINEAR) {
			this.ref = 0;
			this._disposed = false;
			this.typeMode= type;
			this.magMode = mag;
			this.wrapMode= wrap;
			this.mipMode = mip;
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		public function clone() : Texture3D {
			ref++;
			return this;
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
			this.scene.addEventListener(Scene3D.CREATE_EVENT, contextEvent, false, 0, true);
			this.unloadTexture();
		}
		
		/**
		 * 卸载 
		 * @param force	是否强制卸载
		 * 
		 */		
		public function download(force : Boolean) : void {
			if (ref > 0 && !force) {
				return;
			}
			if (scene) {
				scene.removeEventListener(Scene3D.CREATE_EVENT, contextEvent);
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
			if (ref > 0 && !force) {
				ref--;
				return;
			}
			this.download(true);
			this._disposed = true;
			this.dispatchEvent(disposeEvent);
		}
		
	}
}
