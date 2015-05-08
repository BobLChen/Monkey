package monkey.core.scene {

	import flash.display.DisplayObject;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.camera.lens.PerspectiveLens;
	import monkey.core.shader.Shader3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Input3D;
	import monkey.core.utils.Time3D;
		
	/**
	 * scene3d 
	 * @author Neil
	 * 
	 */	
	public class Scene3D extends Object3D {
		
		/** 不支持该profile */
		public static const UNSUPORT_PROFILE_EVENT 	: String = "Scene3D:UNSUPORT_PROFILE";
		/** 软解模式 */
		public static const SOFTWARE_EVENT 			: String = "Scene3D:SOFTWARE";
		/** 创建完成 */
		public static const CREATE_EVENT   			: String = Event.CONTEXT3D_CREATE;
		/** context被销毁 */
		public static const CONTEXT_DISPOSE 		: String = "Scene3D:DISPOSED";
		/** pre render */
		public static const PRE_RENDER_EVENT 		: String = "Scene3D:PRE_RENDER";
		/** post render */
		public static const POST_RENDER_EVENT 		: String = "Scene3D:POST_RENDER";
		/** render */
		public static const RENDER_EVENT			: String = "Scene3D:RENDER";
		/** enterframe事件 */
		private static var enterFrameEvent : Event = new Event(ENTER_FRAME_EVENT);
		/** exitframe事件 */
		private static var exitFrameEvent  : Event = new Event(EXIT_FRAME_EVENT);
		/** pre render */
		private static var preRenderEvent  : Event = new Event(PRE_RENDER_EVENT);
		/** post render */
		private static var postRenderEvent : Event = new Event(POST_RENDER_EVENT);
		/** render event */
		private static var renderEvent	   : Event = new Event(RENDER_EVENT);
		
		/** stage3d设备索引 */
		private static var stage3dIdx 	: int = 0;
		/** 所有网格数据 */
		public var surfaces				: Vector.<Surface3D>;
		/** 所有材质数据 */
		public var textures				: Vector.<Texture3D>;	
		/** 所有的shader */
		public var shaders				: Vector.<Shader3D>;
		/** 跳过本次渲染 */
		public var skipCurrentRender	: Boolean;
		
		private var renderList			: Vector.<Object3D>;	// 渲染列表
		private var _container 			: DisplayObject;		// 2d容器
		private var _backgroundColor 	: Color;				// 背景色
		private var _clearColor			: Vector3D;				// 后台缓冲区颜色
		private var _stage3d			: Stage3D;				// stage3d
		private var _context3d			: Context3D;			// context3d
		private var _autoResize			: Boolean;				// 是否自动缩放大小
		private var _viewPort			: Rectangle;			// viewport
		private var _antialias			: int;					// 抗锯齿等级
		private var _paused				: Boolean;				// 是否暂停
		private var _camera				: Camera3D;				// camera
				
		/**
		 * @param dispObject
		 */		
		public function Scene3D(dispObject : DisplayObject) {
			super();
			this.renderList = new Vector.<Object3D>();
			this.surfaces	= new Vector.<Surface3D>();
			this.textures   = new Vector.<Texture3D>();
			this.shaders	= new Vector.<Shader3D>();
			this.container  = dispObject;
			this.antialias  = 4;
			this.background = new Color(0x333333);
			this.camera     = new Camera3D(new PerspectiveLens());
			this.camera.transform.setPosition(0, 0, -100);
			if (this.container.stage) {
				this.addedToStageEvent();
			} else {
				this.container.addEventListener(Event.ADDED_TO_STAGE, addedToStageEvent, false, 0, true);
			}
		}
				
		/**
		 * 获取相机 
		 * @return 
		 * 
		 */		
		public function get camera():Camera3D {
			return _camera;
		}
		
		/**
		 * 设置相机 
		 * @param value
		 * 
		 */		
		public function set camera(value:Camera3D):void {
			if (value == _camera) {
				return;
			}
			_camera = value;
			if (_camera && viewPort) {
				_camera.lens.setViewPort(0, 0, viewPort.width, viewPort.height);
			}
		}
		
		/**
		 * 获取抗锯齿等级 
		 * @return 
		 * 
		 */		
		public function get antialias():int {
			return _antialias;
		}

		/**
		 * 设置抗锯齿等级 
		 * @param value
		 * 
		 */		
		public function set antialias(value:int):void {
			if (value == _antialias) {
				return;
			}
			_antialias = value;
			if (viewPort && _stage3d && _stage3d.context3D) {
				_stage3d.context3D.configureBackBuffer(viewPort.width, viewPort.height, value);
				_stage3d.context3D.clear(background.r, background.g, background.b, background.alpha);
			}
		}
		
		/**
		 * scene视口 
		 * @return 
		 * 
		 */		
		public function get viewPort():Rectangle {
			return _viewPort;
		}
		
		/**
		 * 设置3D视口 
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * 
		 */		
		public function setViewPort(x : int, y : int, width : int, height : int) : void {
			if (_viewPort && _viewPort.x == x && _viewPort.y == y && _viewPort.width == width && _viewPort.height == height) {
				return;
			}
			if (width <= 50) {
				width = 50;
			}
			if (height <= 50) {
				height = 50;
			}
			if (context && context.driverInfo.indexOf("Software") != -1) {
				if (width > 2048) {
					width = 2048;
				}
				if (height > 2048) {
					height = 2048;
				}
			}
			if (!_viewPort) {
				_viewPort = new Rectangle();
			}
			_viewPort.setTo(x, y, width, height);
			if (_camera) {
				_camera.lens.setViewPort(0, 0, width, height);
			}
			if (context) {
				stage3d.x = x;
				stage3d.y = y;
				context.configureBackBuffer(width, height, antialias);
				context.clear(background.r, background.g, background.b, background.alpha);
			}
		}
		
		/**
		 * 被添加到舞台 
		 * @param e
		 * 
		 */		
		private function addedToStageEvent(e : Event = null) : void {
			this.container.removeEventListener(Event.ADDED_TO_STAGE, addedToStageEvent);
			// 初始化input3d
			if (stage3dIdx == 0) {
				Input3D.initialize(this.container.stage);
			}
			if (stage3dIdx >= 4) {
				throw new Error("无法创建4个以上的scene");
			}
			this._stage3d = container.stage.stage3Ds[stage3dIdx];
			this.stage3d.addEventListener(Event.CONTEXT3D_CREATE, stageContextEvent, false, 0, true);
			// 申请context3d
			try {
				this.stage3d.requestContext3D(Context3DRenderMode.AUTO, Device3D.profile);
			} catch (e : Error) {
				this.dispatchEvent(new Event(UNSUPORT_PROFILE_EVENT));
				this.stage3d.requestContext3D(Context3DRenderMode.AUTO);
			}
			stage3dIdx++;
		}
		
		private function stageContextEvent(event:Event) : void {
			this.resume();
			this._context3d = stage3d.context3D;
			if (context.driverInfo.indexOf("Software") != -1) {
				this.dispatchEvent(new Event(SOFTWARE_EVENT));		// 软解模式
			} else if (context.driverInfo.indexOf("disposed") != -1) {
				this.dispatchEvent(new Event(CONTEXT_DISPOSE));		// context被销毁
				this.pause(); 									// context被销毁，需要暂停渲染
			}
			if (!this.viewPort) {
				this.setViewPort(0, 0, container.stage.stageWidth, container.stage.stageHeight);
			} else {
				this.stage3d.x = viewPort.x;
				this.stage3d.y = viewPort.y;
				this.context.configureBackBuffer(viewPort.width, viewPort.height, antialias);
				this.context.clear();
			}
			Time3D.update();
			this.container.addEventListener(Event.ENTER_FRAME,		  onEnterFrame);
			this.dispatchEvent(event);
		}
		
		/**
		 * enterFrame 
		 * @param event
		 * 
		 */		
		private function onEnterFrame(event : Event) : void {
			if (stage3dIdx == 1) {
				Input3D.update();	// 输入
				Time3D.update();	// 时间
			}
			if (this.paused) {
				return;
			}
			this.setupFrame(this.camera);
			this.update(true);
			this.setupFrame(this.camera);
			this.renderScene();
			if (stage3dIdx == 1) {
				Input3D.clear();
			}
		}
		
		/**
		 * 绘制场景 
		 * 
		 */		
		private function renderScene() : void {
			if (this.context) {
				this.context.clear(background.r, background.g, background.b, background.alpha);
				this.context.setDepthTest(Device3D.defaultDepthWrite, Device3D.defaultCompare);
				this.context.setCulling(Device3D.defaultCullFace);
				this.context.setBlendFactors(Device3D.defaultSourceFactor, Device3D.defaultDestFactor);
				this.skipCurrentRender = false;
				this.dispatchEvent(preRenderEvent);
				if (!this.skipCurrentRender) {
					this.dispatchEvent(renderEvent);
					this.render();
				}
				this.dispatchEvent(postRenderEvent);
				this.context.present();
			}
		}
		
		/**
		 * 设置相机 
		 * @param camera
		 * 
		 */		
		public function setupFrame(camera : Camera3D) : void {
			
			Device3D.triangles = 0;
			Device3D.drawCalls = 0;
			Device3D.drawOBJNum= 0;
			Device3D.camera    = camera;
			Device3D.scene     = this;
			
			Device3D.proj.copyFrom(Device3D.camera.projection);
			Device3D.view.copyFrom(Device3D.camera.view);
			Device3D.viewProjection.copyFrom(Device3D.camera.viewProjection);
			Device3D.camera.transform.getPosition(false, Device3D.cameraPos);
			Device3D.camera.transform.getDir(false, Device3D.cameraDir);
			Device3D.defaultDirectLight.transform.copyfrom(Device3D.camera.transform);
			Device3D.defaultDirectLight.transform.updateTransforms(true);
			
			if (camera.clipScissor) {
				this.context.setScissorRectangle(camera.lens.viewPort);
			} else {
				this.context.setScissorRectangle(null);
			}
		}
		
		/**
		 * 渲染 
		 * @param camera
		 * 
		 */		
		public function render() : void {
			for each (var pivot  : Object3D in renderList) {
				pivot.draw(this, false);
			}
		}
		
		override public function update(includeChildren : Boolean) : void {
			this.dispatchEvent(enterFrameEvent);
			for each (var pivot  : Object3D in renderList) {
				pivot.update(false);
			}
			this.dispatchEvent(exitFrameEvent);
		}
		
		/**
		 *  恢复渲染
		 */		
		public function resume() : void {
			_paused = false;
		}
		
		/**
		 *  暂停渲染
		 */		
		public function pause() : void {
			_paused = true;	
		}
		
		/**
		 * 暂停渲染 
		 * @return 
		 * 
		 */		
		public function get paused() : Boolean {
			return _paused;
		}
		
		/**
		 * 自适应 
		 * @return 
		 * 
		 */		
		public function get autoResize():Boolean {
			return _autoResize;
		}
		
		/**
		 * 自适应 
		 * @param value
		 * 
		 */		
		public function set autoResize(value:Boolean):void {
			if (value == _autoResize) {
				return;
			}
			_autoResize = value;
			if (container && container.stage) {
				if (value) {
					container.stage.align = StageAlign.TOP_LEFT;
					container.stage.scaleMode = StageScaleMode.NO_SCALE;
					container.stage.addEventListener(Event.RESIZE, onStageResize, false, 0, true);
				} else {
					container.stage.removeEventListener(Event.RESIZE, onStageResize);
				}
			}
		}
		
		private function onStageResize(event:Event) : void {
			if (_autoResize) {
				this.setViewPort(0, 0, container.stage.stageWidth, container.stage.stageHeight);
			}
		}
		
		/**
		 * context 
		 * @return 
		 * 
		 */		
		public function get context():Context3D {
			return _context3d;
		}
		
		/**
		 * stage3d 
		 * @return 
		 * 
		 */		
		public function get stage3d():Stage3D {
			return _stage3d;
		}
				
		/**
		 * 2d显示对象
		 * @return 
		 * 
		 */		
		public function get container():DisplayObject {
			return _container;
		}
		
		/**
		 * 2d显示对象
		 * @param value
		 * 
		 */			
		public function set container(value:DisplayObject):void {
			_container = value;
		}

		/**
		 * 背景色 
		 * @return 
		 * 
		 */		
		public function get background():Color {
			return _backgroundColor;
		}
		
		/**
		 * 背景色 
		 * @param value
		 * 
		 */		
		public function set background(value:Color):void {
			_backgroundColor = value;
		}
				
		public function show() : void {
			if (stage3d) {
				stage3d.visible = true;
			}
		}
		
		public function hide() : void {
			if (stage3d) {
				stage3d.visible = false;
			}
		}
		
		override public function dispose(force : Boolean = true):void {
			while (this.textures.length > 0) {
				this.textures[0].dispose(true);
			}
			while (this.surfaces.length > 0) {
				this.surfaces[0].dispose(true);
			}
			while (this.shaders.length > 0) {
				this.shaders[0].dispose();
			}
			this.children.length = 0;
			if (this.context) {
				this.context.dispose();
			}
		}
		
		/**
		 * 释放显存，shader由自己释放。
		 */		
		public function freeMemory() : void {
			while (this.textures.length > 0) {
				this.textures[0].download(true);
			}
			while (this.surfaces.length > 0) {
				this.surfaces[0].download(true);
			}
			this.children.length = 0;
		}
		
		public function removeFromScene(pivot:Object3D) : void {
			var idx : int = renderList.indexOf(pivot);
			if (idx != -1) {
				renderList.splice(idx, 1);
			}
		}
		
		public function addToScene(pivot:Object3D) : void {
			var left  : int = 0;
			var right : int = renderList.length;
			var value : int = pivot.layer;
			var middle: int = 0;
			while (left < right) {
				middle = (left + right) >>> 1;
				if (renderList[middle].layer == value) {
					break;
				}
				if (value > renderList[middle].layer) {
					middle++;
					left = middle;
				} else {
					right = middle;
				}
			}
			renderList.splice(middle, 0, pivot);
		}
	}
}
