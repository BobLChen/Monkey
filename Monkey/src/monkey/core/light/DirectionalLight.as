package monkey.core.light {
	
	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.utils.Color;

	public class DirectionalLight extends Light3D {
		
		private var _specular : Color;
		private var _power 	  : Number;
		
		public function DirectionalLight() {
			super();
			this.specular = new Color(0x333333);
			this.power    = 50;
		}
		
		override public function clone():Object3D {
			var c : DirectionalLight = new DirectionalLight();
			c.color 	= color;
			c.ambient 	= ambient;
			c.specular 	= specular;
			c.power 	= power;
			c.intensity = intensity;
			for each (var icom : IComponent in components) {
				c.addComponent(icom.clone());
			}
			for each (var child : Object3D in children) {
				c.addChild(child.clone());
			}
			return c;
		}
		
		public function get power():Number {
			return _power;
		}
		
		public function set power(value:Number):void {
			this._power = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get specular():Color {
			return _specular;
		}
		
		public function set specular(value:Color):void {
			this._specular = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
