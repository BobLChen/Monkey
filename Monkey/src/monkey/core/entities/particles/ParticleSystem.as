package monkey.core.entities.particles {

	import flash.display.BitmapData;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.animator.ParticleAnimator;
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.entities.particles.prop.color.ColorConst;
	import monkey.core.entities.particles.prop.color.PropColor;
	import monkey.core.entities.particles.prop.value.DataConst;
	import monkey.core.entities.particles.prop.value.PropData;
	import monkey.core.entities.particles.shape.ParticleShape;
	import monkey.core.entities.particles.shape.SphereShape;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.ParticleMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.GradientColor;
	import monkey.core.utils.Matrix3DUtils;
	import monkey.core.utils.ParticleConfig;
	import monkey.core.utils.Time3D;
	
	/**
	 * 粒子
	 * @author Neil
	 * 
	 */	
	public class ParticleSystem extends Object3D {
		
		[Embed(source="ParticleSystem.png")]
		private static const DEFAULT_IMG	: Class;										// 粒子默认贴图
		/** 粒子系统build事件 */
		public  static const BUILD_EVENT	: String = "ParticleSystem:BUILD";				// buld事件
		/** lifetime最大关键帧数量 */
		public  static const MAX_KEY_NUM 	: int = 6;										// 最大的关键帧数量
		private static const buildEvent	   	: Event = new Event(BUILD_EVENT);				// 粒子系统创建完成事件
		private static const DELAY_BIAS		: Number = 0.001;								// 延时时间偏移参数
		private static const matrix3d 		: Matrix3D = new Matrix3D();					// matrix缓存
		private static const vector3d 		: Vector3D = new Vector3D();					// vector缓存
		/** 默认关键帧 */
		private static var _defKeyframe 	: ByteArray;
				
		private var _autoRot		: Boolean;						// 朝着方向自动旋转
		private var _duration 				: Number; 						// 持续发射时间
		private var _loops 					: Boolean; 						// 循环发射模式
		private var _startDelay 			: Number; 						// 开始延迟时间
		private var _startLifeTime 			: PropData; 					// 生命周期
		private var _startSpeed 			: PropData; 					// 速度
		private var _startOffset			: Vector.<PropData>;			// 初始位移
		private var _startSize 				: PropData; 					// 初始大小
		private var _startRotation 			: Vector.<PropData>; 			// 初始旋转角度
		private var _startColor 			: PropColor; 					// 初始颜色
		private var _shape 					: ParticleShape; 				// 形状
		private var _simulationSpace 		: Boolean; 						// 坐标系。false:本地；true:世界
		private var _rate 					: int; 							// 发射频率
		private var _bursts 				: Vector.<Point>; 				// 爆炸
		private var _particleNum			: int;							// 粒子数量
		private var _totalTime				: Number;						// 粒子系统的生命周期
		private var _needBuild				: Boolean;						// 是否需要build
		private var _colorOverLifetime 	 	: GradientColor;				// color over lifetime
		private var _keyfsOverLifetime 		: ByteArray;					// 缩放旋转速度 over lifetime
		private var _image					: BitmapData;					// image
		private var _totalLife				: Number;						// 周期
		private var _texture				: Bitmap2DTexture;				// 粒子贴图
		private var _blendColor				: Color;						// 调色
		private var blendTexture   			: Bitmap2DTexture;				// color over lifetime贴图
		
		private var _posBytes 				: ByteArray;					// world属性时使用的bytes
		private var _velBytes				: ByteArray;					// world属性时使用的bytes
		private var _lastIdx  				: int = 0;						// world属性粒子的最后索引
		private var _posBuffer				: VertexBuffer3D;				// world属性粒子的位移 buffer
		private var _velBuffer				: VertexBuffer3D;				// world属性粒子的速度 buffer
							
		public function ParticleSystem() {
			super();
			this._posBytes		 	= new ByteArray();
			this._posBytes.endian	= Endian.LITTLE_ENDIAN;
			this._velBytes 			= new ByteArray();
			this._velBytes.endian	= Endian.LITTLE_ENDIAN;
		}
		
		/**
		 * 通过配置文件初始化 
		 * @param config
		 * 
		 */		
		public function initWithConfig(config : Object) : void {
			
			this.addComponent(new MeshRenderer(new Mesh3D([]), new ParticleMaterial()));
			this.addComponent(new ParticleAnimator());
			
			this.renderer.material.depthWrite 	= config.depthWrite;
			this.renderer.material.depthCompare = config.depthCompare;
			this.renderer.material.cullFace		= config.cullFace;
			this.renderer.material.sourceFactor = config.sourceFactor;
			this.renderer.material.destFactor	= config.destFactor;		
			
			this.animator.totalFrames	= config.totalFrames == -1 ? Number.MAX_VALUE : config.totalFrames;
			this.userData.imageName 	= config.imageName;
			this.userData.uuid 			= config.uuid;
			this.userData.optimize   	= config.optimize;
			this.mesh.bounds			= new Bounds3D();
			
			this._autoRot				= config.autoRot;
			this._lastIdx		 		= 0;
			this._simulationSpace		= config.world;
			this._totalTime				= config.totalTime;
			this._particleNum			= config.maxParticles;
			this._loops					= config.loops;
			this._startDelay			= config.startDelay;
			this._shape					= new ParticleShape();
			this._shape.vertNum			= config.vertNum;
			
			this.blendColor				= new Color();
			this.frame					= new Point(config.frame[0], config.frame[1]);
			this.billboard				= config.billboard;
			this.totalLife				= config.totalLife;
			this.colorLifetime			= ParticleConfig.getGradientColor(config.colorLifetime);
			this.keyFrames				= ParticleConfig.getKeyFrames(config.keyFrames);
			this.duration 				= config.duration;
			this.rate	  		    	= config.rate;
			this.bursts					= ParticleConfig.getBursts(config.bursts);
			this._needBuild				= false;
			
			if (config.optimize) {
				return;
			}
			
			this.shape	  		  		= ParticleConfig.getShape(config.shape);
			this.startColor		  		= ParticleConfig.getColor(config.startColor);
			this.startLifeTime	  		= ParticleConfig.getData(config.startLifeTime);
			this.startOffset			= new Vector.<PropData>();
			this.startOffset[0]	  		= ParticleConfig.getData(config.startOffset.x);
			this.startOffset[1]	  		= ParticleConfig.getData(config.startOffset.y);
			this.startOffset[2]	  		= ParticleConfig.getData(config.startOffset.z);
			this.startRotation			= new Vector.<PropData>();
			this.startRotation[0]  		= ParticleConfig.getData(config.startRotation.x);
			this.startRotation[1]  		= ParticleConfig.getData(config.startRotation.y);
			this.startRotation[2]  		= ParticleConfig.getData(config.startRotation.z);
			this.startSize		  		= ParticleConfig.getData(config.startSize);
			this.startSpeed		  		= ParticleConfig.getData(config.startSpeed);
			this.userData.lifetimeData 	= config.lifetimeData;	// lifetimeData由IDE自己去组装
			this._needBuild				= false;
		}
		
		/**
		 *  初始化粒子
		 */		
		public function init() : void {
			var mode : Surface3D = new Plane(1, 1, 1).surfaces[0];
			var mesh : Mesh3D = new Mesh3D([]);
			mesh.bounds	= new Bounds3D();
			
			this.addComponent(new ParticleAnimator());
			this.addComponent(new MeshRenderer(mesh, new ParticleMaterial()));
			this._lastIdx		 = 0;
			this.name			 = "Particle";
			this.shape 			 = new SphereShape();
			this.shape.mode 	 = mode;				
			this.rate 			 = 10;								
			this.blendColor		 = new Color();
			this.bursts 		 = new Vector.<Point>();		
			this.billboard		 = true;
			this.duration 		 = 5;											
			this.loops 		 	 = true;											
			this.startDelay 	 = 0;				
			this.frame			 = new Point(1, 1);
			this.startSpeed 	 = new DataConst(5);							
			this.startSize 		 = new DataConst(1);
			this.startColor 	 = new ColorConst(0xFFFFFF);				
			this.startLifeTime   = new DataConst(5);	
			this.colorLifetime	 = new GradientColor();
			this.startRotation   = Vector.<PropData>([new DataConst(0), new DataConst(0), new DataConst(0)])
			this.startOffset 	 = Vector.<PropData>([new DataConst(0), new DataConst(0), new DataConst(0)]);;
			this.worldspace 	 = false;							
			this.image			 = new DEFAULT_IMG().bitmapData;
			this.keyFrames		 = keyframeDatas;
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		override public function clone():Object3D {
			var c : ParticleSystem = new ParticleSystem();
			c.removeAllComponents();
			for each (var icom : IComponent in components) {
				c.addComponent(icom.clone());
			}
			for each (var child : Object3D in children) {
				c.addChild(child.clone());
			}
			c._autoRot 	= this._autoRot;
			c._layer 			= this._layer;
			c._duration 		= this._duration;
			c._loops			= this._loops;
			c._startDelay		= this._startDelay;
			c._startLifeTime	= this._startLifeTime;
			c._startSpeed		= this._startSpeed;
			c._startOffset  	= this._startOffset;
			c._startSize		= this._startSize;
			c._startRotation	= this._startRotation;
			c._startColor		= this._startColor;
			c._blendColor		= this._blendColor.clone();
			c._shape			= this._shape;
			c._rate				= this._rate;
			c._bursts			= this._bursts;
			c._particleNum		= this._particleNum;
			c._totalTime		= this._totalTime;
			c._needBuild		= this._needBuild;
			c._image			= this._image;
			c._texture			= this._texture;
			c._totalLife		= this._totalLife;
			c._keyfsOverLifetime= this._keyfsOverLifetime;
			c._colorOverLifetime= this._colorOverLifetime;
			c._simulationSpace	= this._simulationSpace;
			c.blendTexture		= this.blendTexture;
			return c;
		}
		
		override public function dispose(force:Boolean=false):void {
			super.dispose(force);
			if (this._posBuffer) {
				this._posBuffer.dispose();
				this._posBuffer = null;
			}
			if (this._posBytes) {
				this._posBytes.clear();
				this._posBytes = null;
			}
			if (this._velBuffer) {
				this._velBuffer.dispose();
				this._velBuffer = null;
			}
			if (this._velBytes) {
				this._velBytes.clear();
				this._velBytes = null;
			}
		}
		
		/**
		 * 构建粒子系统 
		 * 
		 */		
		public function build() : void {
			this._needBuild = false;
			this.renderer.mesh.dispose(true);			// 释放所有的数据
			this.caculateTotalTime();					// 首先计算出粒子的生命周期
			this.caculateParticleNum();					// 计算所有的粒子数量
			this.createParticleMesh();					// 生成粒子对应的网格
			this.shape.generate(this);					// 生成shape对应的数据，包括粒子的位置、方向、uv、索引
			this.createParticleAttribute();				// 更新粒子属性
			this.rebuildWorldBuffer();					// 重新构建world属性buffer
			if (this.hasEventListener(BUILD_EVENT)) {
				this.dispatchEvent(buildEvent); 		// 完成事件
			}
		}
		
		/**
		 * 重新构建world属性所需 buffer 
		 * 
		 */		
		private function rebuildWorldBuffer() : void {
			if (this._posBuffer) {
				this._posBuffer.dispose();
				this._posBuffer = null;
			}
			if (this._velBuffer) {
				this._velBuffer.dispose();
				this._velBuffer = null;
			}
			// 创建buffer
			if (this.scene && this._simulationSpace) {
				// 位移
				var bytes : ByteArray = this.surfaces[0].getVertexBytes(Surface3D.CUSTOM4);
				this._posBuffer = this.scene.context.createVertexBuffer(bytes.length / 12, 3);
				this._posBuffer.uploadFromByteArray(bytes, 0, 0, bytes.length / 12);
				// 速度
				bytes = this.surfaces[0].getVertexBytes(Surface3D.CUSTOM1);
				this._velBuffer = this.scene.context.createVertexBuffer(bytes.length / 12, 3);
				this._velBuffer.uploadFromByteArray(bytes, 0, 0, bytes.length / 12);
			}
		}
		
		/**
		 *  更新粒子的属性
		 */		
		private function createParticleAttribute() : void {
			// 生成正常发射频率的数据
			var rateNum : int = rate * duration;
			var idx : int = 0;
			for (var i:int = 0; i < rateNum; i++) {
				this.updateParticles(idx++, i * 1.0 / rate + DELAY_BIAS);
			}
			// 补齐正常发射频率数据
			var fillSize : int = Math.ceil(this._totalTime / duration) - 1;
			var delay : Number = 0;
			if (loops) {
				for (var m:int = 1; m <= fillSize; m++) {
					delay = duration * m;
					for (i = 0; i < rateNum; i++) {
						this.updateParticles(idx++, delay + i * 1.0 / rate + DELAY_BIAS);
					}
				}
			}
			// 生成burst数据
			for (var j:int = 0; j < bursts.length; j++) {	
				for (var n:int = 0; n < bursts[j].y; n++) {	
					this.updateParticles(idx++, bursts[j].x);
				}
			}
			// 补齐burst数据
			if (loops) {
				for (m = 1; m <= fillSize; m++) {
					delay = duration * m;
					for (j = 0; j < bursts.length; j++) {
						for (n = 0; n < bursts[j].y; n++) {	
							this.updateParticles(idx++, delay + bursts[j].x);
						}
					}
				}
			}
			// 循环发射
			if (loops) {
				this._totalTime = fillSize * duration + duration;
			}
			// totalife
			this.totalLife  = this._totalTime;
		}
		
		private function createParticleMesh() : void {
			// 根据粒子数量以及shape顶点数量计算出需要多少个surface
			var size : int = Math.ceil(maxParticles * shape.vertNum / 65535);
			// 计算出每个suface的容量
			var perSize : int = 65535 / shape.vertNum;					
			for (var i:int = 0; i < size; i++) {
				var num : int = 0;
				if (i == size - 1) {
					num = maxParticles - perSize * i;
				} else {
					num = perSize;
				}
				var surface : Surface3D = new Surface3D();
				// custom2存放时间参数，第一个存放起始时间，第二个存放生命周期时间
				surface.setVertexVector(Surface3D.CUSTOM2, new Vector.<Number>(num * shape.vertNum * 2, true), 2);
				// custom3存放粒子颜色，分别对应rgba
				surface.setVertexVector(Surface3D.CUSTOM3, new Vector.<Number>(num * shape.vertNum * 4, true), 4);
				this.renderer.mesh.surfaces.push(surface);
			}
		}
		
		/**
		 * 计算粒子系统的整个生命周期 
		 * 
		 */		
		private function caculateTotalTime() : void {
			this._totalTime = 0;
			// 计算正常发射频率的时间=delay + lifetime
			var rateNum  : int = rate * duration;
			var delay 	 : Number = 0;
			var lifetime : Number = 0;
			for (var i:int = 0; i < rateNum; i++) {
				delay 	 = i * 1.0 / rate;
				lifetime = startLifeTime.getValue(delay);
				this._totalTime = Math.max(this._totalTime, delay + lifetime);
			}
			// 计算burst的时间
			for (var j:int = 0; j < bursts.length; j++) {	
				delay = bursts[j].x;
				lifetime = startLifeTime.getValue(delay);
				this._totalTime = Math.max(this._totalTime, delay + lifetime);
			}		
			this._totalTime += DELAY_BIAS;
			this.animator.totalFrames = this._totalTime + this._startDelay;
			if (this.loops) {
				this.animator.totalFrames = Number.MAX_VALUE;
			}
		}
		
		/**
		 * 更新粒子系统数据 
		 * @param idx		粒子索引
		 * @param delay		粒子延时
		 */		
		private function updateParticles(idx : int, delay : Number) : void {
			var perSize  : int = 65535 / shape.vertNum;										// 计算出每一个surface存放的粒子数量
			var surface  : Surface3D = this.surfaces[int(idx / perSize)];					// 根据persize计算出surface的索引
			idx = idx % perSize;															// 重置索引为surface的正常索引
			// 粒子数据
			var position : Vector.<Number> = surface.getVertexVector(Surface3D.POSITION);	// 位置
			var velocity : Vector.<Number> = surface.getVertexVector(Surface3D.CUSTOM1);	// 方向
			var lifetimes: Vector.<Number> = surface.getVertexVector(Surface3D.CUSTOM2);	// 时间
			var colors	 : Vector.<Number> = surface.getVertexVector(Surface3D.CUSTOM3);	// 颜色
			var xDelay	 : Number	= delay % duration;										// x轴的延时
			var speed 	 : Number 	= startSpeed.getValue(xDelay);							// 根据延时获取对应的Speed
			var size 	 : Number 	= startSize.getValue(xDelay);							// 根据延时获取对应的Size
			var rotaX 	 : Number 	= startRotation[0].getValue(xDelay);					// 根据延时获取对应的RotationX
			var rotaY 	 : Number 	= startRotation[1].getValue(xDelay);					// 根据延时获取对应的RotationY
			var rotaZ 	 : Number 	= startRotation[2].getValue(xDelay);					// 根据延时获取对应的RotationZ
			var color 	 : Vector3D = startColor.getRGBA(xDelay / duration);				// 根据延时获取对应的Color
			var lifetime : Number 	= startLifeTime.getValue(xDelay);						// 根据延时获取对应的LifeTime
			// 缩放以及旋转
			matrix3d.identity();
			Matrix3DUtils.setScale(matrix3d, size, size, size);
			Matrix3DUtils.setRotation(matrix3d, rotaX, rotaY, rotaZ);
			// const speed
			var speedX : Number = startOffset[0].getValue(delay);
			var speedY : Number = startOffset[1].getValue(delay);
			var speedZ : Number = startOffset[2].getValue(delay);
			// step
			var step2 : int = shape.vertNum * idx * 2;
			var step3 : int = shape.vertNum * idx * 3;
			var step4 : int = shape.vertNum * idx * 4;
			// 沿着线速度
			if (this.autoRot) {
				vector3d.setTo(velocity[step3 + 0], velocity[step3 + 1], velocity[step3 + 2]);
				vector3d.normalize();
				Matrix3DUtils.setOrientation(matrix3d, vector3d);
			}
			// 遍历shape
			for (var j:int = 0; j < shape.vertNum; j++) {
				// 转换位置数据
				var seg2 : int = j * 2;
				var seg3 : int = j * 3;
				var seg4 : int = j * 4;
				vector3d.x = position[step3 + seg3 + 0];
				vector3d.y = position[step3 + seg3 + 1];
				vector3d.z = position[step3 + seg3 + 2];
				Matrix3DUtils.transformVector(matrix3d, vector3d, vector3d);
				position[step3 + seg3 + 0] = vector3d.x;
				position[step3 + seg3 + 1] = vector3d.y;
				position[step3 + seg3 + 2] = vector3d.z;
				// 转换速度
				vector3d.x = velocity[step3 + seg3 + 0];
				vector3d.y = velocity[step3 + seg3 + 1];
				vector3d.z = velocity[step3 + seg3 + 2];
				vector3d.scaleBy(speed);
				// 附加速度
				vector3d.x += speedX;
				vector3d.y += speedY;
				vector3d.z += speedZ;
				velocity[step3 + seg3 + 0] = vector3d.x;
				velocity[step3 + seg3 + 1] = vector3d.y;
				velocity[step3 + seg3 + 2] = vector3d.z;
				// 生命周期
				lifetimes[step2 + seg2 + 0] = delay;
				lifetimes[step2 + seg2 + 1] = lifetime;
				// 颜色
				colors[step4 + seg4 + 0] = color.x;
				colors[step4 + seg4 + 1] = color.y;
				colors[step4 + seg4 + 2] = color.z;
				colors[step4 + seg4 + 3] = color.w;
			}
		}
		
		/**
		 * 默认的关键帧数据，强制使用5个关键帧
		 * @return 
		 * 
		 */		
		private static function get keyframeDatas() : ByteArray {
			if (!_defKeyframe) {
				var bytes  : ByteArray = new ByteArray();
				bytes.endian = Endian.LITTLE_ENDIAN;
				// 旋转
				for (i = 0; i < ParticleSystem.MAX_KEY_NUM; i++) {
					bytes.writeFloat(0);
					bytes.writeFloat(0);
					bytes.writeFloat(1);
					bytes.writeFloat(0);
				}
				// 缩放
				for (i = 0; i < ParticleSystem.MAX_KEY_NUM; i++) {
					bytes.writeFloat(1);
					bytes.writeFloat(1);
					bytes.writeFloat(1);
					bytes.writeFloat(1);
				}
				// 位移
				for (var i:int = 0; i < ParticleSystem.MAX_KEY_NUM; i++) {
					bytes.writeFloat(0);
					bytes.writeFloat(0);
					bytes.writeFloat(0);
					bytes.writeFloat(0);
				}
				_defKeyframe = bytes;
			}
			
			var data : ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			
			_defKeyframe.position = 0;
			_defKeyframe.readBytes(data, 0, _defKeyframe.length);
			
			return data;
		}
		
		public function get totalTime():Number {
			return _totalTime;
		}
				
		public function get surfaces() : Vector.<Surface3D> {
			return this.mesh.surfaces;
		}
		
		public function get billboard():Boolean {
			return this.material.billboard;
		}
		
		/**
		 * 广告牌模式 
		 * @param value
		 * 
		 */		
		public function set billboard(value:Boolean):void {
			this.material.billboard = value;
		}
		
		private function get mesh() : Mesh3D {
			return this.renderer.mesh;
		}
		
		private function get material() : ParticleMaterial {
			return this.renderer.material as ParticleMaterial;
		}
		
		/**
		 * 粒子贴图 
		 * @return 
		 * 
		 */		
		public function get image():BitmapData {
			return _image;
		}
		
		/**
		 * 粒子贴图 
		 * @param value
		 * 
		 */		
		public function set image(value:BitmapData):void {
			if (this.texture) {
				this.texture.dispose(true);
			}
			this._image = value;
			this.texture = new Bitmap2DTexture(value);
		}
		
		public function get texture():Bitmap2DTexture {
			return _texture;
		}
		
		/**
		 * 贴图 
		 * @param value
		 * 
		 */		
		public function set texture(value:Bitmap2DTexture):void {
			this._texture = value;
			this.material.texture = value;
		}
		
		public function get frame():Point {
			return this.material.frame;
		}
		
		/**
		 * uv动画 
		 * @param value
		 * 
		 */		
		public function set frame(value:Point):void {
			this.material.frame = value;
		}
		
		/**
		 * 随生命周期变换的旋转缩放速度数据 
		 * @param value
		 * 
		 */		
		public function get keyFrames():ByteArray {
			return _keyfsOverLifetime;
		}
		
		public function set keyFrames(value:ByteArray):void {
			_keyfsOverLifetime = value;
			material.keyframes = value;
		}
		
		/**
		 * 随生命周期变化的颜色 
		 * @return 
		 * 
		 */		 
		public function get colorLifetime():GradientColor {
			return _colorOverLifetime;
		}
		
		/**
		 * 随生命周期变化的颜色 
		 * @param value
		 * 
		 */		
		public function set colorLifetime(value:GradientColor):void {
			_colorOverLifetime = value;
			if (blendTexture) {
				blendTexture.dispose(true);
			}
			blendTexture = new Bitmap2DTexture(_colorOverLifetime.gridient);
			material.blendTexture = blendTexture;
		}
		
		/**
		 * 附加速度 
		 * @param value
		 * 
		 */		
		public function set startOffset(value:Vector.<PropData>):void {
			_startOffset = value;
			_needBuild = true;
		}
		
		/**
		 * 附加速度 
		 * @return 
		 * 
		 */		
		public function get startOffset():Vector.<PropData> {
			return _startOffset;
		}
		
		/**
		 * 粒子数量 
		 * @return 
		 * 
		 */				
		public function get maxParticles():int {
			return _particleNum;
		}
				
		/**
		 * 计算粒子系统的粒子数量
		 */		
		private function caculateParticleNum() : void {
			var result : int = 0;
			result += int(rate * duration);							// 发射频率 * 发射时间
			for (var i:int = 0; i < bursts.length; i++) {
				result += bursts[i].y;
			}
			// 循环模式需要补齐粒子
			// 例如粒子系统的生命周期_totalTime为8秒，但是发射器发射时间为5秒。因此少了一个循环，需要补齐一个循环。
			if (loops) {
				var fillNum : int = Math.ceil(this._totalTime / duration);
				result = result * fillNum;
			}
			this._particleNum = result;
		}
		
		/**
		 * 粒子形状
		 * @return
		 *
		 */
		public function get shape() : ParticleShape {
			return _shape;
		}

		/**
		 * 粒子形状
		 * @param value
		 *
		 */
		public function set shape(value : ParticleShape) : void {
			_shape = value;
			_needBuild = true;
		}
		
		/**
		 * 沿着方向自动旋转 
		 * @return 
		 * 
		 */		
		public function get autoRot():Boolean {
			return _autoRot;
		}
		
		/**
		 * @private
		 */
		public function set autoRot(value:Boolean):void {
			this._autoRot = value;
			this._needBuild = true;
		}

		/**
		 * 爆发粒子
		 * @return
		 *
		 */
		public function get bursts() : Vector.<Point> {
			return _bursts;
		}

		/**
		 * 爆发粒子
		 * @return
		 *
		 */
		public function set bursts(value : Vector.<Point>) : void {
			_bursts = value;
			_needBuild = true;
		}

		/**
		 * 发射频率
		 * @param value
		 *
		 */
		public function get rate() : int {
			return _rate;
		}

		/**
		 * 发射频率
		 * @param value
		 *
		 */
		public function set rate(value : int) : void {
			_rate = value;
			_needBuild = true;
		}
		
		/**
		 * 粒子坐标系
		 * @param value
		 *
		 */
		public function get worldspace() : Boolean {
			return _simulationSpace;
		}
		
		/**
		 * world类型的粒子最多只能使用顶点数量为65535。超过了将不再启用。
		 * world类型的粒子暂不支持Bursts
		 * @param value
		 *
		 */
		public function set worldspace(value : Boolean) : void {
			_simulationSpace = value;
			this.rebuildWorldBuffer();
		}
		
		/**
		 * 初始颜色
		 * @return
		 *
		 */
		public function get startColor() : PropColor {
			return _startColor;
		}

		/**
		 * 初始颜色
		 * @param value
		 *
		 */
		public function set startColor(value : PropColor) : void {
			_startColor = value;
			_needBuild = true;
		}

		/**
		 * 初始角度
		 * @return
		 *
		 */
		public function get startRotation() : Vector.<PropData> {
			return _startRotation;
		}

		/**
		 * 初始角度
		 * @param value
		 *
		 */
		public function set startRotation(value : Vector.<PropData>) : void {
			_startRotation = value;
			_needBuild = true;
		}

		/**
		 * 初始大小
		 * @return
		 *
		 */
		public function get startSize() : PropData {
			return _startSize;
		}

		/**
		 * 初始大小
		 * @param value
		 *
		 */
		public function set startSize(value : PropData) : void {
			_startSize = value;
			_needBuild = true;
		}

		/**
		 * 初始速度
		 * @return
		 *
		 */
		public function get startSpeed() : PropData {
			return _startSpeed;
		}

		/**
		 * 初始速度
		 * @param value
		 *
		 */
		public function set startSpeed(value : PropData) : void {
			_startSpeed = value;
			_needBuild = true;
		}

		/**
		 * 粒子生命周期
		 * @return
		 *
		 */
		public function get startLifeTime() : PropData {
			return _startLifeTime;
		}

		/**
		 * 粒子生命周期
		 * @param value
		 *
		 */
		public function set startLifeTime(value : PropData) : void {
			_startLifeTime = value;
			_needBuild = true;
		}

		/**
		 * 开始延迟时间
		 * @return
		 *
		 */
		public function get startDelay() : Number {
			return _startDelay;
		}

		/**
		 * 开始延迟时间
		 * @return
		 *
		 */
		public function set startDelay(value : Number) : void {
			_startDelay = value;
		}

		/**
		 * loop模式。0:无限循环；1:循环次数
		 * @return
		 *
		 */
		public function get loops() : Boolean {
			return _loops;
		}

		/**
		 * loop模式。0:无限循环；1:循环次数
		 * @return
		 *
		 */
		public function set loops(value : Boolean) : void {
			this._loops = value;
			this._needBuild = true;
		}
		
		/**
		 * 发射持续时间
		 * @return
		 *
		 */
		public function get duration() : Number {
			return _duration;
		}
		
		public function get totalLife():Number {
			return _totalLife;
		}
		
		public function set totalLife(value:Number):void {
			_totalLife = value;
			this.material.totalLife = value;
		}

		/**
		 * 发射持续时间
		 * @return
		 *
		 */
		public function set duration(value : Number) : void {
			this._duration = value;
			this._needBuild = true;
		}
		
		public function get blendColor():Color {
			return _blendColor;
		}
		
		public function set blendColor(value:Color):void {
			_blendColor = value;
			this.material.blendColor = value;
		}
		
		/**
		 * 更新buffer 
		 * 
		 */		
		private function updateBuffers() : void {
			if (!this._posBuffer) {
				this.rebuildWorldBuffer();
			}
			this._posBytes.clear();
			this._velBytes.clear();
			// 计算当前粒子索引
			var curIdx : int = int((this.animator.currentFrame % this._totalTime) * rate) % maxParticles;	
			// 计算出需要更新的数量,需要算上最后一次更新位置
			var count  : int = 0;
			// 判断是否到达末尾
			if (this._lastIdx > curIdx) {
				count = maxParticles - this._lastIdx;
			} else {
				count = Math.ceil(Time3D.deltaTime * rate) + curIdx - this._lastIdx;
			}
			// 考虑到计算量world属性仅仅只对顶点数量<=65535有用
			var surf   : Surface3D = this.surfaces[0];		
			// 获取偏移数据
			var offsetBytes: ByteArray = surf.getVertexBytes(Surface3D.CUSTOM4);	
			offsetBytes.position = shape.vertNum * 12 * _lastIdx;
			// 速度数据
			var speedBytes : ByteArray = surf.getVertexBytes(Surface3D.CUSTOM1);
			speedBytes.position = shape.vertNum * 12 * _lastIdx;
			// 统计数量
			var num	   : int = 0;																				
			while (offsetBytes.bytesAvailable && count > 0) {
				count--;
				for (var i:int = 0; i < shape.vertNum; i++) {
					// 位移
					vector3d.x = offsetBytes.readFloat();
					vector3d.y = offsetBytes.readFloat();
					vector3d.z = offsetBytes.readFloat();
					this.transform.localToGlobal(vector3d, vector3d);
					this._posBytes.writeFloat(vector3d.x);
					this._posBytes.writeFloat(vector3d.y);
					this._posBytes.writeFloat(vector3d.z);
					// 速度
					vector3d.x = speedBytes.readFloat();
					vector3d.y = speedBytes.readFloat();
					vector3d.z = speedBytes.readFloat();
					this.transform.localToGlobalVector(vector3d, vector3d);
					this._velBytes.writeFloat(vector3d.x);
					this._velBytes.writeFloat(vector3d.y);
					this._velBytes.writeFloat(vector3d.z);
				}
				num++;
			}
			// 更新粒子数据
			if (this._posBuffer && num >= 1) {
				this._posBuffer.uploadFromByteArray(this._posBytes, 0, this._lastIdx * shape.vertNum, num * shape.vertNum);
				this._velBuffer.uploadFromByteArray(this._velBytes, 0, this._lastIdx * shape.vertNum, num * shape.vertNum);
				if (this._lastIdx > curIdx) {
					this._lastIdx = 0;
					// 粒子只更新到末尾，并没有更新完，还需要从0开始更新一次
					this.updateBuffers();
				} else {
					this._lastIdx = curIdx;
				}
			}
		}
		
		private function ready() : Boolean {
			if (!this.visible) {
				return false;
			}
			// 延时未到
			if (this.animator.currentFrame < this.startDelay) {
				return false;
			}
			// 非循环模式并且播放完成
			if (!this.loops && this.animator.currentFrame > this.animator.totalFrames) {
				return false;				
			}
			return true;
		}
		
		private function updateDeviceData() : void {
			// 模型数据
			Device3D.world.copyFrom(transform.world);
			Device3D.mvp.copyFrom(Device3D.world);
			Device3D.mvp.append(Device3D.viewProjection);
			Device3D.drawOBJNum++;
			if (this._simulationSpace) {
				Device3D.world.identity();
				Device3D.mvp.copyFrom(Device3D.viewProjection);
			}
		}
		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (!this.ready()) {
				return;
			}
			if (this._needBuild) {
				this.build();
			}
			if (this.hasEventListener(ENTER_DRAW_EVENT)) {
				this.dispatchEvent(enterDrawEvent);
			}
			this.updateDeviceData();
			
			var posBuffer : VertexBuffer3D = null;
			var velBuffer : VertexBuffer3D = null;
			if (this._simulationSpace) {
				this.updateBuffers();
				posBuffer = this.surfaces[0].vertexBuffers[Surface3D.CUSTOM4];						// 替换surface里面vertexbuffer
				velBuffer = this.surfaces[0].vertexBuffers[Surface3D.CUSTOM1];						// 替换surface里面vertexbuffer
				if (posBuffer && velBuffer) {
					this.surfaces[0].vertexBuffers[Surface3D.CUSTOM4] = this._posBuffer;
					this.surfaces[0].vertexBuffers[Surface3D.CUSTOM1] = this._velBuffer;
				}
			}
			
			// 设置时间
			this.material.time = this.animator.currentFrame - this.startDelay;
			// 绘制组件
			for each (var icom : IComponent in components) {
				if (icom.enable) {
					icom.onDraw(scene);
				}
			}
			
			// world属性，替换回vertexbuffer
			if (this._simulationSpace && posBuffer && velBuffer) {
				this.surfaces[0].vertexBuffers[Surface3D.CUSTOM4] = posBuffer;
				this.surfaces[0].vertexBuffers[Surface3D.CUSTOM1] = velBuffer;
			}
			
			// 绘制children
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.draw(scene, includeChildren);
				}
			}
			
			if (this.hasEventListener(EXIT_DRAW_EVENT)) {
				this.dispatchEvent(exitDrawEvent);
			}
		}
	}
}
