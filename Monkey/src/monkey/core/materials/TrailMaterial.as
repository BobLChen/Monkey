package monkey.core.materials {
	
	import monkey.core.materials.shader.TrailShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;

	/**
	 * 条带材质 
	 * @author Neil
	 * 
	 */	
	public class TrailMaterial extends DiffuseMaterial {
		
		public function TrailMaterial(texture : Texture3D) {
			super(texture);
			this._shader = TrailShader.instance;
		}
		
		override public function updateMaterial(scene:Scene3D):void {
			TrailShader(shader).texture = this.texture;	
			TrailShader(shader).tillingOffset(repeatX, repeatY, offsetX, offsetY);
		}
		
	}
}
