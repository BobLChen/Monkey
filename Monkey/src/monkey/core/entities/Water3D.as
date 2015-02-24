package monkey.core.entities {

	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.events.ShaderEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.materials.WaterMaterial;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.CubeTextue3D;
	import monkey.core.textures.Texture3D;

	/**
	 * 海水 
	 * @author Neil
	 * 
	 */	
	public class Water3D extends Object3D {
		
		[Embed(source = "water.pbj", mimeType="application/octet-stream")]
		private static var WaterShader : Class;
		
		private var _pointArr 		: Array;			
		private var _waveMesh 		: Plane; 		// 海浪geometry
		private var _waveBmp 		: BitmapData; 	// 海浪bitmapdata
		private var _waveBytes 		: ByteArray; 	// 海浪bytes
		private var _shader2d 		: Shader; 		// shader
		private var _waterSpeed 	: Number; 		// 设置水流速度
		private var _waterMaterial  : WaterMaterial;// 水波材质
		
		/**
		 *  
		 * @param cubeTexture			海水材质贴图
		 * @param normalTexture			海水形状贴图
		 * @param width					海水宽度
		 * @param height				海水长度
		 * @param segment				段数
		 * 
		 */		
		public function Water3D(cubeTexture : CubeTextue3D, normalTexture : Texture3D, width : Number = 3000, height : Number = 3000, segment : int = 32) {
			super();
			this._waterSpeed 	= 0.0025;
			this._pointArr 		= [new Point(), new Point()];
			this._waterMaterial = new WaterMaterial(cubeTexture, normalTexture);
			this._waveBytes 	= new ByteArray();
			this._waveBytes.endian = Endian.LITTLE_ENDIAN;
			this._waveBytes.length = segment * segment * 12; // 3通道、一个通道4byte
			this._waveMesh		= new Plane(width, height, segment - 1, "+xz");
			this._waveMesh.surfaces[0].setVertexBytes(Surface3D.CUSTOM3, _waveBytes, 3);
			this._waveBmp 		= new BitmapData(segment, segment, false); // 柏林噪音图
			this._shader2d 	    = new Shader(new WaterShader());
			this._shader2d.data.src.input = _waveBmp;
			this.addComponent(this._waterMaterial);
			this.addComponent(this._waveMesh);
		}
		
		/**
		 * 海水段数 
		 * @return 
		 * 
		 */		
		public function get segment() : int {
			return _waveMesh.segment;
		}
		
		/**
		 * 海水宽度 
		 * @return 
		 * 
		 */		
		public function get width() : Number {
			return _waveMesh.width;
		}
		
		/**
		 * 海水高度 
		 * @return 
		 * 
		 */		
		public function get height() : Number {
			return _waveMesh.height;
		}
		
		/**
		 * 海水形状等级 
		 * @param value
		 * 
		 */		
		public function set waterWave(value : Number) : void {
			this._waterMaterial.wave = value;
		}
		
		/**
		 * 海水形状等级 
		 * @param value
		 * 
		 */		
		public function get waterWave() : Number {
			return _waterMaterial.wave;
		}
		
		/**
		 * 海水高度
		 * @param value
		 * 
		 */		
		public function set waterHeight(value : Number) : void {
			this._waterMaterial.waveHeight = value;
		}
		
		/**
		 * 海水高度
		 * @param value
		 * 
		 */		
		public function get waterHeight() : Number {
			return _waterMaterial.waveHeight;
		}
		
		/**
		 * 海水速度
		 * @param value
		 * 
		 */		
		public function set waterSpeed(value : Number) : void {
			_waterSpeed = value;
		}
		
		/**
		 * 海水速度
		 * @param value
		 * 
		 */		
		public function get waterSpeed() : Number {
			return _waterSpeed;
		}
		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (!visible || disposed) {
				return;
			}
			this,updateWave();
			super.draw(scene, includeChildren);
		}
		
		private function updateWave() : void {
			var t : Number = getTimer();
			this._pointArr[0].y = t * _waterSpeed;
			this._pointArr[1].y = t * _waterSpeed;
			this._waveBmp.perlinNoise(3, 3, 2, 0, false, true, 7, true, _pointArr);
			// 柏林噪音图
			var job : ShaderJob = new ShaderJob(_shader2d, _waveBytes, _waveMesh.segment, _waveMesh.segment);
			job.addEventListener(ShaderEvent.COMPLETE, onWaterShaderComplete, false, 0, true);
			job.start();
		}
		
		private function onWaterShaderComplete(event:ShaderEvent) : void {
			if (disposed) {
				return;
			}
			if (_waveMesh.surfaces[0].vertexBuffers[Surface3D.CUSTOM3]) {
				_waveMesh.surfaces[0].vertexBuffers[Surface3D.CUSTOM3].uploadFromByteArray(_waveBytes, 0, 0, _waveMesh.segment * _waveMesh.segment);
			}
		}
		
	}
}
