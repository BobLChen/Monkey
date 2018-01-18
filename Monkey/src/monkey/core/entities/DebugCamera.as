package monkey.core.entities {
	
	import monkey.core.camera.Camera3D;
	import monkey.core.camera.lens.PerspectiveLens;
	import monkey.core.scene.Scene3D;

	public class DebugCamera extends Lines3D {
		
		private var _camera : Camera3D;
		private var _color 	: uint;
		private var _alpha 	: Number;
		private var _far 	: Number;
		private var _near 	: Number;
		
		public function DebugCamera(camera : Camera3D, color : int = 0xFFCB00, alpha : Number = 1) {
			super();
			this._alpha = alpha;
			this._color = color;
			this._far 	= camera.far;
			this._near 	= camera.near;
			this.camera = camera;
		}
		
		public function get camera() : Camera3D {
			return this._camera;
		}
		
		public function set camera(value : Camera3D) : void {
			if (value == null || this._camera == value) {
				return;
			}
			this._camera = value;
			this.config();
		}
		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (this._far != camera.far || this._near != camera.near) {
				this.config();
			}
			super.draw(scene, includeChildren);
		}
		
		private function config() : void {
			
			var sizeX 	: Number = 0;
			var sizeY 	: Number = 0;
			var size2X 	: Number = 0;
			var size2Y 	: Number = 0;
			
			if (this._camera == null) {
				return;
			}
			this.clear();
			
			var far 	: Number = this._camera.far;
			var aspect 	: Number = 1;
			var zoom 	: Number = 1;
			
			if (this._camera.lens is PerspectiveLens) {
				aspect = (_camera.lens as PerspectiveLens).aspect;
				zoom   = (_camera.lens as PerspectiveLens).zoom;
			}
			
			lineStyle(1, this._color, this._alpha);
			
			sizeX = zoom * this._camera.near;
			sizeY = zoom * this._camera.near / aspect;
			
			moveTo(-sizeX,  sizeY, this._camera.near);
			lineTo( sizeX,  sizeY, this._camera.near);
			lineTo( sizeX, -sizeY, this._camera.near);
			lineTo(-sizeX, -sizeY, this._camera.near);
			lineTo(-sizeX,  sizeY, this._camera.near);
			
			size2X = zoom * far;
			size2Y = zoom * far / aspect;
			
			moveTo(-size2X,  size2Y, far);
			lineTo( size2X,  size2Y, far);
			lineTo( size2X, -size2Y, far);
			lineTo(-size2X, -size2Y, far);
			lineTo(-size2X,  size2Y, far);
			lineStyle(1, _color, _alpha);
			
			moveTo( sizeX,  sizeY, this._camera.near);
			lineTo( size2X, size2Y, far);
			moveTo( sizeX, -sizeY, this._camera.near);
			lineTo( size2X,-size2Y, far);
			moveTo(-sizeX, -sizeY, this._camera.near);
			lineTo(-size2X,-size2Y, far);
			moveTo(-sizeX,  sizeY, this._camera.near);
			lineTo(-size2X, size2Y, far);
			
			this._far 	= camera.far;
			this._near 	= camera.near;
		}
	}
}
