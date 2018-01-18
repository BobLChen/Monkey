package monkey.core.components {
	
	import flash.geom.Matrix3D;
	
	import monkey.core.animator.SkeletonAnimator;
	import monkey.core.base.Object3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.scene.Scene3D;

	/**
	 * @author Neil
	 */	
	public class AvatarComponent extends Component3D {
		
		private var animator : SkeletonAnimator;
		private var tagName   : String;
		private var component : Object3D;
		
		/**
		 * @param name			挂节点骨骼名称
		 * @param component		挂机物体
		 * 
		 */				
		public function AvatarComponent(name : String, component : Object3D) {
			super();
			this.tagName = name;
			this.component = component;
			this.initAvatar();
		}
		
		override public function onOtherComponentAdd(component:IComponent):void {
			super.onOtherComponentAdd(component);
			this.initAvatar();
		}
		
		override public function onOtherComponentRemove(component:IComponent):void {
			super.onOtherComponentRemove(component);
			if (component is SkeletonAnimator) {
				this.animator = null;
			}
		}
		
		override public function onRemove(master:Object3D):void {
			super.onRemove(master);
			if (this.component) {
				this.component.dispose();
				this.component = null;
			}
		}
				
		private function initAvatar() : void {
			if (object3D && object3D.animator && object3D.animator is SkeletonAnimator) {
				this.animator = object3D.animator as SkeletonAnimator;
				this.object3D.addChild(this.component);
			}
		}
		
		override public function onDraw(scene:Scene3D):void {
			if (!this.animator || !this.component) {
				return;
			}
			var mt : Matrix3D = this.animator.getMountMatrix(tagName, this.animator.currentFrame);
			this.component.transform.local.copyFrom(mt);
			this.component.transform.updateTransforms(true);
		}
				
	}
}
