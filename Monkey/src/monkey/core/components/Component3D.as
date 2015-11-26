package monkey.core.components {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import monkey.core.base.Object3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.scene.Scene3D;
	
	/**
	 * 组件 
	 * @author Neil
	 * 
	 */	
	public class Component3D extends EventDispatcher implements IComponent {
		
		/** 启用组件 */
		public static const ENABLE_EVENT 	: String = "Component3D:ENABLE";
		/** disable */
		public static const DISABLE_EVENT   : String = "Component3D:DISABLE";
		/** 添加到object */
		public static const ADD_EVENT		: String = "Component3D:ADD";
		/** 从object中移除 */
		public static const REMOVE_EVENT	: String = "Component3D:REMOVE";
		
		// 事件
		private static const enableEvent    : Event = new Event(ENABLE_EVENT);
		private static const disableEvent   : Event = new Event(DISABLE_EVENT);
		private static const addEvent		: Event = new Event(ADD_EVENT);
		private static const removeEvent	: Event = new Event(REMOVE_EVENT);
		
		protected var _object3D : Object3D;	// object3d
		protected var _enable   : Boolean;	// 是否启用
		protected var _disposed : Boolean;	// 是否被摧毁
		
		public function Component3D() {
			super();
			this._enable = true;
		}
		
		/**
		 * master 
		 * @return 
		 * 
		 */		
		public function get object3D():Object3D {
			return _object3D;
		}
		
		/**
		 * 被添加到object3d 
		 * @param master
		 * 
		 */		
		public function onAdd(master : Object3D) : void {
			this._object3D = master;
			if (this.hasEventListener(ADD_EVENT)) {
				this.dispatchEvent(addEvent);
			}
		}
		
		/**
		 * object3d添加了其它组件 
		 * @param component
		 * 
		 */		
		public function onOtherComponentAdd(component : IComponent) : void {
			
		}
		
		/**
		 * object3d移除了其它组件 
		 * @param component
		 * 
		 */		
 		public function onOtherComponentRemove(component : IComponent) : void {
			
		}

		/**
		 * 组件被移除 
		 * @param master
		 * 
		 */		
		public function onRemove(master : Object3D) : void {
			this._object3D = null;
			if (this.hasEventListener(REMOVE_EVENT)) {
				this.dispatchEvent(removeEvent);
			}
		}
		
		/**
		 * 进入帧循环 
		 * 
		 */		
		public function onUpdate() : void {
			
		}
		
		/**
		 * 开始绘制 
		 * @param scene
		 * 
		 */		
		public function onDraw(scene : Scene3D) : void {
			
		}
		
		/**
		 * 开/关组件 
		 * @param value
		 * 
		 */		
		public function set enable(value : Boolean) : void {
			if (enable == value) {
				return;
			}
			this._enable = value;
			if (value && hasEventListener(ENABLE_EVENT)) {
				this.dispatchEvent(enableEvent);
			} else if (hasEventListener(DISABLE_EVENT)) {
				this.dispatchEvent(disableEvent);
			}
		}
		
		/**
		 * 是否启用 
		 * @return 
		 */		
		public function get enable() : Boolean {
			return _enable;
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		public function clone() : IComponent {
			var c : Component3D = new Component3D();
			return c;
		}
		
		/**
		 * 销毁 
		 * 
		 */		
		public function dispose(force : Boolean = false) : void {
			this._disposed = true;
		}
		
		/**
		 * 是否被摧毁 
		 * @return 
		 * 
		 */		
		public function get disposed() : Boolean {
			return _disposed ;
		}

	}
}
