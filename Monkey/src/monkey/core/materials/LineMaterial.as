package monkey.core.materials {

	import monkey.core.materials.shader.LineShader;
		
	/**
	 * 线材质 
	 * @author Neil
	 * 
	 */	
	public class LineMaterial extends Material3D {
		
		public function LineMaterial() {
			super();
			this._shader = LineShader.instance;
			this.blendMode = BLEND_ALPHA;
		}
				
	}
}
