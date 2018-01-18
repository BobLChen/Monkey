package monkey.core.materials.shader {

	import flash.geom.Vector3D;
	
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.TextureMapFilter;
	import monkey.core.shader.filters.UnityLightmapFilter;
	import monkey.core.textures.Texture3D;
	
	/**
	 * Unity3D lightmap diffuse shader 
	 * @author Neil
	 * 
	 */	
	public class UnityLightmapDiffuseShader extends Shader3D {
		
		private static var _instance : UnityLightmapDiffuseShader;
		
		private var _textureFilter  : TextureMapFilter;
		private var _lightmapFilter : UnityLightmapFilter;
		
		public function UnityLightmapDiffuseShader() {
			super([]);
			this._textureFilter  = new TextureMapFilter(null);
			this._lightmapFilter = new UnityLightmapFilter();
			this.addFilter(this._textureFilter);
			this.addFilter(this._lightmapFilter);
		}
		
		public static function get instance():UnityLightmapDiffuseShader {
			if (!_instance) {
				_instance = new UnityLightmapDiffuseShader();
			}
			return _instance;
		}

		/**
		 * 强度 
		 * @param value
		 * 
		 */		
		public function set intensity(value : Number) : void {
			this._lightmapFilter.intensity = value;
		}
		
		/**
		 * 普通材质贴图 
		 * @param value
		 * 
		 */		
		public function set texture(value : Texture3D) : void {
			this._textureFilter.texture = value;
		}
		
		/**
		 * 光照贴图 
		 * @param value
		 * 
		 */		
		public function set lightmap(value : Texture3D) : void {
			this._lightmapFilter.texture = value;
		}
		
		/**
		 * 缩放以及偏移量 
		 * @param value
		 * 
		 */		
		public function set tillingOffset(value:Vector3D):void {
			this._lightmapFilter.tilingOffset = value;
		}

	}
}
