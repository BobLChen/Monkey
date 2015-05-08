package monkey.core.materials {

	import flash.geom.Vector3D;
	
	import monkey.core.materials.shader.UnityLightmapDiffuseShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;

	/**
	 * Unity Lightmap 材质 
	 * @author Neil
	 * 
	 */	
	public class UnityLightmapDiffuseMaterial extends Material3D {
		
		private var _diffuse  : Texture3D;
		private var _lightmap : Texture3D;
		private var _tilingOffset : Vector3D;
		private var _intensity : Number = 2;
		
		public function UnityLightmapDiffuseMaterial(diffuse : Texture3D, lightmap : Texture3D, tilingOffset : Vector3D) {
			super(UnityLightmapDiffuseShader.instance);
			this.diffuse = diffuse;
			this.lightmap = lightmap;
			this.tilingOffset = tilingOffset;
		}
		
		public function get intensity():Number {
			return _intensity;
		}

		public function set intensity(value:Number):void {
			_intensity = value;
		}

		public function get tilingOffset():Vector3D {
			return _tilingOffset;
		}

		public function set tilingOffset(value:Vector3D):void {
			_tilingOffset = value;
		}

		public function get lightmap():Texture3D {
			return _lightmap;
		}

		public function set lightmap(value:Texture3D):void {
			_lightmap = value;
		}

		public function get diffuse():Texture3D {
			return _diffuse;
		}

		public function set diffuse(value:Texture3D):void {
			_diffuse = value;
		}
		
		override public function updateMaterial(scene:Scene3D):void {
			UnityLightmapDiffuseShader(shader).texture = this.diffuse;
			UnityLightmapDiffuseShader(shader).lightmap = this.lightmap;
			UnityLightmapDiffuseShader(shader).tillingOffset = this.tilingOffset;
			UnityLightmapDiffuseShader(shader).intensity = this.intensity;
		}
		
	}
}
