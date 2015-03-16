package monkey.core.materials {
	
	import monkey.core.materials.shader.WaterShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.CubeTextue3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Color;
	
	/**
	 * 海水材质 
	 * @author Neil
	 * 
	 */	
	public class WaterMaterial extends Material3D {
		
		private var _cubeTexture   : CubeTextue3D;
		private var _normalTexture : Texture3D;
		private var _waveHeight	   : Number;
		private var _wave		   : Number;
		private var _blendColor	   : Color;
		
		/**
		 *  
		 * @param cubeTexture			海水颜色材质
		 * @param normalTexture			海水形状材质
		 * @param wave					海水形状等级
		 * @param waveHeight			海水高度
		 * @param blendColor			波光颜色
		 * 
		 */		
		public function WaterMaterial(cubeTexture : CubeTextue3D, normalTexture : Texture3D, wave : Number, waveHeight : Number, blendColor : Color) {
			super(WaterShader.instance);
			this.cubeTexture   = cubeTexture;
			this.normalTexture = normalTexture;
			this.wave		   = wave;
			this.waveHeight	   = waveHeight;
			this.blendColor	   = blendColor;
		}
		
		override public function clone():Material3D {
			var c : WaterMaterial = new WaterMaterial(cubeTexture.clone() as CubeTextue3D, normalTexture.clone(), wave, waveHeight, blendColor);
			c.copyFrom(this);
			return c;
		}
		
		override public function dispose():void {
			super.dispose();
			this.cubeTexture.dispose();
			this.normalTexture.dispose();
		}
		
		override protected function setShaderDatas(scene:Scene3D):void {
			this.cubeTexture.upload(scene);
			this.normalTexture.upload(scene);
			WaterShader(shader).cubeTexture 	= cubeTexture;
			WaterShader(shader).normalTexture 	= normalTexture;
			WaterShader(shader).waveHeight 		= waveHeight;
			WaterShader(shader).waterWave 		= wave;
			WaterShader(shader).blendColor 		= blendColor;
		}
		
		public function get blendColor():Color {
			return _blendColor;
		}

		public function set blendColor(value:Color):void {
			_blendColor = value;
		}

		public function get wave():Number {
			return _wave;
		}

		public function set wave(value:Number):void {
			_wave = value;
		}

		public function get waveHeight():Number {
			return _waveHeight;
		}

		public function set waveHeight(value:Number):void {
			_waveHeight = value;
		}

		public function get normalTexture():Texture3D {
			return _normalTexture;
		}

		public function set normalTexture(value:Texture3D):void {
			_normalTexture = value;
		}

		public function get cubeTexture():CubeTextue3D {
			return _cubeTexture;
		}

		public function set cubeTexture(value:CubeTextue3D):void {
			_cubeTexture = value;
		}
		
	}
}
