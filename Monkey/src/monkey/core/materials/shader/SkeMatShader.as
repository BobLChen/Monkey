package monkey.core.materials.shader {

	import flash.utils.ByteArray;
	
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.SkeletonFilter34;
	
	/**
	 * 矩阵骨骼shader 
	 * @author Neil
	 * 
	 */	
	public class SkeMatShader extends Shader3D {
		
		private var filter : SkeletonFilter34;
		
		public function SkeMatShader() {
			super([]);
			this.filter = new SkeletonFilter34();
			this.addFilter(filter);
		}
		
		public function set boneData(bytes : ByteArray) : void {
			this.filter.boneData = bytes;
		}
		
	}
}
