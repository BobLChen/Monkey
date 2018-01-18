package monkey.core.camera {

	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.camera.lens.Lens3D;
	import monkey.core.components.Transform3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Matrix3DUtils;
	
	/**
	 * 相机 
	 * @author Neil
	 * 
	 */	
	public class Camera3D extends Object3D {
		
		/** 是否裁减相机视口以外区域 */
		public var clipScissor 		: Boolean;
		
		private var _lens 			: Lens3D;				// 镜头
		private var _viewProjection : Matrix3D;				// view projection
		private var _projDirty		: Boolean;				// projection dirty
		private var _viewProjDirty	: Boolean;				// view projection dirty
		
		public function Camera3D(lens : Lens3D) {
			super();
			this._projDirty 	 = true;
			this._viewProjDirty  = true;
			this._viewProjection = new Matrix3D();
			this.lens 			 = lens;
			this.lens.addEventListener(Lens3D.PROJECTION_UPDATE, onLensProjChanged);
			this.transform.addEventListener(Transform3D.UPDATE_TRANSFORM_EVENT, onUpdateTransform);
		}
		
		override public function clone():Object3D {
			var c : Camera3D = new Camera3D(lens.clone());
			for each (var icom : IComponent in components) {
				c.addComponent(icom.clone());
			}
			for each (var child : Object3D in children) {
				c.addChild(child.clone());
			}
			c._layer = this._layer;
			return c;
		}
		
		/**
		 * 相机位置更新，需要重新设置view projection 
		 * @param event
		 * 
		 */		
		private function onUpdateTransform(event:Event) : void {
			this._viewProjDirty = true;
		}
		
		/**
		 * 镜头更新 
		 * @param event
		 * 
		 */		
		private function onLensProjChanged(event:Event) : void {
			this._projDirty = true;
		}
		
		public function get zoom() : Number {
			return _lens.zoom;
		}
		
		/**
		 * 镜头 
		 * @return 
		 * 
		 */		
		public function get lens():Lens3D {
			return _lens;
		}
		
		/**
		 * 设置相机镜头 
		 * @param value
		 * 
		 */		
  		public function set lens(value:Lens3D):void {
			if (this._lens) {
				this._lens.removeEventListener(Lens3D.PROJECTION_UPDATE, onLensProjChanged);
			}
			this._lens = value;
			this._lens.addEventListener(Lens3D.PROJECTION_UPDATE, onLensProjChanged, false, 0, true);
		}
		
		/**
		 * 投影矩阵 
		 * @return 
		 * 
		 */		
		public function get projection() : Matrix3D {
			return _lens.projection;
		}
		
		/**
		 * view 
		 * @return 
		 * 
		 */		
		public function get view() : Matrix3D {
			return transform.invWorld;
		}
		
		/**
		 * view projection 
		 * @return 
		 * 
		 */		
		public function get viewProjection() : Matrix3D {
			if (this._projDirty || this._viewProjDirty) {
				this._projDirty     = false;
				this._viewProjDirty = false;
				this._viewProjection.copyFrom(view);
				this._viewProjection.append(projection);
			}
			return this._viewProjection;
		}
		
		/**
		 * 近裁面 
		 * @return 
		 * 
		 */		
		public function get near() : Number {
			return this._lens.near;
		}
		
		/**
		 * 近裁面 
		 * @return 
		 * 
		 */		
		public function set near(value : Number) : void {
			this._lens.near = value;
		}
		
		/**
		 * 远裁面 
		 * @return 
		 * 
		 */		
		public function get far() : Number {
			return this._lens.far;
		}
		
		/**
		 * 远裁面 
		 * @return 
		 * 
		 */		
		public function set far(value : Number) : void {
			this._lens.far = value;
		}
		
		public function get aspect() : Number {
			return this._lens.aspect;
		}
				
		/**
		 * 视口 
		 * @param rect
		 * 
		 */		
		public function set viewPort(rect : Rectangle) : void {
			this._lens.setViewPort(rect.x, rect.y, rect.width, rect.height);
		}
		
		/**
		 * 设置视口 
		 * @param x			x坐标
		 * @param y			y坐标
		 * @param width		宽度
		 * @param height	高度
		 * 
		 */		
		public function setViewPort(x : int, y : int, width : int, height : int) : void {
			this._lens.setViewPort(x, y, width, height);
		}
		
		/**
		 * 视口 
		 * @param rect
		 * 
		 */		
		public function get viewPort() : Rectangle {
			return this._lens.viewPort;
		}
		
		/**
		 * 获取方向，相机尺寸必须和scene尺寸一样。
		 * @param x			2d x坐标
		 * @param y			2d y坐标
		 * @param out		方向
		 * @return 
		 * 
		 */		
		public function getPointDir(x : Number, y : Number, out : Vector3D = null) : Vector3D {
			if (!out) {
				out = new Vector3D();
			}
			var rect : Rectangle = Device3D.scene.viewPort;
			// 转换到3d投影之后的坐标
			x = x - rect.x;
			y = y - rect.y;
			out.x = ((x / rect.width) - 0.5) * 2;
			out.y = ((-y / rect.height) + 0.5) * 2;
			out.z = 1;
			// 通过逆矩阵转换到投影之前的坐标
			Matrix3DUtils.transformVector(lens.invProjection, out, out);
			out.x = out.x * out.z;
			out.y = out.y * out.z;
			// 转换到view空间 PS:view就是invWorld
			Matrix3DUtils.deltaTransformVector(transform.world, out, out);
			out.normalize();
			return out;
		}
		
	}
}
