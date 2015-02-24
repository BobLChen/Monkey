package monkey.core.base {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import monkey.core.camera.Camera3D;
	import monkey.core.components.Transform3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	
	/**
	 * object3D 
	 * @author Neil
	 * 
	 */	
	public class Object3D extends EventDispatcher {
		
		// -------------------------------- 事件定义 --------------------------------
		/** 开始绘制 */
		public static const ENTER_FRAME 		: String = "Object3D:ENTER_FRAME";
		/** 结束绘制 */
		public static const EXIT_FRAME 			: String = "Object3D:EXIT_FRAME";
		/** 进入帧循环 */
		public static const ENTER_DRAW			: String = "Object3D:ENTER_DRAW";
		/** 退出帧循环 */
		public static const EXIT_DRAW			: String = "Object3D:EXIT_DRAW";
		/** 添加一个子节点 */
		public static const ADD_CHILD			: String = "Object3D:ADD_CHILD";
		/** 移除一个子节点 */
		public static const REMOVE_CHILD		: String = "Object3D:REMOVE_CHILD";
		/** 被添加 */
		public static const ADDED				: String = "Object3D:ADDED";
		/** 被移除 */
		public static const REMOVED				: String = "Object3D:REMOVED";
		
		// -------------------------------- 所有事件 --------------------------------
		private static const enterDrawEvent 	: Event = new Event(ENTER_DRAW);
		private static const exitDrawEvent  	: Event = new Event(EXIT_DRAW);
		private static const enterFrameEvent	: Event = new Event(ENTER_FRAME);
		private static const exitFrameEvent		: Event = new Event(EXIT_FRAME);
		private static const addChildEvent		: Event = new Event(ADD_CHILD);
		private static const removeChildEvent	: Event = new Event(REMOVE_CHILD);
		private static const addedEvent			: Event = new Event(ADDED);
		private static const removedEvent		: Event = new Event(REMOVED);
		
		
		/** 名称 */
		public var name : String = "";
		
		private var _components 	: Vector.<IComponent>;			// 所有组件
		private var _transform  	: Transform3D;					// transform
		private var _children   	: Vector.<Object3D>;			// 子节点
		private var _parent			: Object3D;						// 父级
		private var _visible		: Boolean;						// 是否显示
		private var _disposed		: Boolean;						// 是否已经被销毁
		private var componentDict   : Dictionary;					// 组件字典，懒汉模式
		
		public function Object3D() {
			super();
			this.visible	   = true;
			this.componentDict = new Dictionary();
			this._components   = new Vector.<IComponent>();
			this._transform    = new Transform3D();
			this._children	   = new Vector.<Object3D>();
			this.addComponent(_transform);
		}
		
		public function get visible():Boolean {
			return _visible;
		}
		
		public function set visible(value:Boolean):void {
			if (value == _visible) {
				return;
			}
			_visible = value;
			for (var child : Object3D in children) {
				child.visible = value;
			}
		}

		/**
		 * 添加一个child 
		 * @param child
		 * 
		 */		
		public function addChild(child : Object3D) : void {
			if (children.indexOf(child) != -1) {
				return;
			}
			child._parent = this;
			child.visible = visible;
			children.push(child);
			child.dispatchEvent(addedEvent);
			this.dispatchEvent(addChildEvent);
		}
		
		/**
		 * 移除child 
		 * @param child
		 * 
		 */		
		public function removeChild(child : Object3D) : void {
			var idx : int = children.indexOf(child);
			if (idx == -1) {
				return;
			}
			children.splice(idx, 1);
			child._parent = null;
			child.dispatchEvent(removedEvent);
			this.dispatchEvent(removeChildEvent);
		}
		
		/**
		 * 父级 
		 * @return 
		 * 
		 */		
		public function get parent() : Object3D {
			return _parent;
		}
		
		/**
		 * 子节点 
		 * @return 
		 * 
		 */		
		public function get children() : Vector.<Object3D> {
			return _children;
		}
		
		/**
		 * transform 
		 * @return 
		 * 
		 */		
		public function get transform() : Transform3D {
			return _transform;
		}
		
		/**
		 * 所有组件 
		 * @return 
		 * 
		 */		
		public function get components() : Vector.<IComponent> {
			return this._components;
		}
		
		/**
		 * 添加组件 
		 * @param com
		 * 
		 */		
		public function addComponent(icom : IComponent) : void {
			if (components.indexOf(icom) != -1) {
				return;
			}
			components.push(icom);
			icom.onAdd(this);
			for each (var c : IComponent in components) {
				c.onOtherComponentAdd(icom);
			}
		}
		
		/**
		 * 移除组件 
		 * @param com
		 * 
		 */		
		public function removeComponent(icom : IComponent) : void {
			var idx : int = components.indexOf(icom);
			if (idx == -1) {
				return;
			}
			components.splice(idx, 1);
			// 从字典中移除
			for (var clazz : Class in componentDict) {
				if (icom is clazz) {
					delete componentDict[clazz];
				}
			}
			icom.onRemove(this);
			for each (var c : IComponent in components) {
				c.onOtherComponentRemove(icom);
			}
		}
		
		/**
		 * 根据类型获取component 
		 * @param clazz	类型
		 * @return 
		 * 
		 */		
		public function getComponent(clazz : Class) : IComponent {
			if (componentDict[clazz]) {
				return componentDict[clazz];
			}
			for each (var icom : IComponent in components) {
				if (icom is clazz) {
					componentDict[clazz] = icom;
					break;
				}
			}
			return componentDict[clazz];
		}
		
		/**
		 * 根据类型获取components，低效率
		 * @param clazz		类型
		 * @param out		结果
		 * @return 			
		 * 
		 */		
		public function getComponents(clazz : Class, out : Vector.<IComponent>) : Vector.<IComponent> {
			if (!out) {
				out = new Vector.<IComponent>();
			}
			for each (var icom : IComponent in components) {
				if (icom is clazz) {
					out.push(icom);
				}
			}
			return out;
		}
		
		/**
		 * 更新 
		 * @param includeChildren
		 * 
		 */		
		public function update(includeChildren : Boolean) : void {
			if (!visible) {
				return;
			}
			this.dispatchEvent(enterFrameEvent);
			for each (var icom : IComponent in components) {
				if (icom.enable) {
					icom.onUpdate();
				}
			}
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.update(includeChildren);
				}
			}
			this.dispatchEvent(exitFrameEvent);
		}
		
		/**
		 * 绘制 
		 * @param includeChildren
		 * @param scene
		 * 
		 */		
		public function draw(scene : Scene3D, includeChildren : Boolean = true) : void {
			if (!visible) {
				return;
			}
			this.dispatchEvent(enterDrawEvent);
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
			this.dispatchEvent(exitDrawEvent);
		}
		
		/**
		 * 遍历所有对象 
		 * @param callback
		 * @param clazz
		 * @param params
		 * @param includeChildren
		 * 
		 */		
		public function forEach(callback : Function, params : Object = null, includeChildren : Boolean = true) : void {
			for each (var child : Object3D in children) {
				if (params) {
					callback(child, params);
				} else {
					callback(child);
				}
				if (includeChildren) {
					child.forEach(callback, params, includeChildren);
				}
			}
		}
		
		/**
		 * 获取屏幕坐标 
		 * @param out
		 * @param camera
		 * @param viewPort
		 * @return 
		 * 
		 */		
		public function getScreenCoords(out : Vector3D = null, camera : Camera3D = null, viewport : Rectangle = null) : Vector3D {
			if (!out) {
				out = new Vector3D();
			}
			if (!camera) {
				camera = Device3D.camera;
			}
			if (!viewport) {
				viewport = Device3D.scene.viewPort;				
			}
			var t  : Vector3D = camera.viewProjection.transformVector(this.transform.getPosition(false, out));
			var w2 : Number = viewport.width  * 0.5;
			var h2 : Number = viewport.height * 0.5;
			out.x = ( t.x / t.w) * w2 + w2 + viewport.x;
			out.y = (-t.y / t.w) * h2 + h2 + viewport.y;
			out.z = t.z;
			out.w = t.w;
			return out;
		}
		
		/**
		 * 是否已经被释放 
		 * @return 
		 * 
		 */		
		public function get disposed() : Boolean {
			return _disposed;
		}
				
		/**
		 * 释放 
		 */		
		public function dispose() : void {
			if (this.parent) {
				this.parent.removeChild(this);
			}
			if (disposed) {
				return;
			}
			this._disposed = true;
			for each (var icom : IComponent in components) {
				icom.dispose();
			}
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		public function clone() : Object3D {
			var c : Object3D = new Object3D();
			for each (var icom : IComponent in components) {
				c.addComponent(icom.clone());
			}
			for each (var child : Object3D in children) {
				c.children.push(child.clone());
			}
			return c;
		}
	}
}
