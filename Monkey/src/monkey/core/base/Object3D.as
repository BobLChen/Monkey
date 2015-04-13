package monkey.core.base {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import monkey.core.animator.Animator;
	import monkey.core.camera.Camera3D;
	import monkey.core.components.Transform3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Matrix3DUtils;
	import monkey.core.utils.Vector3DUtils;
	
	/**
	 * object3D 
	 * @author Neil
	 * 
	 */	
	public class Object3D extends EventDispatcher {
		
		// -------------------------------- 事件定义 --------------------------------
		/** 开始绘制 */
		public static const ENTER_FRAME_EVENT 		: String = "Object3D:ENTER_FRAME_EVENT";
		/** 结束绘制 */
		public static const EXIT_FRAME_EVENT 		: String = "Object3D:EXIT_FRAME_EVENT";
		/** 进入帧循环 */
		public static const ENTER_DRAW_EVENT		: String = "Object3D:ENTER_DRAW_EVENT";
		/** 退出帧循环 */
		public static const EXIT_DRAW_EVENT			: String = "Object3D:EXIT_DRAW_EVENT";
		/** 添加一个子节点 */
		public static const ADD_CHILD_EVENT			: String = "Object3D:ADD_CHILD_EVENT";
		/** 移除一个子节点 */
		public static const REMOVE_CHILD_EVENT		: String = "Object3D:REMOVE_CHILD_EVENT";
		/** 被添加 */
		public static const ADDED_EVENT				: String = "Object3D:ADDED_EVENT";
		/** 添加到场景 */
		public static const ADDED_TO_SCENE_EVENT	: String = "Object3D:ADDED_INTO_SCENE_EVENT";
		/** 被移除 */
		public static const REMOVED_EVENT			: String = "Object3D:REMOVED_EVENT";
		/** 被移除 */
		public static const REMOVED_FROM_SCENE_EVENN: String = "Object3D:REMOVED_FROM_SCENE_EVENN";
		/** 被销毁 */
		public static const DISPOSE_EVENT			: String = "Object3D:DISPOSE_EVENT";
		
		// -------------------------------- 所有事件 --------------------------------
		protected static const enterDrawEvent 	: Event = new Event(ENTER_DRAW_EVENT);
		protected static const exitDrawEvent  	: Event = new Event(EXIT_DRAW_EVENT);
		protected static const enterFrameEvent	: Event = new Event(ENTER_FRAME_EVENT);
		protected static const exitFrameEvent	: Event = new Event(EXIT_FRAME_EVENT);
		protected static const addChildEvent	: Event = new Event(ADD_CHILD_EVENT);
		protected static const removeChildEvent	: Event = new Event(REMOVE_CHILD_EVENT);
		protected static const addedEvent		: Event = new Event(ADDED_EVENT);
		protected static const addedToSceneEvent: Event = new Event(ADDED_TO_SCENE_EVENT);
		protected static const removedEvent		: Event = new Event(REMOVED_EVENT);
		protected static const disposedEvent	: Event = new Event(DISPOSE_EVENT);
		protected static const removedFromSceneEvent : Event = new Event(REMOVED_FROM_SCENE_EVENN);
		
		/** 名称 */
		public var name 	: String = "";
		public var userData : Object;
		
		protected var _layer		: int;							// 层级
		protected var _scene		: Scene3D;						// 所在场景
		protected var _components 	: Vector.<IComponent>;			// 所有组件
		protected var _children   	: Vector.<Object3D>;			// 子节点
		protected var _parent		: Object3D;						// 父级
		protected var _visible		: Boolean;						// 是否显示
		protected var _disposed		: Boolean;						// 是否已经被销毁
		protected var componentDict : Dictionary;					// 组件字典，懒汉模式
						
		public function Object3D() {
			super();
			this.userData	   = new Object();
			this.visible	   = true;
			this.componentDict = new Dictionary();
			this._components   = new Vector.<IComponent>();
			this._children	   = new Vector.<Object3D>();
			this.addComponent(new Transform3D());
		}
		
		public function gotoAndStop(frame : Object, includeChildren : Boolean = true) : void {
			if (animator) {
				animator.gotoAndStop(frame);
			}
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.gotoAndStop(frame, includeChildren);
				}
			}
		}
		
		public function gotoAndPlay(frame : Object, animationMode : int = Animator.ANIMATION_LOOP_MODE, includeChildren : Boolean = true) : void {
			if (animator) {
				animator.gotoAndPlay(frame, animationMode);
			}
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.gotoAndPlay(frame, animationMode, includeChildren);
				}
			}
		}
		
		public function play(animationMode : int = Animator.ANIMATION_STOP_MODE, includeChildren : Boolean = true) : void {
			if (animator) {
				animator.play(animationMode);
			}
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.play(animationMode, includeChildren);
				}
			}
		}
		
		public function stop(includeChildren : Boolean = true) : void {
			if (animator) {
				animator.stop();
			}
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.stop(includeChildren);
				}
			}
		}
		
		public function get renderer() : MeshRenderer {
			return this.getComponent(MeshRenderer) as MeshRenderer;
		}
		
		public function get animator() : Animator {
			return this.getComponent(Animator) as Animator;
		}
		
		public function get layer():int {
			return _layer;
		}
		
		/**
		 * 设置层级 
		 * @param value
		 * @param includeChildren
		 * 
		 */		
		public function setLayer(value:int, includeChildren : Boolean = true):void {
			if (this._scene && value != _layer) {
				this._scene.removeFromScene(this);
				this._layer = value;
				this._scene.addToScene(this);
			} else {
				this._layer = value;
			}
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.setLayer(value, includeChildren);
				}
			}
		}
				
		public function get visible():Boolean {
			return _visible;
		}
		
		public function set visible(value:Boolean):void {
			if (value == _visible) {
				return;
			}
			_visible = value;
			for each (var child : Object3D in children) {
				child.visible = value;
			}
		}
		
		/**
		 * 添加一个child 
		 * @param child
		 * 
		 */		
		public function addChild(child : Object3D) : void {
			if (child) {
				child.parent = this;
			}
		}
		
		/**
		 * 移除child 
		 * @param child
		 * 
		 */		
		public function removeChild(child : Object3D) : void {
			if (child) {
				child.parent = null;
			}
		}
		
		/**
		 * 父级 
		 * @return 
		 * 
		 */		
		public function get parent() : Object3D {
			return _parent;
		}
		
		public function set parent(pivot : Object3D) : void {
			if (pivot == this._parent) {
				return;
			}
			// 有父节点
			if (this._parent) {
				var idx : int = this._parent.children.indexOf(this);
				if (idx != -1) {
					this._parent.children.splice(idx, 1);
					this._parent.dispatchEvent(removeChildEvent);
					this.dispatchEvent(removedEvent);
				}
			}
			this._parent = pivot;
			// 父节点存在
			if (this._parent) {
				this._parent.children.push(this);
				this._parent.dispatchEvent(addChildEvent);
				this.transform.updateTransforms(true);
				this.dispatchEvent(addedEvent);
			}
			// 未处于场景中
			if (!this._scene) {
				if (pivot) {
					if (pivot is Scene3D) {			// 父节点为场景
						this.addedToScene(pivot as Scene3D);
					} else if (pivot.scene) {		// 父节点在场景中
						this.addedToScene(pivot.scene);
					}
				}
			} else {
				// 已经处于场景中
				if (!pivot) {												// 父节点为null, 从场景中移除
					this.removedFromScene();	
				} else if (!(pivot is Scene3D) && !pivot.scene) {			// 父节点未处于场景中, 从场景中移除
					this.removedFromScene();
				}
			}
			
		}
		
		/**
		 * 从场景中移除 
		 * 
		 */		
		private function removedFromScene() : void {
			this._scene.removeFromScene(this);
			this._scene = null;
			this.dispatchEvent(removedFromSceneEvent);
			for each (var child : Object3D in children) {
				child.removedFromScene();
			}
		}
		
		/**
		 * 添加到场景 
		 * @param scene
		 * 
		 */		
		private function addedToScene(scene : Scene3D) : void {
			this._scene = scene;
			this._scene.addToScene(this);
			this.dispatchEvent(addedToSceneEvent);
			for each (var child : Object3D in children) {
				child.addedToScene(scene);
			}
		}
		
		public function get scene() : Scene3D {
			return _scene;
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
			return getComponent(Transform3D) as Transform3D;
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
		 * 移除除Transform3D组件以外所有组件 
		 */		
		public function removeAllComponents() : void {
			while (components.length) {
				this.removeComponent(components[0]);
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
			
			if (hasEventListener(ENTER_FRAME_EVENT)) {
				this.dispatchEvent(enterFrameEvent);
			}
			
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
			
			if (hasEventListener(EXIT_FRAME_EVENT)) {
				this.dispatchEvent(exitFrameEvent);
			}
			
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
			
			if (hasEventListener(ENTER_DRAW_EVENT)) {
				this.dispatchEvent(enterDrawEvent);
			}
			
			Device3D.world.copyFrom(transform.world);
			Device3D.mvp.copyFrom(Device3D.world);
			Device3D.mvp.append(Device3D.viewProjection);
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
		
		/**
		 * 遍历所有对象 
		 * @param callback
		 * @param clazz
		 * @param params
		 * @param includeChildren
		 * 
		 */		
		public function forEach(callback : Function, clazz : Class = null, params : Object = null, includeChildren : Boolean = true) : void {
			for each (var child : Object3D in children) {
				if (!clazz) {
					if (params) {
						callback(child, params);
					} else {
						callback(child);
					}
				} else if (child is clazz) {
					if (params) {
						callback(child, params);
					} else {
						callback(child);
					}
				}
				if (includeChildren) {
					child.forEach(callback, clazz, params, includeChildren);
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
		public function dispose(force : Boolean = false) : void {
			if (this.disposed) {
				return;
			}
			if (this.parent) {
				this.parent.removeChild(this);
			}
			this._disposed = true;
			for each (var icom : IComponent in components) {
				icom.dispose(force);
			}
			while (children.length > 0) {
				children[0].dispose(force);
			}
			if (hasEventListener(DISPOSE_EVENT)) {
				this.dispatchEvent(disposedEvent);
			}
		}
		
		public function inView() : Boolean {
			var vec : Vector3D = Vector3DUtils.vec0;
			this.transform.getPosition(false, vec);
			Matrix3DUtils.transformVector(Device3D.camera.view, vec, vec);
			if (vec.z < Device3D.camera.near || vec.z > Device3D.camera.far) {
				return false;
			}
			return true;
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
				c.addChild(child.clone());
			}
			c._layer = this._layer;
			return c;
		}
	}
}
