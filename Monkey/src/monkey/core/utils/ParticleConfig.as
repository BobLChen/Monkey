package monkey.core.utils {
	
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.prop.color.ColorConst;
	import monkey.core.entities.particles.prop.color.ColorGradient;
	import monkey.core.entities.particles.prop.color.ColorRandomTwoConst;
	import monkey.core.entities.particles.prop.color.ColorRandomTwoGridient;
	import monkey.core.entities.particles.prop.color.PropColor;
	import monkey.core.entities.particles.prop.value.DataConst;
	import monkey.core.entities.particles.prop.value.DataCurves;
	import monkey.core.entities.particles.prop.value.DataLinear;
	import monkey.core.entities.particles.prop.value.DataRandomTwoConst;
	import monkey.core.entities.particles.prop.value.DataRandomTwoCurves;
	import monkey.core.entities.particles.prop.value.PropData;
	import monkey.core.entities.particles.shape.ParticleShape;
	import monkey.core.entities.particles.shape.SphereShape;
	
	/**
	 * 粒子系统配置 
	 * @author Neil
	 * 
	 */	
	public dynamic class ParticleConfig extends Object {
		
		/** 数据常量类型 */
		public static const DATA_CONST  	: String = "DATA_CONST";
		/** 数据曲线类型 */
		public static const DATA_CURVE  	: String = "DATA_CURVE";
		/** 数据线性类型 */
		public static const DATA_LINEAR 	: String = "DATA_LINEAR";
		/** 数据常量随机 */
		public static const DATA_RAND_CONST	: String = "DATA_RAND_CONST";
		/** 数据曲线随机 */
		public static const DATA_RAND_CURVE : String = "DATA_RAND_CURVE";
		
		/** 颜色常量类型 */
		public static const COLOR_CONST		: String = "COLOR_CONST";
		/** 颜色线性类型 */
		public static const COLOR_GRADIENT	: String = "COLOR_GRADIENT";
		/** 颜色常量随机 */
		public static const COLOR_RAND_CONST: String = "COLOR_RAND_CONST";
		/** 颜色线性随机 */
		public static const COLOR_RAND_GRAD : String = "COLOR_RAND_GRAD";
		
		/** 盒子发射器 */
		public static const SHAPE_BOX		: String = "SHAPE_BOX";
		/** 圆锥发射器 */
		public static const SHAPE_CONE		: String = "SHAPE_CONE";
		/** mesh发射器 */
		public static const SHAPE_MESH		: String = "SHAPE_MESH";
		/** 球形发射器 */
		public static const SHAPE_SPHERE	: String = "SHAPE_SPHERE";
				
		/** 粒子名称 */
		public var name    			: String  = "";
		/** uuid */
		public var uuid				: String  = "";
		/** 广告牌 */
		public var billboard		: Boolean = true;
		/** 持续时间 */
		public var duration			: Number  = 5;
		/** 循环 */
		public var loops			: Boolean =  true;
		/** 开始延时 */
		public var startDelay		: Number  = 0;
		/** 发射频率 */
		public var rate	   			: Number  = 10;
		/** world空间的粒子系统 */
		public var world			: Boolean = false;
		/** 粒子总时间 */
		public var totalFrames		: Number  = 0;
		/** 粒子系统的间隔 */
		public var tototalLife		: Number  = 0;
		
		private var _shape 			: Object  = {};					// 粒子形状
		private var _bursts			: Object  = [];					// 爆炸
		private var _frame			: Object  = [1, 1];				// uv动画
		private var _startSpeed		: Object  = {};					// 初始速度
		private var _startSize		: Object  = {};					// 初始尺寸
		private var _startColor 	: Object  = {};					// 初始颜色
		private var _startLifeTime	: Object  = {};					// 初始生命周期
		private var _startRotation	: Object  = {};					// 初始旋转
		private var _startOffset	: Object  = {};					// 初始位移
		private var _colorLifetime	: Object  = {};					// 运行期颜色
		private var _imageName		: Object  = {};					// 图片
		private var _keyFrames		: Object  = {};					// 关键帧数据
		private var _lifetimeData	: Object  = {};					// 运行期关键帧。
		
		public function ParticleConfig() {
			super();
		}
		
		public function get lifetimeData():Object {
			return _lifetimeData;
		}

		public function set lifetimeData(value:Object):void {
			_lifetimeData = {};
			_lifetimeData.speedX	= getLinearData(value.speedX);
			_lifetimeData.speedY	= getLinearData(value.speedY);
			_lifetimeData.speedZ	= getLinearData(value.speedZ);
			_lifetimeData.axisX		= getLinearData(value.axisX);
			_lifetimeData.axisY		= getLinearData(value.axisY);
			_lifetimeData.axisZ		= getLinearData(value.axisZ);
			_lifetimeData.angle		= getLinearData(value.angle);
			_lifetimeData.size		= getLinearData(value.size);
			_lifetimeData.lifetime	= value.lifetime;
		}
		
		public function get keyFrames():Object {
			return _keyFrames;
		}
		
		/**
		 * 粒子关键帧数据。
		 * @param value
		 * 
		 */		
		public function set keyFrames(value:Object):void {
			var bytes : ByteArray = value as ByteArray;
			bytes.position = 0;
			var datas : Array = [];
			while (bytes.bytesAvailable) {
				datas.push(bytes.readFloat());
			}
			bytes.position = 0;
			_keyFrames = datas;
		}
		
		public function get imageName():Object {
			return _imageName;
		}
		
		/**
		 * 粒子贴图,保存粒子贴图名称
		 * @param value
		 * 
		 */		
		public function set imageName(value:Object):void {
			_imageName = value;
		}
		
		public function get colorLifetime():Object {
			return _colorLifetime;
		}
		
		/**
		 * 运行期颜色变化 
		 * @param value
		 * 
		 */		
		public function set colorLifetime(value:Object):void {
			var color : GradientColor = value as GradientColor;
			_colorLifetime = {};
			_colorLifetime.colors = color.colors;
			_colorLifetime.alphas = color.alphas;
			_colorLifetime.alphaRatios = color.alphaRatios;
			_colorLifetime.colorRatios = color.colorRatios;
		}

		public function get startOffset():Object {
			return _startOffset;
		}

		/**
		 * 初始位移 
		 * @param value
		 * 
		 */		
		public function set startOffset(value:Object):void {
			_startOffset = {};
			_startOffset.x = getDataConfig(value[0]);
			_startOffset.y = getDataConfig(value[1]);
			_startOffset.z = getDataConfig(value[2]);
		}

		public function get startRotation():Object {
			return _startRotation;
		}

		/**
		 * 初始旋转 
		 * @param value
		 * 
		 */		
		public function set startRotation(value:Object):void {
			_startRotation = {};
			_startRotation.x = getDataConfig(value[0]);
			_startRotation.y = getDataConfig(value[1]);
			_startRotation.z = getDataConfig(value[2]);
		}
		
		public function get startLifeTime():Object {
			return _startLifeTime;
		}

		/**
		 * 初始生命周期 
		 * @param value
		 * 
		 */		
		public function set startLifeTime(value:Object):void {
			_startLifeTime = getDataConfig(value as PropData);
		}
		
		public function get startColor():Object {
			return _startColor;
		}
		
		/**
		 * 初始颜色 
		 * @param value
		 * 
		 */		
		public function set startColor(value:Object):void {
			_startColor = getColorConfig(value as PropColor);
		}

		public function get startSize():Object {
			return _startSize;
		}
		
		/**
		 * 初始尺寸 
		 * @param value
		 * 
		 */		
		public function set startSize(value:Object):void {
			_startSize = getDataConfig(value as PropData);
		}

		public function get startSpeed():Object {
			return _startSpeed;
		}
		
		/**
		 * 初始速度 
		 * @param value
		 * 
		 */		
		public function set startSpeed(value:Object):void {
			_startSpeed = getDataConfig(value as PropData);
		}
		
		public function get frame():Object {
			return _frame;
		}
		
		/**
		 * uv动画 
		 * @param value
		 * 
		 */		
		public function set frame(value:Object):void {
			_frame = [value.x, value.y];
		}

		public function get bursts():Object {
			return _bursts;
		}

		/**
		 * 爆炸数据 
		 * @param value
		 * 
		 */		
		public function set bursts(value:Object):void {
			var arr : Vector.<Point> = value as Vector.<Point>;
			var ret : Array = [];
			for each (var p : Point in arr) {
				ret.push(p.x, p.y);
			}
			_bursts = ret;
		}
		
		public function get shape():Object {
			return _shape;
		}
			
		/**
		 * 粒子发射器形状 
		 * @param value
		 * 
		 */		
		public function set shape(value:Object):void {
			_shape = getShapeConfig(value as ParticleShape);
		}
		
		/**
		 *  
		 * @param config
		 * @return 
		 * 
		 */		
		public static function getShape(config : Object) : ParticleShape {
			
			var mode   : Surface3D = new Surface3D();
			mode.setVertexVector(Surface3D.POSITION, Vector.<Number>(config.mode.position), 3);
			mode.setVertexVector(Surface3D.UV0,		 Vector.<Number>(config.mode.uv), 2);
			mode.indexVector = Vector.<uint>(config.mode.index);
			var bounds : Bounds3D = new Bounds3D();
			bounds.min.x = config.mode.bounds[0];
			bounds.min.y = config.mode.bounds[1];
			bounds.min.z = config.mode.bounds[2];
			bounds.max.x = config.mode.bounds[3];
			bounds.max.y = config.mode.bounds[4];
			bounds.max.z = config.mode.bounds[5];
			bounds.length.x = bounds.max.x - bounds.min.x;
			bounds.length.y = bounds.max.y - bounds.min.y;
			bounds.length.z = bounds.max.z - bounds.min.z;
			bounds.center.x = bounds.length.x * 0.5 + bounds.min.x;
			bounds.center.y = bounds.length.y * 0.5 + bounds.min.y;
			bounds.center.z = bounds.length.z * 0.5 + bounds.min.z;
			bounds.radius = Vector3D.distance(bounds.center, bounds.max);
			mode.bounds = bounds;
			
			if (config.type == SHAPE_SPHERE) {
				var sphere : SphereShape = new SphereShape();
				sphere.mode   = mode;
				sphere.radius = config.radius;
				sphere.shell  = config.shell;
				sphere.random = config.random;
				sphere.hemi	  = config.hemi;
				return sphere;
			}
						
			return new SphereShape();
		}
		
		/**
		 * 根据配置获取data 
		 * @param config
		 * @return 
		 * 
		 */		
		public static function getData(config : Object) : PropData {
			if (config.type == DATA_CONST) {
				var constd : DataConst = new DataConst(config.value);
				return constd;
			} else if (config.type == DATA_CURVE) {
				var curve : DataCurves = new DataCurves();
				curve.curve.datas = new Vector.<Point>();
				curve.yValue = config.yValue;
				var i : int = 0;
				while (i < config.value.length) {
					curve.curve.datas.push(new Point(config.value[i], config.value[i + 1]));
					i += 2;
				}
				return curve;
			} else if (config.type == DATA_RAND_CONST) {
				var ranConst : DataRandomTwoConst = new DataRandomTwoConst();
				ranConst.minValue = config.minValue;
				ranConst.maxValue = config.maxValue;
				return ranConst;
			} else if (config.type == DATA_RAND_CURVE) {
				var ranCurve : DataRandomTwoCurves = new DataRandomTwoCurves();
				ranCurve.minCurves.datas = new Vector.<Point>();
				ranCurve.maxCurves.datas = new Vector.<Point>();
				i = 0;
				while (i < config.minCurves.length) {
					ranCurve.minCurves.datas.push(new Point(config.minCurves[i], config.minCurves[i + 1]));
					i += 2;
				}
				i = 0;
				while (i < config.maxCurves.length) {
					ranCurve.minCurves.datas.push(new Point(config.maxCurves[i], config.maxCurves[i + 1]));
					i += 2;
				}
			} else if (config.type == DATA_LINEAR) {
				var linear : DataLinear = new DataLinear();
				linear.curve.datas = new Vector.<Point>();
				i = 0;
				while (i < config.value.length) {
					linear.curve.datas.push(new Point(config.value[i], config.value[i + 1]));
					i += 2;
				}
			}
			return DataConst(0);
		}
		
		/**
		 * 根据配置文件获取colro 
		 * @param config
		 * @return 
		 * 
		 */		
		public static function getColor(config : Object) : PropColor {
			
			if (config.type == COLOR_CONST) {
				var constColor : ColorConst = new ColorConst();
				constColor.color = config.color;
				constColor.alpha = config.alpha;
				return constColor;
			} else if (config.type == COLOR_GRADIENT) {
				var gradColor : ColorGradient = new ColorGradient();
				gradColor.color.setColors(config.colors, config.colorRatios);
				gradColor.color.setAlphas(config.alphas, config.alphaRatios);
				return gradColor;
			} else if (config.type == COLOR_RAND_CONST) {
				var rconstColor : ColorRandomTwoConst = new ColorRandomTwoConst();
				rconstColor.minColor = config.minColor;
				rconstColor.minAlpha = config.minAlpha;
				rconstColor.maxColor = config.maxColor;
				rconstColor.maxAlpha = config.maxAlpha;
				return rconstColor;
			} else if (config.type == COLOR_RAND_GRAD) {
				var rgradColor : ColorRandomTwoGridient = new ColorRandomTwoGridient();
				rgradColor.minColor.setAlphas(config.minColors, config.minColorRatios);
				rgradColor.minColor.setAlphas(config.minAlphas, config.minAlphaRatios);
				rgradColor.maxColor.setAlphas(config.maxColors, config.maxColorRatios);
				rgradColor.maxColor.setAlphas(config.maxAlphas, config.maxAlphaRatios);
				return rgradColor;
			}
			return new ColorConst();
		}
		
		/**
		 * 获取颜色配置 
		 * @param color
		 * @return 
		 * 
		 */		
		public static function getColorConfig(color : PropColor) : Object {
			var ret : Object = {};
			if (color is ColorConst) {
				ret.type = COLOR_CONST;
				var constColor : ColorConst = color as ColorConst;
				ret.color = constColor.color;
				ret.alpha = constColor.alpha;
			} else if (color is ColorGradient) {
				ret.type = COLOR_GRADIENT;
				var gradColor : ColorGradient = color as ColorGradient;
				ret.colors = gradColor.color.colors;
				ret.alphas = gradColor.color.alphas;
				ret.colorRatios = gradColor.color.colorRatios;
				ret.alphaRatios = gradColor.color.alphaRatios;
			} else if (color is ColorRandomTwoConst) {
				ret.type = COLOR_RAND_CONST;
				var rconstColor : ColorRandomTwoConst = color as ColorRandomTwoConst;
				ret.minColor = rconstColor.minColor;
				ret.minAlpha = rconstColor.minAlpha;
				ret.maxColor = rconstColor.maxColor;
				ret.maxAlpha = rconstColor.maxAlpha;
			} else if (color is ColorRandomTwoGridient) {
				ret.type = COLOR_RAND_GRAD;
				var rgradColor : ColorRandomTwoGridient = color as ColorRandomTwoGridient;
				ret.minColors = rgradColor.minColor.colors;
				ret.minAlphas = rgradColor.minColor.alphas;
				ret.minColorRatios = rgradColor.minColor.colorRatios;
				ret.minAlphaRatios = rgradColor.minColor.alphaRatios;
				ret.maxColors = rgradColor.maxColor.colors;
				ret.maxAlphas = rgradColor.maxColor.alphas;
				ret.maxColorRatios = rgradColor.maxColor.colorRatios;
				ret.maxAlphaRatios = rgradColor.maxColor.alphaRatios;
			}
			return ret;
		}
		
		/**
		 *  
		 * @param shape
		 * @return 
		 * 
		 */		
		public static function getShapeConfig(shape : ParticleShape) : Object {
			var aabb : Bounds3D = shape.mode.bounds;
			var ret  : Object 	= {};
			ret.vertNum 		= shape.vertNum;
			ret.mode			= {};
			ret.mode.position 	= shape.mode.getVertexVector(Surface3D.POSITION);
			ret.mode.uv 		= shape.mode.getVertexVector(Surface3D.UV0);
			ret.mode.index		= shape.mode.indexVector;
			ret.mode.bounds 	= [aabb.min.x, aabb.min.y, aabb.min.z, aabb.max.x, aabb.max.y, aabb.max.z];
			if (shape is SphereShape) {
				var ss : SphereShape = shape as SphereShape;
				ret.type 	= SHAPE_SPHERE;
				ret.radius 	= ss.radius;
				ret.shell	= ss.shell;
				ret.random	= ss.random;
				ret.hemi	= ss.hemi;
			}
			return ret;
		}
		
		/**
		 * 获取速度配置文件 
		 * @param data
		 * @return 
		 * 
		 */		
		public static function getDataConfig(data : PropData) : Object {
			var ret : Object = {};
			if (data is DataConst) {
				ret.type = DATA_CONST;
				var constd : DataConst = data as DataConst;
				ret.value= constd.value;
			} else if (data is DataCurves) {
				ret.type = DATA_CURVE;
				var curve : DataCurves = data as DataCurves;
				ret.yValue = curve.yValue;
				ret.value = [];
				for each (var p : Point in curve.curve.datas) {
					ret.value.push(p.x, p.y);
				}
			} else if (data is DataRandomTwoConst) {
				ret.type = DATA_RAND_CONST;
				var ranConst : DataRandomTwoConst = data as DataRandomTwoConst;
				ret.minValue = ranConst.minValue;
				ret.maxValue = ranConst.maxValue;
			} else if (data is DataRandomTwoCurves) {
				ret.type = DATA_RAND_CURVE;
				var ranCurve : DataRandomTwoCurves = data as DataRandomTwoCurves;
				ret.minCurves = [];
				ret.maxCurves = [];
				for each (p in ranCurve.minCurves.datas) {
					ret.minCurves.push(p.x, p.y);
				}
				for each (p in ranCurve.maxCurves.datas) {
					ret.maxCurves.push(p.x, p.y);
				}
			} else if (data is DataLinear) {
				ret.type = DATA_LINEAR;
				var linear : DataLinear = data as DataLinear;
				ret.value = [];
				for each (p in linear.curve.datas) {
					ret.value.push(p.x, p.y);
				}
			}
			return ret;
		}
		
		public static function getLinearData(value : Linears) : Object {
			var ret : Object= {};
			ret.value = [];
			ret.yValue= value.yValue;
			for each (var p : Point in value.datas) {
				ret.value.push(p.x, p.y);
			}
			return ret;
		}
		
	}
}
