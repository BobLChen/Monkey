package monkey.core.camera.lens {

	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	
	/**
	 * 透视投影 
	 * @author Neil
	 * 
	 */	
	public class PerspectiveLens extends Lens3D {
		
		private static const rawData : Vector.<Number> = new Vector.<Number>(16, true);

		private var _fieldOfView : Number;			// field of view
		private var _aspect 	 : Number;			// 横纵比
		
		public function PerspectiveLens(fieldOfView : Number = 75) {
			super();
			this._aspect = 1.0;
			this.fieldOfView = fieldOfView;
		}
		
		override public function clone():Lens3D {
			var c : PerspectiveLens = new PerspectiveLens();
			c.copyfrom(this);
			c._fieldOfView = this._fieldOfView;
			c._aspect = this._aspect;
			return c;
		}
		
		override public function get aspect():Number {
			return this._aspect;
		}
		
		/**
		 * 焦距 
		 * @param value
		 * 
		 */		
		override public function set zoom(value : Number) : void {
			if (_zoom == value) {
				return;
			}
			_zoom = value;
			_fieldOfView = Math.atan(value) * 360 / Math.PI;
			invalidateProjection();
		}
		
		public function get fieldOfView() : Number {
			return _fieldOfView;
		}
		
		public function set fieldOfView(value : Number) : void {
			if (value == _fieldOfView) {
				return;
			}
			_fieldOfView = value;
			_zoom = Math.tan(value * Math.PI / 360);
			invalidateProjection();
		}
		
		override public function updateProjectionMatrix() : void {
						
			var w : Number = viewPort.width;
			var h : Number = viewPort.height;
			var n : Number = near;
			var f : Number = far;
			var a : Number = w / h;
			var y : Number = 1 / this._zoom * a;
			var x : Number = y / a;
			
			rawData[0] = x;
			rawData[5] = y;
			rawData[10] = f / (n - f);
			rawData[11] = -1;
			rawData[14] = (f * n) / (n - f);
			
			var scene : Scene3D = Device3D.scene;
			if (scene && scene.viewPort) {
				w = scene.viewPort.width;
				h = scene.viewPort.height;
			}
			rawData[0] = x / (w / viewPort.width);
			rawData[5] = y / (h / viewPort.height);
			rawData[8] = 1  - (viewPort.width  / w) - (viewPort.x / w) * 2;
			rawData[9] = -1 + (viewPort.height / h) + (viewPort.y / h) * 2;
			
			this._aspect    = a;
			this._projection.copyRawDataFrom(rawData);
			this._projection.prependScale(1, 1, -1);
			
			super.updateProjectionMatrix();
		}
		
	}
}
