package monkey.core.scene {

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.utils.Input3D;
	import monkey.core.utils.Vector3DUtils;

	public class Viewer3D extends Scene3D {
		
		public var smooth 	   	: Number;
		public var speedFactor 	: Number;
		
		private var _out 		: Vector3D;
		private var _drag 		: Boolean;
		private var _spinX 		: Number = 0;
		private var _spinY 		: Number = 0;
		private var _spinZ 		: Number = 0;
		
		public function Viewer3D(dispObject : DisplayObject, smooth : Number = 1, speedFactor : Number = 0.5) {
			super(dispObject);
			this._out 		 = new Vector3D();
			this.smooth 	 = smooth;
			this.speedFactor = speedFactor;
			this.addEventListener(Object3D.ENTER_FRAME, updateEvent);
		}
		
		private function updateEvent(event:Event) : void {
			if (Input3D.mouseUp) {
				this._drag = false;
			}
			
			if (this._drag) {
				if (Input3D.keyDown(Input3D.SPACE)) {
					this.camera.transform.translateX((-Input3D.mouseXSpeed * camera.transform.getPosition().length) / 300);
					this.camera.transform.translateY(( Input3D.mouseYSpeed * camera.transform.getPosition().length) / 300);
				} else {
					this._spinX = this._spinX + (Input3D.mouseXSpeed * this.smooth) * this.speedFactor;
					this._spinY = this._spinY + (Input3D.mouseYSpeed * this.smooth) * this.speedFactor;
				}
			}
			
			if (Input3D.delta != 0 && viewPort.contains(Input3D.mouseX, Input3D.mouseY)) {
				this._spinZ = ((((camera.transform.getPosition(false, this._out).length + 0.1) * this.speedFactor) * Input3D.delta) / 20);
			}
			
			this.camera.transform.translateZ(this._spinZ);
			this.camera.transform.rotateY(this._spinX, false, Vector3DUtils.ZERO);
			this.camera.transform.rotateX(this._spinY, true,  Vector3DUtils.ZERO);
			
			this._spinX *= (1 - this.smooth);
			this._spinY *= (1 - this.smooth);
			this._spinZ *= (1 - this.smooth);
			
			if (Input3D.mouseHit && viewPort.contains(Input3D.mouseX, Input3D.mouseY)) {
				this._drag = true;
			}		
		}
		
	}
}
