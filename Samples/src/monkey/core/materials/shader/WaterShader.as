package monkey.core.materials.shader {

	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.WaveFilter;
	import monkey.core.textures.CubeTextue3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Color;
	
	/**
	 * 水波shader 
	 * @author Neil
	 * 
	 */	
	public class WaterShader extends Shader3D {
		
		private static var _instance : WaterShader;
		
		private var waterFilter : WaveFilter;
		
		public function WaterShader() {
			super([]);
			if (_instance) {
				throw new Error("single ton...");
			}
			this.waterFilter = new WaveFilter();
			this.addFilter(waterFilter);
		}
				
		public function set normalTexture(texture : Texture3D) : void {
			this.waterFilter.normalTexture = texture;
		}
		
		public function set cubeTexture(textue : CubeTextue3D) : void {
			this.waterFilter.cubeTexture = textue;
		}
		
		public function set waterWave(value : Number) : void {
			this.waterFilter.waterWave = value;
		}
		
		public function set waveHeight(value : Number) : void {
			this.waterFilter.waveHeight = value;
		}
		
		public function set blendColor(value : Color) : void {
			this.waterFilter.blendColor = value;
		}
		
		public static function get instance() : WaterShader {
			if (!_instance) {
				_instance = new WaterShader();
			}
			return _instance;
		}
		
	}
}
