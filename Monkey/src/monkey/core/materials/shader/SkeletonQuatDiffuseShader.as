package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.SkeletonFilterQuat;

	/**
	 * 四元数骨骼动画shader 
	 * @author Neil
	 * 
	 */	
	public class SkeletonQuatDiffuseShader extends Shader3D {
		
		private var filter : SkeletonFilterQuat;
		
		public function SkeletonQuatDiffuseShader() {
			super([]);
		}
		
	}
}
