package monkey.core.interfaces {
	
	import monkey.core.base.Object3D;
	import monkey.core.scene.Scene3D;

	public interface IComponent {
		
		/**
		 * 被添加到Object3D 
		 * @param master	宿主
		 * 
		 */		
		function onAdd(master : Object3D) : void;
		
		/**
		 * 被移除 
		 * @param master	宿主
		 * 
		 */		
		function onRemove(master : Object3D) : void;
		
		/**
		 * 其他组件被添加到master 
		 * @param component	新添加的组件	
		 * 
		 */		
		function onOtherComponentAdd(component : IComponent) : void;
		
		/**
		 * 其他组件被移除 
		 * @param component 被移除的组件
		 * 
		 */		
		function onOtherComponentRemove(component : IComponent) : void;
		
		/**
		 * 进入帧循环
		 */
		function onUpdate() : void;
		
		/**
		 * 绘制
		 */
		function onDraw(scene : Scene3D) : void;
				
		/**
		 * 开/关组件 
		 * @param value
		 * 
		 */		
		function set enable(value : Boolean) : void;
		
		/**
		 * 是否启用 
		 * @return 
		 */		
		function get enable() : Boolean;
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		function clone() : IComponent;
		
		/**
		 * 销毁 
		 */		
		function dispose() : void;
		
		/**
		 * 是否已经被销毁 
		 * @return 
		 * 
		 */		
		function get disposed() : Boolean;
	}
	
}
