package monkey.core.light {

	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.interfaces.IComponent;
	
	/**
	 * 灯光 
	 * @author Neil
	 * 
	 */	
	public class Light3D extends Object3D {
		
		private var _color 		: uint;
		private var _ambient	: uint;
		private var _intensity 	: Number;
		
		public function Light3D() {
			super();
			this.color 		= 0xffffff;
			this.ambient	= 0x333333;
			this.intensity 	= 1;
		}
		
		public function get intensity():Number {
			return _intensity;
		}
		
		/**
		 * 灯光强度 
		 * @param value
		 * 
		 */		
		public function set intensity(value:Number):void {
			this._intensity = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
				
		override public function clone():Object3D {
			var c : Light3D = new Light3D();
			c.color = color;
			c.ambient = ambient;
			for each (var icom : IComponent in components) {
				c.addComponent(icom.clone());
			}
			for each (var child : Object3D in children) {
				c.children.push(child.clone());
			}
			return c;
		}
		
		public function get ambient() : uint {
			return _ambient;
		}
		
		/**
		 * 环境光 
		 * @param value
		 * 
		 */		
		public function set ambient(value : uint) : void {
			this._ambient = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 灯光颜色
		 * @return
		 *
		 */
		public function get color() : uint {
			return _color;
		}
		
		/**
		 * 灯光颜色
		 * @param value
		 *
		 */
		public function set color(value : uint) : void {
			this._color = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
