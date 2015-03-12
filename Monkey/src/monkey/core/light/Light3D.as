package monkey.core.light {

	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.utils.Color;
	
	/**
	 * 灯光 
	 * @author Neil
	 * 
	 */	
	public class Light3D extends Object3D {
		
		private var _color 		: Color;
		private var _ambient	: Color;
		private var _intensity 	: Number;
		
		public function Light3D() {
			super();
			this.color 		= new Color(0xffffff);
			this.ambient	= new Color(0x333333);
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
				c.addChild(child.clone());
			}
			return c;
		}
		
		public function get ambient() : Color {
			return _ambient;
		}
		
		/**
		 * 环境光 
		 * @param value
		 * 
		 */		
		public function set ambient(value : Color) : void {
			this._ambient = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 灯光颜色
		 * @return
		 *
		 */
		public function get color() : Color {
			return _color;
		}
		
		/**
		 * 灯光颜色
		 * @param value
		 *
		 */
		public function set color(value : Color) : void {
			this._color = value;
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
