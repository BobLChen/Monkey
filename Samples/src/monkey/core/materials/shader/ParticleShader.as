package monkey.core.materials.shader {

	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.ParticleSystemFilter;
	import monkey.core.textures.Texture3D;

	/**
	 * 单例模式 
	 * 粒子系统shader
	 * @author Neil
	 * 
	 */	
	public class ParticleShader extends Shader3D {
		
		private static var _instance : ParticleShader;
		
		private var filter : ParticleSystemFilter;
				
		public function ParticleShader() {
			super([]);
			if (_instance) {
				throw new Error("ParticleShader为单例模式");
			}
			this.filter = new ParticleSystemFilter();
			this.addFilter(filter);
		}
		
		public static function get instance() : ParticleShader {
			if (!_instance) {
				_instance = new ParticleShader();
			}
			return _instance;
		}
		
		public function set frame(value : Point) : void {
			this.filter.frame = value;
		}
		
		public function set time(value : Number) : void {
			this.filter.time = value;
		}
		
		public function set totalLife(value : Number) : void {
			this.filter.totalLife = value;
		}
		
		public function set billboard(value : Boolean) : void {
			this.filter.billboard = value;
		} 
		
		public function get billboard() : Boolean {
			return this.filter.billboard;
		}
		
		/**
		 * 贴图 
		 * @param value
		 * 
		 */		
		public function set texture(value : Texture3D) : void {
			this.filter.texture = value;
		}
		
		/**
		 * color over lifetime 
		 * @param value
		 * 
		 */		 
		public function set blendTexture(value : Texture3D) : void {
			this.filter.blendTexture = value;
		}
		
		/**
		 * 关键帧 
		 * @param value
		 * 
		 */		
		public function set keyframe(value : ByteArray) : void {
			this.filter.keyframe = value;
		}
		
	}
}
