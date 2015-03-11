package monkey.core.entities {
	
	import flash.geom.Rectangle;
	
	import monkey.core.base.Surface3D;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;

	public class Quad extends Mesh3D {
		
		public var fullScreenMode : Boolean = true;
		
		private var _x 		: Number;
		private var _y 		: Number;
		private var _width 	: Number;
		private var _height : Number;
		private var _surf 	: Surface3D;
		
		public function Quad(x : Number = 0, y : Number = 0, width : Number = 100, height : Number = 100, fullScreenMode : Boolean = false) {
			super([]);
			this._surf = new Surface3D();
			this._surf.setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
			this._surf.setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
			this._surf.indexVector = new Vector.<uint>();
			this._surf.getVertexVector(Surface3D.POSITION).push(-1, 1, 0, 1, 1, 0, -1, -1, 0, 1, -1, 0);
			this._surf.getVertexVector(Surface3D.UV0).push(0, 0, 1, 0, 0, 1, 1, 1);
			this._surf.indexVector.push(0, 1, 2, 3, 2, 1);
			this.surfaces.push(this._surf);
			this.setTo(x, y, width, height, fullScreenMode);
		}
		
		public function setTo(x : Number, y : Number, width : Number, height : Number, fullScreenMode : Boolean = false) : void {
			this._x = x;
			this._y = y;
			this._width = width;
			this._height = height;
			this.fullScreenMode = fullScreenMode;
		}
		
		override public function draw(scene:Scene3D, material:Material3D):void {
			var x : Number = 0;
			var y : Number = 0;
			var w : Number = 0;
			var h : Number = 0;
			var v : Rectangle = scene.viewPort;
			x = this._x / v.width;
			y = this._y / v.height;
			w = this._width / v.width;
			h = this._height / v.height;
			if (this.fullScreenMode) {
				w = 1 - x - w;
				h = 1 - y - h;
			}
			object3D.transform.local.identity();
			object3D.transform.local.appendScale(w, h, 1);
			object3D.transform.local.appendTranslation((-1 + w + x * 2), (1 - h - y * 2), 0);
			Device3D.mvp.copyFrom(object3D.transform.local);
			super.draw(scene, material);
		}
	}
}
