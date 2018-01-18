package monkey.core.entities {
	
	import monkey.core.base.Object3D;
	import monkey.core.light.DirectionalLight;
	import monkey.core.light.Light3D;
	import monkey.core.light.PointLight;
	import monkey.core.scene.Scene3D;
	
	public class DebugLight extends Object3D {
		
		private var _pointLine		: Lines3D;
		private var _directionLine 	: Lines3D;
		private var _color 			: uint;
		private var _alpha 			: Number;
		private var _light 			: Light3D;
		
		public function DebugLight(light : Light3D, color : uint = 0xffcb00, alpha : Number = 1) {
			super();
			this._pointLine     = new Lines3D();
			this._directionLine = new Lines3D();
			this._light = light;
			this._alpha = alpha;
			this._color = color;
			this.initDirectionLine();
			this.initPointLine();
			this.setLayer(1000);
		}
		
		public function get light():Light3D {
			return _light;
		}
		
		public function set light(value:Light3D):void {
			_light = value;
		}
		
		/**
		 * 初始化点光线框 
		 * 
		 */		
		private function initPointLine() : void {
			
			var one : Number = 1;
			
			this._pointLine.lineStyle(1, this._color, this._alpha);
			this._pointLine.moveTo(Math.cos(0) * one, 0, Math.sin(0) * one);
			
			var seg : Number = Math.PI * 2 / 24;
			var i 	: Number = seg;
			
			while (i <= (Math.PI * 2 + seg)) {
				this._pointLine.lineTo(Math.cos(i) * one, 0, Math.sin(i) * one);
				i += seg;
			}
			
			this._pointLine.moveTo(0, Math.cos(0) * one, Math.sin(0) * one);
			i = seg;
			
			while (i <= (Math.PI * 2 + seg)) {
				this._pointLine.lineTo(0, Math.cos(i) * one, Math.sin(i) * one);
				i += seg;
			}
			
			this._pointLine.moveTo(Math.cos(0) * one, Math.sin(0) * one, 0);
			i = seg;
			
			while (i <= (Math.PI * 2 + seg)) {
				this._pointLine.lineTo(Math.cos(i) * one, Math.sin(i) * one, 0);
				i += seg;
			}
			
		}
		
		/**
		 *  初始化平行光线框
		 */		
		private function initDirectionLine() : void {
			this._directionLine.lineStyle(1, this._color, this._alpha);
			this._directionLine.moveTo(-20, -20, 0);
			this._directionLine.lineTo(-20, 20, 0);
			this._directionLine.lineTo(20, 20, 0);
			this._directionLine.lineTo(20, -20, 0);
			this._directionLine.lineTo(-20, -20, 0);
			this._directionLine.moveTo(0, 0, 0);
			this._directionLine.lineTo(0, 0, 20);
			this._directionLine.moveTo(-8, 0, 20);
			this._directionLine.lineTo(8, 0, 20);
			this._directionLine.lineTo(0, 0, 30);
			this._directionLine.lineTo(-8, 0, 20);
		}
		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			super.draw(scene, includeChildren);
			if (this._light is DirectionalLight) {
				this._directionLine.transform.local.copyFrom(_light.transform.world);
				this._directionLine.draw(scene, includeChildren);
			} else if (this._light is PointLight) {
				this._pointLine.transform.local.copyFrom(_light.transform.world);
				this._pointLine.transform.setScale(PointLight(_light).radius, PointLight(_light).radius, PointLight(_light).radius);
				this._pointLine.draw(scene, includeChildren);
			}
		}
	}
}
