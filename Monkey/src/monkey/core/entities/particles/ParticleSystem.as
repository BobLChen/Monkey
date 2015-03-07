package monkey.core.entities.particles {

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.entities.particles.prop.color.PropColor;
	import monkey.core.entities.particles.prop.color.PropGradientColor;
	import monkey.core.entities.particles.prop.value.PropConst;
	import monkey.core.entities.particles.prop.value.PropData;
	import monkey.core.entities.particles.prop.value.PropRandomTwoConst;
	import monkey.core.entities.particles.shape.ParticleShape;
	import monkey.core.entities.particles.shape.SphereShape;
	import monkey.core.entities.primitives.Plane;
	import monkey.core.interfaces.IComponent;
	import monkey.core.materials.ParticleMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.GradientColor;
	import monkey.core.utils.Matrix3DUtils;
	import monkey.core.utils.Time3D;
	
	/**
	 * 粒子
	 * @author Neil
	 * 
	 */	
	public class ParticleSystem extends Object3D {
		
		[Embed(source="ParticleSystem.png")]
		private static const DEFAULT_IMG	: Class;										// 粒子默认贴图
		
		/** 粒子动画播放完成事件 */
		public static const PLAY_COMPLETE	: String = "ParticleSystem:COMPLETE";
		/** 粒子系统build事件 */
		public static const BUILD		   	: String = "ParticleSystem:BUILD";
		/** lifetime最大关键帧数量 */
		public static const MAX_KEY_NUM 	: int = 6;
		
		private static const buildEvent	   	: Event = new Event(BUILD);						// 粒子系统创建完成事件
		private static const AnimDoneEvent 	: Event = new Event(PLAY_COMPLETE);				// 播放完成事件
		private static const DELAY_BIAS		: Number = 0.001;								// 延时时间偏移参数
		private static const matrix3d 		: Matrix3D = new Matrix3D();					// matrix缓存
		private static const vector3d 		: Vector3D = new Vector3D();					// vector缓存
		
		/** 默认关键帧 */
		private static var _defKeyframe 	: ByteArray;
		
		private var _duration 				: Number; 						// 持续发射时间
		private var _loops 					: Boolean; 						// 循环发射模式
		private var _startDelay 			: Number; 						// 开始延迟时间
		private var _startLifeTime 			: PropData; 					// 生命周期
		private var _startSpeed 			: PropData; 					// 速度
		private var _additionalSpeed		: Vector.<PropRandomTwoConst>;	// 附加速度
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
		private var _time					: Number = 0;					// 时间
		private var _colorOverLifetime 	 	: GradientColor;				// color over lifetime
		private var _keyfsOverLifetime 		: ByteArray;					// 缩放旋转速度 over lifetime
		private var _image					: BitmapData;					// image
		private var _playing				: Boolean;						// 是否正在播放
		private var texture					: Bitmap2DTexture;				// 粒子贴图
		private var blendTexture   			: Bitmap2DTexture;				// color over lifetime贴图
		private var mesh 					: Mesh3D;						// mesh
		private var material				: ParticleMaterial;				// material
		
		/**
		 *  粒子系统
		 */		
		public function ParticleSystem() {
			super();
			this.init();
		}
		
		/**
		 *  初始化粒子系统参数
		 */		
		private function init() : void {
			this.name			 = "Particle";
			this.material 		 = new ParticleMaterial();
			this.mesh			 = new Mesh3D([]);
			this.shape 			 = new SphereShape();
			this.shape.mode 	 = new Plane(1, 1, 1).surfaces[0];				
			this.mesh.bounds	 = shape.mode.bounds;
			this.rate 			 = 10;											
			this.bursts 		 = new Vector.<Point>();		
			this.billboard		 = true;
			this.duration 		 = 5;											
			this.loops 		 	 = true;											
			this.startDelay 	 = 0;											
			this.startSpeed 	 = new PropConst(5);							
			this.startSize 		 = new PropConst(1);
			this.startColor 	 = new PropGradientColor();						
			this.startLifeTime   = new PropConst(5);							
			this.startRotation   = Vector.<PropData>([new PropConst(0), new PropConst(0), new PropConst(0)])
			this.additionalSpeed = Vector.<PropRandomTwoConst>([new PropRandomTwoConst(), new PropRandomTwoConst(), new PropRandomTwoConst()]);;
			this.simulationSpace = false;										
			this.colorLifetime 	 = new GradientColor();
			this.image			 = new DEFAULT_IMG().bitmapData;
			this.keyFrames		 = keyframeDatas;
			this.addComponent(new MeshRenderer(this.mesh, this.material));
		}
		
		/**
		 * 构建粒子系统 
		 * 
		 */		
		public function build() : void {
			this._needBuild = false;
			this.mesh.dispose(true);		// 释放所有的数据
			this.caculateTotalTime();		// 首先计算出粒子的生命周期
			this.caculateParticleNum();		// 计算所有的粒子数量
			this.createParticleMesh();		// 生成粒子对应的网格
			this.shape.generate(this);		// 生成shape对应的数据，包括粒子的位置、方向、uv、索引
			this.createParticleAttribute();	// 更新粒子属性
			this.dispatchEvent(buildEvent); // 完成事件
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
			if (loops) {
				this._totalTime = fillSize * duration;
				this.material.totalLife = fillSize * duration;
			} else {
				this.material.totalLife = this._totalTime * 2; // * 2防止粒子在结束时又重新出现
			}
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
				this.mesh.surfaces.push(surface);
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
		}
		
		/**
		 * 更新粒子系统数据 
		 * @param idx		粒子索引
		 * @param delay		粒子延时
		 */		
		private function updateParticles(idx : int, delay : Number) : void {
			var perSize  : int = 65535 / shape.vertNum;						// 计算出每一个surface存放的粒子数量
			var surface  : Surface3D = this.surfaces[int(idx / perSize)];	// 根据persize计算出surface的索引
			idx = idx % perSize;											// 重置索引为surface的正常索引
			// 粒子数据
			var position : Vector.<Number> = surface.getVertexVector(Surface3D.POSITION);	// 位置
			var velocity : Vector.<Number> = surface.getVertexVector(Surface3D.CUSTOM1);	// 方向
			var lifetimes: Vector.<Number> = surface.getVertexVector(Surface3D.CUSTOM2);	// 时间
			var colors	 : Vector.<Number> = surface.getVertexVector(Surface3D.CUSTOM3);	// 颜色
			var xDelay	 : Number	= delay % duration;								// x轴的延时
			var speed 	 : Number 	= startSpeed.getValue(xDelay);					// 根据延时获取对应的Speed
			var size 	 : Number 	= startSize.getValue(xDelay);					// 根据延时获取对应的Size
			var rotaX 	 : Number 	= startRotation[0].getValue(xDelay);			// 根据延时获取对应的RotationX
			var rotaY 	 : Number 	= startRotation[1].getValue(xDelay);			// 根据延时获取对应的RotationY
			var rotaZ 	 : Number 	= startRotation[2].getValue(xDelay);			// 根据延时获取对应的RotationZ
			var color 	 : Vector3D = startColor.getRGBA(xDelay / duration);		// 根据延时获取对应的Color
			var lifetime : Number 	= startLifeTime.getValue(xDelay);				// 根据延时获取对应的LifeTime
			// 缩放以及旋转
			matrix3d.identity();
			Matrix3DUtils.setScale(matrix3d, size, size, size);
			Matrix3DUtils.setRotation(matrix3d, rotaX, rotaY, rotaZ);
			// const speed
			var speedX : Number = additionalSpeed[0].getValue(delay);
			var speedY : Number = additionalSpeed[1].getValue(delay);
			var speedZ : Number = additionalSpeed[2].getValue(delay);
			// step
			var step2 : int = shape.vertNum * idx * 2;
			var step3 : int = shape.vertNum * idx * 3;
			var step4 : int = shape.vertNum * idx * 4;
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
		
		public function get surfaces() : Vector.<Surface3D> {
			return this.mesh.surfaces;
		}
		
		public function get billboard():Boolean {
			return this.material.billboard;
		}
		
		public function set billboard(value:Boolean):void {
			this.material.billboard = value;
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
				var matrix : Matrix3D = new Matrix3D();
				var datas  : Vector.<Number> = new Vector.<Number>(16 * 11, true);
				for (var i:int = 0; i < ParticleSystem.MAX_KEY_NUM; i++) {
					matrix.identity();
					Matrix3DUtils.setScale(matrix, 1, 1, 1);		// 缩放
					Matrix3DUtils.setRotation(matrix, 0, 0, 0);		// 旋转
					matrix.transpose();
					for (var j:int = 0; j < 16; j++) {
						datas[16 * i + j] = matrix.rawData[j];
					}
					datas[16 * i + 12] = 0;			// x轴位移
					datas[16 * i + 13] = 0;			// y轴位移
					datas[16 * i + 14] = 0;			// z轴位移
				}
				var size : int = datas.length;
				for (var k:int = 0; k < size; k++) {
					bytes.writeFloat(datas[k]);
				}
				_defKeyframe = bytes;
			}
			return _defKeyframe;
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
			if (texture) {
				texture.dispose(true);
			}
			_image = value;
			texture = new Bitmap2DTexture(value);
			material.texture = texture;
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
		 * 粒子系统当前时间 
		 * @return 
		 * 
		 */		
		public function get time():Number {
			return _time;
		}
		
		public function set time(value:Number):void {
			_time = value;
		}
		
		/**
		 * 附加速度 
		 * @param value
		 * 
		 */		
		public function set additionalSpeed(value:Vector.<PropRandomTwoConst>):void {
			_additionalSpeed = value;
			_needBuild = true;
		}
		
		/**
		 * 附加速度 
		 * @return 
		 * 
		 */		
		public function get additionalSpeed():Vector.<PropRandomTwoConst> {
			return _additionalSpeed;
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
		public function get simulationSpace() : Boolean {
			return _simulationSpace;
		}

		/**
		 * 粒子坐标系
		 * @param value
		 *
		 */
		public function set simulationSpace(value : Boolean) : void {
			_simulationSpace = value;
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

		/**
		 * 发射持续时间
		 * @return
		 *
		 */
		public function set duration(value : Number) : void {
			this._duration = value;
			this._needBuild = true;
		}
		
		public function get playing() : Boolean {
			return _playing;
		}
		
		public function play() : void {
			_playing = true;
		}
		
		public function stop() : void {
			_playing = false;	
		}
		
		public function gotoAndStop(time : Number) : void {
			_playing = false;
			_time = time;
		}
		
		public function gotoAndPlay(time : Number) : void {
			_playing = true;
			_time = time;
		}
		
		override public function draw(scene:Scene3D, includeChildren:Boolean=true):void {
			if (!visible) {
				return;
			}
			this.dispatchEvent(enterDrawEvent);
			// build
			if (this._needBuild) {
				this.build();
			}
			// 非循环模式
			if (!loops && time >= startDelay + _totalTime) {
				return;
			}
			// playing
			if (playing) {
				time += Time3D.deltaTime;	
			}
			// 小于延时
			if (time < startDelay) {
				return;
			}
			// draw
			this.material.time = time - startDelay;
			// 绘制组件
			for each (var icom : IComponent in components) {
				if (icom.enable) {
					icom.onDraw(scene);
				}
			}
			// 绘制children
			if (includeChildren) {
				for each (var child : Object3D in children) {
					child.draw(scene, includeChildren);
				}
			}
			// 检测粒子是否播放完成
			if (!loops && time >= startDelay + _totalTime) {
				this.dispatchEvent(AnimDoneEvent);
			}
			this.dispatchEvent(exitDrawEvent);
		}
		
	}
}
