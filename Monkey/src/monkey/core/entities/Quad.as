package monkey.core.entities {
	
	import flash.geom.Rectangle;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.Material3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	
	public class Quad extends Object3D {
		
		public var fullScreen 	: Boolean = true;
		
		private var _x 			: Number;
		private var _y 			: Number;
		private var _width 		: Number;
		private var _height 	: Number;
		private var _mesh		: Mesh3D;
		private var _surf 		: Surface3D;
		private var _renderer	: MeshRenderer;
		
		public function Quad(x : Number = 0, y : Number = 0, width : Number = 100, height : Number = 100, fullScreenMode : Boolean = false) {
			this._surf = new Surface3D();
			this._surf.setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
			this._surf.setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
			this._surf.indexVector = new Vector.<uint>();
			this._surf.getVertexVector(Surface3D.POSITION).push(-1, 1, 0, 1, 1, 0, -1, -1, 0, 1, -1, 0);
			this._surf.getVertexVector(Surface3D.UV0).push(0, 0, 1, 0, 0, 1, 1, 1);
			this._surf.indexVector.push(0, 1, 2, 3, 2, 1);
			this._mesh = new Mesh3D([this._surf]);
			this._renderer = new MeshRenderer(this._mesh, null);
			this.addComponent(this._renderer);
			this.setTo(x, y, width, height, fullScreenMode);
		}
				
		public function set material(material : Material3D) : void {
			this.renderer.material = material;				
		}
		
		public function get material() : Material3D {
			return this.renderer.material;
		}
				
		public function setTo(x : Number, y : Number, width : Number, height : Number, fullScreenMode : Boolean = false) : void {
			this._x = x;
			this._y = y;
			this._width = width;
			this._height = height;
			this.fullScreen = fullScreenMode;
		}
		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (!visible) {
				return;
			}
			
			if (hasEventListener(ENTER_DRAW_EVENT)) {
				this.dispatchEvent(enterDrawEvent);
			}
			
			var x : Number = 0;
			var y : Number = 0;
			var w : Number = 0;
			var h : Number = 0;
			var v : Rectangle = scene.viewPort;
			x = this._x / v.width;
			y = this._y / v.height;
			w = this._width / v.width;
			h = this._height / v.height;
			if (this.fullScreen) {
				w = 1 - x - w;
				h = 1 - y - h;
			}
			
			this.transform.local.identity();
			this.transform.local.appendScale(w, h, 1);
			this.transform.local.appendTranslation((-1 + w + x * 2), (1 - h - y * 2), 0);
			
			Device3D.world.copyFrom(transform.world);
			Device3D.mvp.copyFrom(this.transform.local);
			Device3D.drawOBJNum++;
						
			for each (var icom : IComponent in components) {
				if (icom.enable) {
					icom.onDraw(scene);
				}
			}
			
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.draw(scene, includeChildren);
				}
			}
			
			if (hasEventListener(EXIT_DRAW_EVENT)) {
				this.dispatchEvent(exitDrawEvent);
			}
		}
		
	}
}
