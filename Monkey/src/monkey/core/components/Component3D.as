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
		public static const ENABLE 			: String = "Component3D:ENABLE";
		/** disable */
		public static const DISABLE 		: String = "Component3D:DISABLE";
		// 事件
		private static const enableEvent    : Event = new Event(ENABLE);
		private static const disableEvent   : Event = new Event(DISABLE);
		
		private var _object3D : Object3D;	// object3d
		private var _enable   : Boolean;	// 是否启用
		private var _disposed : Boolean;	// 是否被摧毁
		
		public function Component3D() {
			super();
			this._enable = true;
		}
		
		public function copyfrom(icom : Component3D) : void {
			this._enable   = icom.enable;
			this._disposed = icom.disposed;
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
			if (value && hasEventListener(ENABLE)) {
				this.dispatchEvent(enableEvent);
			} else if (hasEventListener(DISABLE)) {
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
		public function dispose() : void {
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
