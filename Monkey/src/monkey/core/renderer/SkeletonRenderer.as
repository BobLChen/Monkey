package monkey.core.renderer {

	import monkey.core.animator.SkeletonAnimator;
	import monkey.core.entities.Mesh3D;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.Material3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	
	/**
	 * 骨骼动画渲染器 
	 * @author Neil
	 * 
	 */	
	public class SkeletonRenderer extends MeshRenderer {
		
		public function SkeletonRenderer(mesh : Mesh3D, material : Material3D) {
			super(mesh, material);
		}
		
		override public function clone():IComponent {
			var c : SkeletonRenderer = new SkeletonRenderer(mesh.clone(), material.clone());
			return c;
		}
		
		override public function onDraw(scene:Scene3D):void {
			var animator : SkeletonAnimator = object3D.animator as SkeletonAnimator;
			if (!material || !mesh || !animator) {
				return;
			}
			if (!inView) {
				return;
			}
			for (var i:int = 0; i < mesh.surfaces.length; i++) {
				Device3D.BoneMatrixs = animator.getBoneBytes(i, animator.currentFrame % animator.totalFrames);
				material.updateMaterial(scene);
				material.draw(scene, mesh.surfaces[i]);
			}
		}
				
	}
}
