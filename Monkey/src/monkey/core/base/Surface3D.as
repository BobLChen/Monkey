package monkey.core.base {
	
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.scene.Scene3D;

	/**
	 * 网格数据 
	 * @author Neil
	 * 
	 */	
	public class Surface3D {
		
		/** 顶点 */
		public static const POSITION		: int = 0;
		/** uv0,默认uv */
		public static const UV0				: int = 1;
		/** uv1 */
		public static const UV1				: int = 2;
		/** 法线 */
		public static const NORMAL			: int = 3;
		/** 权重 */
		public static const SKIN_WEIGHTS 	: int = 4;
		/** 骨骼索引 */
		public static const SKIN_INDICES 	: int = 5;
		/** 切线 */
		public static const TANGENT 		: int = 6;
		/** 自定义数据1 */
		public static const CUSTOM1			: int = 7;
		/** 自定义数据2 */
		public static const CUSTOM2			: int = 8;
		/** 自定义数据3 */
		public static const CUSTOM3			: int = 9;
		/** 自定义数据4 */
		public static const CUSTOM4			: int = 10;
		/** 数据格式数量 */
		public static const LENGTH 			: int = 11;
		
		/** 数据格式 */
		public var formats 		 : Vector.<String>;
		/** 顶点buffer */
		public var vertexBuffers : Vector.<VertexBuffer3D>;
		/** 索引Buffer */
		public var indexBuffer	 : IndexBuffer3D;
		/** 索引数据 */
		public var indexVector 	 : Vector.<uint>;
		/** 三角形数量 */
		public var numTriangles	 : int;
		/** 场景 */
		public var scene 	 	 : Scene3D;		
		
		private var vertexVector : Vector.<Vector.<Number>>;			// 浮点型数据源
		private var vertexBytes	 : Vector.<ByteArray>;					// 二进制数据源
		private var ref 		 : Ref;									// 引用计数器
		private var _bounds		 : Bounds3D								// 包围盒
		private var _disposed	 : Boolean;								// 是否已经被销毁
				
		public function Surface3D() {
			this.ref 		  = new Ref();
			this.formats 	  = new Vector.<String>(LENGTH, true);
			this.vertexBuffers= new Vector.<VertexBuffer3D>(LENGTH, true);
			this.vertexBytes  = new Vector.<ByteArray>(LENGTH, true);
			this.vertexVector = new Vector.<Vector.<Number>>(LENGTH, true);
			this._disposed    = false;
		}
		
		/**
		 * 克隆 
		 * @return 
		 * 
		 */		
		public function clone() : Surface3D {
			var c : Surface3D 	= new Surface3D();
			c.formats 			= formats;
			c.vertexBuffers 	= vertexBuffers;
			c.indexBuffer 		= indexBuffer;
			c.indexVector		= indexVector;
			c.numTriangles		= numTriangles;
			c.scene				= scene;
			c.vertexVector		= vertexVector;
			c.vertexBytes		= vertexBytes;
			c.ref				= ref;
			c._bounds			= _bounds;
			c._disposed			= _disposed;
			ref.ref++;
			return c;
		}
		
		/**
		 * 包围盒 
		 * @return 
		 * 
		 */		
		public function get bounds() : Bounds3D {
			if (!_bounds) {
				updateBoundings();
			}
			return _bounds;
		}
		
		/**
		 * 更新bounds 
		 * 
		 */		
		public function updateBoundings() : void {
			this.bounds = new Bounds3D();
			this.bounds.max.setTo(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			this.bounds.min.setTo(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			var positions : Vector.<Number> = getVertexVector(Surface3D.POSITION);
			var size : int = positions.length;
			var i : int = 0;
			var x : Number = 0;
			var y : Number = 0;
			var z : Number = 0;
			while (i < size) {
				x = positions[i + 0];
				y = positions[i + 1];
				z = positions[i + 2];
				this.bounds.min.x = Math.min(x, bounds.min.x);
				this.bounds.min.y = Math.min(y, bounds.min.y);
				this.bounds.min.z = Math.min(z, bounds.min.z);
				this.bounds.max.x = Math.max(x, bounds.max.x);
				this.bounds.max.y = Math.max(y, bounds.max.y);
				this.bounds.max.z = Math.max(z, bounds.max.z);
				i += 3;
			}
			this.bounds.length.x = this.bounds.max.x - this.bounds.min.x;
			this.bounds.length.y = this.bounds.max.y - this.bounds.min.y;
			this.bounds.length.z = this.bounds.max.z - this.bounds.min.z;
			this.bounds.center.x = this.bounds.length.x * 0.5 + this.bounds.min.x;
			this.bounds.center.y = this.bounds.length.y * 0.5 + this.bounds.min.y;
			this.bounds.center.z = this.bounds.length.z * 0.5 + this.bounds.min.z;
			this.bounds.radius = Vector3D.distance(bounds.center, bounds.max);
		}
		
		/**
		 * 包围盒 
		 * @param value
		 * 
		 */		
		public function set bounds(value:Bounds3D) : void {
			_bounds = value;
		}

		/**
		 * 是否已经被销毁 
		 * @return 
		 * 
		 */		
		public function get disposed():Boolean {
			return _disposed;
		}

		/**
		 * 设置数据源 
		 * @param type		数据类型
		 * @param data		数据
		 * @param size		数据格式
		 * 
		 */		
		public function setVertexVector(type : int, data : Vector.<Number>, size : int) : void {
			this.formats[type] = "float" + size;
			this.vertexVector[type] = data;
		}
		
		/**
		 * 获取对应格式的数据 
		 * @param type		数据类型
		 * @return 			data
		 * 
		 */		
		public function getVertexVector(type : int) : Vector.<Number> {
			if (this.vertexVector[type]) {
				return this.vertexVector[type];
			}
			var bytes : ByteArray = this.vertexBytes[type];
			var datas : Vector.<Number> = new Vector.<Number>();
			bytes.position = 0;
			while (bytes.bytesAvailable > 0) {
				datas.push(bytes.readFloat());
			}
			this.vertexVector[type] = datas;
			return datas;
		}
		
		/**
		 * 获取对应格式的数据 
		 * @param type		数据类型
		 * @return 			data
		 * 
		 */		
		public function getVertexBytes(type : int) : ByteArray {
			if (this.vertexBytes[type]) {
				return this.vertexBytes[type];
			}
			var bytes : ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			var datas : Vector.<Number> = this.vertexVector[type];
			var size  : int = datas.length;
			for (var i:int = 0; i < size; i++) {
				bytes.writeFloat(datas[i]);
			}
			this.vertexBytes[type] = bytes;
			return bytes;
		}
		
		/**
		 * 设置数据源
		 * @param type		数据类型
		 * @param data		数据
		 * @param size		数据格式
		 * 
		 */		
		public function setVertexBytes(type : int, data : ByteArray, size : int) : void {
			this.formats[type] = "float" + size;
			this.vertexBytes[type] = data;
		}
		
		/**
		 * 从显卡卸载数据
		 * @param force		是否忽略引用计数，强制卸载
		 * 
		 */		
		public function download(force : Boolean = false) : void {
			if (ref.ref > 0 && !force) {
				return;
			}
			// 从场景中移除
			if (scene) {
				scene.removeEventListener(Scene3D.CREATE, contextEvent);
				var idx : int = scene.surfaces.indexOf(this);
				if (idx != -1) {
					scene.surfaces.splice(idx, 1);
				}
			}
			scene = null;
			unloadVertexBuffer();
			unloadIndexBuffer();
		}
		
		/**
		 * 卸载顶点buffer 
		 */		
		private function unloadVertexBuffer() : void {
			for (var i:int = 0; i < LENGTH; i++) {
				if (!vertexBuffers[i]) {
					continue;
				}
				vertexBuffers[i].dispose();
				vertexBuffers[i] = null;
			}
		}
		
		/**
		 * 卸载索引buffer 
		 */		
		private function unloadIndexBuffer() : void {
			if (indexBuffer) {
				indexBuffer.dispose();
				indexBuffer = null;
			}
		}
		
		/**
		 * 上传 
		 * @param context
		 * 
		 */		
		public function upload(scene3d : Scene3D) : void {
			if (scene == scene3d) {
				return;
			}
			scene = scene3d;
			contextEvent();
		}
		
		/**
		 * context event
		 */
		protected function contextEvent(e : Event = null) : void {
			this.scene.addEventListener(Scene3D.CREATE, contextEvent, false, 0, true);
			if (this.scene.surfaces.indexOf(this) == -1) {
				this.scene.surfaces.push(this);
			}
			this.updateVertexBuffer();
			this.updateIndexBuffer();
		}
		
		/**
		 * 更新索引buffer 
		 * 
		 */		
		private function updateIndexBuffer() : void {
			this.unloadIndexBuffer();
			var size : int = indexVector.length;
			this.indexBuffer = scene.context.createIndexBuffer(size);
			this.indexBuffer.uploadFromVector(indexVector, 0, size);
			this.numTriangles = size / 3;
		}
		
		/**
		 * 更新顶点buffer 
		 */		
		private function updateVertexBuffer() : void {
			this.unloadVertexBuffer();
			var num  : int = -1;
			var size : int = -1;
			for (var i:int = 0; i < LENGTH; i++) {
				size = getSizeByFormat(formats[i]);
				if (vertexBytes[i]) {					// 优先上传bytes
					num = vertexBytes[i].length / 4 / size;
					vertexBuffers[i] = scene.context.createVertexBuffer(num, size);
					vertexBuffers[i].uploadFromByteArray(vertexBytes[i], 0, 0, num);
				} else if (vertexVector[i]) {			// 使用vector上传
					num  = vertexVector[i].length / size;
					vertexBuffers[i] = scene.context.createVertexBuffer(num, size);
					vertexBuffers[i].uploadFromVector(vertexVector[i], 0, num);
				}
			}
		}
		
		/**
		 * 根据format获取尺寸 
		 * @param format	数据格式
		 * @return 			szie
		 * 
		 */		
		private function getSizeByFormat(format : String) : int {
			switch(format) {
				case Context3DVertexBufferFormat.FLOAT_1: {
					return 1;
					break;
				}
				case Context3DVertexBufferFormat.FLOAT_2: {
					return 2;
					break;
				}
				case Context3DVertexBufferFormat.FLOAT_3: {
					return 3;
					break;
				}
				case Context3DVertexBufferFormat.FLOAT_4: {
					return 4;
					break;
				}
			}
			return -1;
		}
		
		/**
		 * 销毁surface3d 
		 */		
		public function dispose(force : Boolean = false) : void {
			if (disposed) {
				return;
			}
			this._disposed = true;
			// 存在克隆对象，引用计数减一
			if (ref.ref > 0 && !force) {
				ref.ref--;
				return;
			}
			this.download(true);
			// 清空内存数据
			for (var i:int = 0; i < LENGTH; i++) {
				if (vertexVector[i]) {
					vertexVector[i].length = 0;
					vertexVector[i] = null;
				}
				if (vertexBytes[i]) {
					vertexBytes[i].clear();
					vertexBytes[i] = null;
				}
			}
			// 
			this.formats = null;
			this.vertexBytes = null;
			this.vertexVector = null;
		}
	}
}
