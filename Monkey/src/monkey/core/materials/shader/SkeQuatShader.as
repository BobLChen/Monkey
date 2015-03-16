package monkey.core.materials.shader {

	import flash.utils.ByteArray;
	
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.SkeletonFilterQuat;

	/**
	 * 四元数骨骼shader 
	 * @author Neil
	 * 
	 */	
	public class SkeQuatShader extends Shader3D {
		
		private var filter : SkeletonFilterQuat;
		
		public function SkeQuatShader() {
			super([]);
			this.filter = new SkeletonFilterQuat();
			this.addFilter(filter);
		}
		
		public function set boneData(bytes : ByteArray) : void {
			this.filter.boneData = bytes;
		}
		
	}
}
