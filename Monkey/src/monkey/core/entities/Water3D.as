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
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.textures.BitmapCubeTexture;
	import monkey.core.utils.Color;
	
	/**
	 * 海水 
	 * 由于ShaderJob不能多实例运行。因此Water3D只能使用一个。。。
	 * @author Neil
	 * 
	 */	
	public class Water3D extends Object3D {
		
		[Embed(source = "water.pbj", mimeType="application/octet-stream")]
		private static var WaterShader : Class;
		
		private var _pointArr 		: Array;			
		private var _waveMesh 		: Plane; 			// 海浪geometry
		private var _waveBmp 		: BitmapData; 		// 海浪bitmapdata
		private var _waveBytes 		: ByteArray; 		// 海浪bytes
		private var _shader2d 		: Shader; 			// shader
		private var _waterSpeed 	: Number; 			// 设置水流速度
		private var _waterMaterial  : WaterMaterial;	// 水波材质
		private var _waterDirty		: Boolean;			// 是否需要更新
		private var _width			: Number;			// 宽度
		private var _height			: Number;			// 高度
		private var _segment		: int;				// 分段
		
		/**
		 *  
		 * @param cubeTexture			海水材质贴图
		 * @param normalTexture			海水形状贴图
		 * @param width					海水宽度
		 * @param height				海水长度
		 * @param segment				段数
		 * 
		 */		
		public function Water3D(cubeTexture : BitmapData, normalTexture : BitmapData, width : Number = 3000, height : Number = 3000, segment : int = 32) {
			super();
			this.name = "Water3D";
			this._waterSpeed 	= 0.25;
			this._pointArr 		= [new Point(), new Point()];
			this._waterMaterial = new WaterMaterial(new BitmapCubeTexture(cubeTexture), new Bitmap2DTexture(normalTexture), 30, 20, new Color(0x668099));
			this._waterDirty	= true;
			this.addComponent(new MeshRenderer(null, this._waterMaterial));
			this.width 			= width;
			this.height 		= height;
			this.segment 		= segment;
			this.initWater();
		}
		
		/**
		 *  初始化Water
		 */		
		private function initWater() : void {
			if (this.renderer.mesh) {
				this.renderer.mesh.dispose(true);
			}
			this._waterDirty	= false;
			this._waveBytes 	= new ByteArray();
			this._waveBytes.endian = Endian.LITTLE_ENDIAN;
			this._waveBytes.length = segment * segment * 12; // 3通道、一个通道4byte
			this._waveMesh		= new Plane(width, height, segment - 1, "+xz");
			this._waveMesh.surfaces[0].setVertexBytes(Surface3D.CUSTOM3, _waveBytes, 3);
			this._waveBmp 		= new BitmapData(segment, segment, false); // 柏林噪音图
			this._shader2d 	    = new Shader(new WaterShader());
			this._shader2d.data.src.input = _waveBmp;
			this.renderer.mesh = this._waveMesh;
		}
		
		public function get texture() : BitmapCubeTexture {
			return this._waterMaterial.cubeTexture as BitmapCubeTexture;
		}
		
		/**
		 * water 贴图 
		 * @param value
		 * 
		 */		
		public function set texture(value : BitmapCubeTexture) : void {
			this._waterMaterial.cubeTexture = value;
		}
		
		/**
		 * water 波纹图 
		 * @param value
		 * 
		 */		
		public function set normalTexture(value : Bitmap2DTexture) : void {
			this._waterMaterial.normalTexture = value;
		}
		
		public function get normalTexture() : Bitmap2DTexture {
			return this._waterMaterial.normalTexture as Bitmap2DTexture;
		}
		
		/**
		 * 混合色 
		 * @param value
		 * 
		 */		
		public function set blendColor(value : Color) : void {
			this._waterMaterial.blendColor = value;
		}
		
		public function get blendColor() : Color {
			return this._waterMaterial.blendColor;
		}
		
		/**
		 * 段数 
		 * @param value
		 * 
		 */		
		public function set segment(value:int):void {
			this._segment = value;
			this._waterDirty = true;
		}
		
		public function set height(value:Number):void {
			this._height = value;
			this._waterDirty = true;
		}
		
		/**
		 * 宽度 
		 * @param value
		 * 
		 */		
		public function set width(value:Number):void {
			this._width = value;
			this._waterDirty = true;
		}
		
		/**
		 * 海水段数 
		 * @return 
		 * 
		 */		
		public function get segment() : int {
			return _segment;
		}
		
		/**
		 * 海水宽度 
		 * @return 
		 * 
		 */		
		public function get width() : Number {
			return _width;
		}
		
		/**
		 * 海水高度 
		 * @return 
		 * 
		 */		
		public function get height() : Number {
			return _height;
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
		
		/**
		 * 绘制water 
		 * @param scene
		 * @param includeChildren
		 * 
		 */		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (this._waterDirty) {
				this.initWater();
				return;
			}
			this,updateWave();
			super.draw(scene, includeChildren);
		}
		
		/**
		 * 更新water 波浪
		 * 
		 */		
		private function updateWave() : void {
			if (!visible || disposed) {
				return;
			}
			var t : Number = getTimer();
			this._pointArr[0].y = t * _waterSpeed / 100;
			this._pointArr[1].y = t * _waterSpeed / 100;
			this._waveBmp.perlinNoise(3, 3, 2, 0, false, true, 7, true, _pointArr);
			// 柏林噪音图
			var job : ShaderJob = new ShaderJob(_shader2d, _waveBytes, segment, segment);
			job.addEventListener(ShaderEvent.COMPLETE, onWaterShaderComplete, false, 0, true);
			job.start();
		}
		
		/**
		 * shaderjob完成 
		 * @param event
		 * 
		 */		
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
