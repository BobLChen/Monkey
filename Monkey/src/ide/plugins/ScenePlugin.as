package ide.plugins {

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import ide.App;
	import ide.events.FrameEvent;
	import ide.events.SceneEvent;
	import ide.panel.ScenePanel;
	
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.camera.lens.PerspectiveLens;
	import monkey.core.collisions.MouseCollision;
	import monkey.core.collisions.collider.Collider;
	import monkey.core.entities.Grid3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Input3D;
	import monkey.core.utils.Time3D;
	
	import ui.core.interfaces.IPlugin;
	
	public class ScenePlugin extends Scene3D implements IPlugin {

		private static const ACTION_NULL 	: String = "action:null";
		private static const ACTION_ORIBIT 	: String = "action:orbit";
		private static const ACTION_PAN 	: String = "action:pan";
		private static const ACTION_ZOOM 	: String = "action:zoom";
		
		private var _scenePanel 	: ScenePanel;			// scene panel
		private var _grid 			: Grid3D;				// 3d网格
		private var _stats 			: FPSStats;				// fps
		private var _mouse			: MouseCollision;		// 拾取器
		private var _app 			: App;					// app
		private var _lastFrame 		: Number;				// 上一帧
		private var _cameraMode 	: String;				// 相机模式
		private var _action 		: String;				// action
		private var _orbitPoint 	: Vector3D;				// 绕点
		private var _orbitDistance 	: Number = 300;			// 距离
		private var _orbitAxis 		: Vector3D;				// 绕轴
		private var _rotationSpeedX : Number = 0;			// speedx
		private var _rotationSpeedY : Number = 0;			// speedy
		private var _showGrid 		: Boolean;				// 是否显示网格
		private var _mouseMoved 	: Boolean;				// mouse moved
		private var _sceneCamera 	: Camera3D;				
		
		public function ScenePlugin() {
			super(App.core.stage);
			this.name = "Scene3D";
			this._cameraMode 	= ACTION_ORIBIT;
			this._action 		= ACTION_NULL;
			this._showGrid 		= true;
			this._mouse			= new MouseCollision();
			this._orbitPoint 	= new Vector3D();
			this._orbitAxis 	= new Vector3D();
			this._sceneCamera   = new Camera3D(new PerspectiveLens());
			this._lastFrame 	= 0;
			this._grid 			= new Grid3D();
			this._scenePanel 	= new ScenePanel(this);
			this._scenePanel.background = false;
			this.camera 	    = this._sceneCamera;
			this.camera.transform.setPosition(50, 100, -200);
			this.camera.transform.lookAt(0, 0, 0);
			this.camera.far 	= 50000;
			this.antialias 		= 4;
			this.autoResize 	= false;
			this.background		= new Color(0x505050);
			this.addEventListener(Event.CONTEXT3D_CREATE, contextCreateEvent);
			this.addEventListener(Scene3D.POST_RENDER_EVENT, onPostRender);
		}
						
		public function get mouse():MouseCollision {
			return _mouse;
		}
		
		private function onPostRender(event:Event) : void {
			this._app.dispatchEvent(new SceneEvent(SceneEvent.POST_RENDER_EVENT));
		}
		
		public function get sceneCamera() : Camera3D {
			return _sceneCamera;
		}
				
		public function get action() : String {
			return _action;
		}

		public function get showGrid() : Boolean {
			return _showGrid;
		}

		public function set showGrid(value : Boolean) : void {
			_showGrid = value;
		}

		public function get lastFrame() : Number {
			return _lastFrame;
		}

		public function set lastFrame(value : Number) : void {
			_lastFrame = value;
		}
		
		private function contextCreateEvent(event : Event) : void {
			Input3D.rightClickEnabled = true;
			this.context.enableErrorChecking = true;
			this._scenePanel.update();
			this._scenePanel.draw();
			this.addEventListener(ENTER_FRAME_EVENT, onEnterFrame);
		}
				
		public function init(app : App) : void {
			this._app = app;
			this._app.scene = this;
			this._app.studio.scene.addPanel(this._scenePanel);
			this._app.studio.scene.open();
			this._app.studio.update();
			this._app.selection.sceneCamera = this._sceneCamera;
			this._app.addEventListener(SceneEvent.CHANGE, sceneChangeEvent);
		}
		
		private function sceneChangeEvent(event:Event) : void {
			this.forEach(function(child:Object3D):void{
				var collider : Collider = child.getComponent(Collider) as Collider;
				if (!collider && child.renderer && child.renderer.mesh) {
					child.addComponent(new Collider(child.renderer.mesh));
				}
			});
			this.mouse.removeCollisionWith(this, true);
			this.mouse.addCollisionWith(this, true);
		}
		
		public function start() : void {
			this._app.selection.objects = [this];
			this._scenePanel.addEventListener(FrameEvent.CHANGE, changeFrame);
		}
		
		private function changeFrame(event : Event) : void {
			var obj : Object3D = this._app.selection.main;
			if (obj) {
				this._lastFrame = this._scenePanel.rule.currentFrame;
				if (obj.animator) {
					obj.animator.gotoAndStop(this._scenePanel.rule.currentFrame);
				}
				if (obj is ParticleSystem) {
					(obj as ParticleSystem).animator.gotoAndStop(this._lastFrame * 1 / this._app.stage.frameRate);
				}
			}
		}
		
		private function onEnterFrame(event:Event) : void {
			
			this._app.dispatchEvent(new SceneEvent(SceneEvent.UPDATE_EVENT));
			
			var inScene : Boolean = this.viewPort.contains(Input3D.mouseX, Input3D.mouseY);
			if (inScene) {
				if (Input3D.mouseDown || Input3D.rightMouseDown || Input3D.middleMouseDown) {
					App.core.stage.focus = null;
				}
				if (Input3D.keyDown(Input3D.CONTROL) && Input3D.keyDown(Input3D.D)) {
					this._app.selection.deleted();
				} else if (Input3D.keyDown(Input3D.CONTROL) && Input3D.keyDown(Input3D.X)) {
					this._app.selection.cut();
				} else if (Input3D.keyDown(Input3D.CONTROL) && Input3D.keyDown(Input3D.V)) {
					this._app.selection.paste();
				}
			}
			
			if (this._scenePanel.play) {
				this._scenePanel.rule.currentFrame = this._lastFrame + Time3D.deltaTime * this._app.stage.frameRate;
				this._lastFrame = this._scenePanel.rule.currentFrame;
				var obj : Object3D = this._app.selection.main;
				if (obj && obj.animator) {
					obj.animator.gotoAndStop(this._scenePanel.rule.currentFrame);
				}
				if (obj && obj is ParticleSystem) {
					(obj as ParticleSystem).animator.gotoAndStop(this._scenePanel.rule.currentFrame * 1.0 / this._app.stage.frameRate);
				}
//				this.gotoAndStop(this._scenePanel.rule.currentFrame);
				this._app.dispatchEvent(new FrameEvent(FrameEvent.CHANGING));
			}
					
			if (this._action == ACTION_NULL) {
				if (inScene && Input3D.rightMouseHit) {
					this._action = ACTION_ORIBIT;
					this._mouseMoved = false;
				} else if (inScene && Input3D.keyHit(Input3D.SPACE)) {
					this._action = ACTION_PAN;
				} else if (inScene && (Input3D.delta != 0)) {
					this._action = ACTION_ZOOM;
				}
			}
			
			if (App.core.stage.focus) {
				var speed : int = Input3D.keyDown(Input3D.SHIFT) ? 2 : 1;
				if (Input3D.keyDown(Input3D.UP)) {
					this.camera.transform.translateZ(_scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.DOWN)) {
					this.camera.transform.translateZ(-_scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.LEFT)) {
					this.camera.transform.translateX(-this._scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.RIGHT)) {
					this.camera.transform.translateX(this._scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.PAGE_UP)) {
					this.camera.transform.translateY(this._scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.keyDown(Input3D.PAGE_DOWN)) {
					this.camera.transform.translateY(-this._scenePanel.footsSpeed.value * speed);
				}
				if (Input3D.rightMouseDown) {
					if (Input3D.keyDown(Input3D.W)) {
						this.camera.transform.translateZ(this._scenePanel.footsSpeed.value * speed);
					}
					if (Input3D.keyDown(Input3D.S)) {
						this.camera.transform.translateZ(-this._scenePanel.footsSpeed.value * speed);
					}
					if (Input3D.keyDown(Input3D.A)) {
						this.camera.transform.translateX(-this._scenePanel.footsSpeed.value * speed);
					}
					if (Input3D.keyDown(Input3D.D)) {
						this.camera.transform.translateX(this._scenePanel.footsSpeed.value * speed);
					}
					if (Input3D.keyDown(Input3D.E)) {
						this.camera.transform.translateY(this._scenePanel.footsSpeed.value * speed);
					}
					if (Input3D.keyDown(Input3D.Q)) {
						this.camera.transform.translateY(-this._scenePanel.footsSpeed.value * speed);
					}
				}
			}
			
			switch (this._action) {
				case ACTION_ORIBIT:  {
					if (this._cameraMode == ACTION_ORIBIT || Input3D.keyDown(Input3D.CONTROL)) {
						this._rotationSpeedX = this._rotationSpeedX * 0.4;
						this._rotationSpeedY = this._rotationSpeedY * 0.4;
						this._rotationSpeedX = this._rotationSpeedX + (Input3D.mouseXSpeed * 0.25);
						this._rotationSpeedY = this._rotationSpeedY + (Input3D.mouseYSpeed * 0.25);
						this.camera.transform.rotateY(this._rotationSpeedX, false, this._orbitPoint);
						this.camera.transform.rotateX(this._rotationSpeedY, true, this._orbitPoint);
					} else {
						this._rotationSpeedX += Input3D.mouseXSpeed * 0.1;
						this._rotationSpeedY += Input3D.mouseYSpeed * 0.1;
						this._rotationSpeedX *= 0.7;
						this._rotationSpeedY *= 0.7;
						this.camera.transform.rotateY(this._rotationSpeedX, false);
						this.camera.transform.rotateX(this._rotationSpeedY, true);
					}
					if (!this._mouseMoved) {
						this._mouseMoved = Math.abs(Input3D.mouseX) > 1 || Math.abs(Input3D.mouseYSpeed) > 1;
					}
					if (Input3D.rightMouseUp || Input3D.middleMouseUp) {
						this._action = ACTION_NULL;
					}
					break;
				}
				case ACTION_ZOOM:  {
					this._orbitDistance = this.camera.transform.world.position.subtract(this._orbitPoint).length;
					if (Input3D.keyDown(Input3D.SHIFT)) {
						this.camera.transform.translateZ((this._orbitDistance * Input3D.delta) / 2000);
					} else {
						this.camera.transform.translateZ((this._orbitDistance * Input3D.delta) / 200);
					}
					this._action = ACTION_NULL;
					break;
				}
				case ACTION_PAN:  {
					this._mouseMoved = Input3D.mouseMoved > 2;
					if (Input3D.middleMouseDown || (Input3D.keyDown(Input3D.SPACE) && Input3D.mouseDown)) {
						this.camera.transform.translateX((-Input3D.mouseXSpeed * this._orbitDistance) / 800);
						this.camera.transform.translateY((Input3D.mouseYSpeed * this._orbitDistance) / 800);
						this._orbitAxis = camera.transform.getDir(false);
						this.camera.transform.localToGlobal(new Vector3D(0, 0, this._orbitDistance), this._orbitPoint);
					}
					this._action = ACTION_NULL;
					break;
				}
				default:  {
					this._action = ACTION_NULL;
					break;
				}
			}
			
			if (Input3D.middleMouseDown || (Input3D.keyDown(Input3D.SPACE) && Input3D.mouseDown)) {
				this.camera.transform.translateX(-Input3D.mouseXSpeed * this._orbitDistance / 800);
				this.camera.transform.translateY(Input3D.mouseYSpeed * this._orbitDistance / 800);
				this._orbitAxis = camera.transform.getDir(false);
				this.camera.transform.localToGlobal(new Vector3D(0, 0, this._orbitDistance), this._orbitPoint);
			}
			
			if (Input3D.middleMouseUp || Input3D.keyUp(Input3D.SPACE)) {
				this._action = ACTION_NULL;
			}
						
		}
				
		public function renderToBitmapData(camera1 : Camera3D, bmp : BitmapData) : void {
			this.context.clear(0, 0, 0, 0);
			this.antialias = 8;
			super.render(camera1);
			this.context.drawToBitmapData(bmp);
		}
		
		override public function render(camera:Camera3D):void {
			if (this._showGrid) {
				this._grid.draw(this);
			}
			super.render(camera);
		}
			
	}
}
