package monkey.core.camera.lens {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
		
	/**
	 * 镜头 
	 * @author Neil
	 * 
	 */	
	public class Lens3D extends EventDispatcher {
			
		public static const PROJECTION_UPDATE  : String = "Lens3D:PROJECTION_UPDATE";
		
		protected static const projectionEvent : Event  = new Event(PROJECTION_UPDATE);
		
		protected var _projection 		: Matrix3D;			// 投影矩阵
		protected var _viewPort   		: Rectangle;		// 相机视口
		protected var _near		  		: Number;			// 近裁面
		protected var _far		  		: Number;			// 远裁面
		protected var _projDirty  		: Boolean;			// 投影矩阵需要更新
		protected var _invProjDirty		: Boolean;			// 投影逆矩阵需要更新
		protected var _invProjection	: Matrix3D;			// 投影逆矩阵
		protected var _zoom				: Number;			// 焦距
		
		public function Lens3D() {
			super();
			this._viewPort		= new Rectangle();
			this._projection	= new Matrix3D();
			this._invProjection	= new Matrix3D();
			this._near			= 0.1;
			this._far			= 3000;
			this._projDirty		= true;
			this._invProjDirty  = true;
		}
		
		public function clone() : Lens3D {
			var c : Lens3D = new Lens3D();
			c.copyfrom(this);
			return c;
		}
		
		public function copyfrom(lens : Lens3D) : void {
			this._viewPort.copyFrom(lens._viewPort);
			this._projection.copyFrom(lens._projection);
			this._invProjection.copyFrom(lens._invProjection);
			this._near 			= lens._near;
			this._far 			= lens._far;
			this._projDirty 	= lens._projDirty;
			this._invProjDirty 	= lens._invProjDirty;
			this._zoom 			= lens.zoom;
		}
		
		public function get aspect():Number {
			return 1;
		}
		
		/**
		 * 焦距 
		 * @return 
		 * 
		 */		
		public function get zoom():Number {
			return _zoom;
		}

		/**
		 * 焦距 
		 * @return 
		 * 
		 */		
		public function set zoom(value:Number):void {
			if (value == _zoom) {
				return;
			}
			_zoom = value;
			invalidateProjection();
		}
		
		/**
		 * 视口 
		 * @return 
		 * 
		 */		
		public function get viewPort():Rectangle {
			return _viewPort;
		}
			
		/**
		 * 视口 
		 * @return 
		 * 
		 */		
		public function setViewPort(x : Number, y : Number, width : Number, height : Number):void {
			if (_viewPort.x == x && _viewPort.y == y && _viewPort.width == width && _viewPort.height == height) {
				return;
			}
			_viewPort.setTo(x, y, width, height);
			invalidateProjection();
		}
		
		/**
		 * 远裁面 
		 * @return 
		 * 
		 */		
		public function get far():Number {
			return _far;
		}

		/**
		 * 远裁面 
		 * @return 
		 * 
		 */		
		public function set far(value:Number):void {
			if (_far == value) {
				return;
			}
			_far = value;
			invalidateProjection();
		}
		
		/**
		 * 逆投影矩阵 
		 * @return 
		 * 
		 */		
		public function get invProjection() : Matrix3D {
			if (_invProjDirty) {
				_invProjection.copyFrom(projection);
				_invProjection.invert();
				_invProjDirty = false;
			}
			return _invProjection;
		}
		
		/**
		 * 投影矩阵 
		 * @return 
		 * 
		 */		
		public function get projection() : Matrix3D {
			if (_projDirty) {
				updateProjectionMatrix();
			}
			return _projection;
		}
		
		/**
		 * 近裁面 
		 * @return 
		 * 
		 */		
		public function get near() : Number {
			return _near;
		}
				
		/**
		 * 近裁面 
		 * @return 
		 * 
		 */		
		public function set near(value : Number) : void {
			if (_near == value) {
				return;
			}
			_near = value;
			invalidateProjection();
		}
		
		protected function invalidateProjection() : void {
			this._projDirty = true;
			this._invProjDirty = true;
		}
				
		/**
		 * 更新投影矩阵 
		 */		
		public function updateProjectionMatrix() : void {
			this._projDirty 	= false;	
			this._invProjDirty 	= true;
			this.dispatchEvent(projectionEvent);
		}
		
	}
}
