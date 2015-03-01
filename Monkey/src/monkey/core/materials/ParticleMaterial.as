package monkey.core.materials {
	
	import flash.utils.ByteArray;
	
	import monkey.core.materials.shader.ParticleShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;

	/**
	 * 粒子系统材质 
	 * @author Neil
	 * 
	 */	
	public class ParticleMaterial extends Material3D {
		
		private var _texture   : Texture3D;
		private var _colorLife : Texture3D;
		private var _keyframes : ByteArray;
		private var _time	   : Number;
		private var _totalLife : Number;
		private var _billboard : Boolean;
		
		public function ParticleMaterial() {
			super();
			this._shader 	= ParticleShader.instance;
			this.blendMode 	= BLEND_SCREEN;
			this.depthWrite = false;
		}
		
		public function get billboard():Boolean {
			return _billboard;
		}
		
		public function set billboard(value:Boolean):void {
			_billboard = value;
		}
		
		public function get totalLife():Number {
			return _totalLife;
		}
		
		/**
		 * 粒子系统的整个生命周期 
		 * @param value
		 * 
		 */		
		public function set totalLife(value:Number):void {
			_totalLife = value;
		}

		public function get time():Number {
			return _time;
		}

		public function set time(value:Number):void {
			_time = value;
		}

		/**
		 * 关键帧数据 
		 * @return 
		 * 
		 */		
		public function get keyframes():ByteArray {
			return _keyframes;
		}
		
		/**
		 * 关键帧数据 
		 * @param value
		 * 
		 */		
		public function set keyframes(value:ByteArray):void {
			_keyframes = value;
		}
		
		/**
		 * color over lifetime 
		 * @return 
		 * 
		 */		
		public function get blendTexture():Texture3D {
			return _colorLife;
		}
		
		/**
		 * color over lifetime 
		 * @param value
		 * 
		 */		
		public function set blendTexture(value:Texture3D):void {
			_colorLife = value;
		}
		
		/**
		 * texture 
		 * @return 
		 * 
		 */		
		public function get texture():Texture3D {
			return _texture;
		}
		
		/**
		 * texture 
		 * @param value
		 * 
		 */		
		public function set texture(value:Texture3D):void {
			_texture = value;
		}
				
		override protected function setShaderDatas(scene:Scene3D):void {
			texture.upload(scene);
			blendTexture.upload(scene);
			ParticleShader(shader).time 		= time;
			ParticleShader(shader).texture 		= texture;
			ParticleShader(shader).keyframe 	= keyframes;
			ParticleShader(shader).billboard	= billboard;
			ParticleShader(shader).totalLife 	= totalLife;
			ParticleShader(shader).blendTexture = blendTexture;
		}
		
	}
}
