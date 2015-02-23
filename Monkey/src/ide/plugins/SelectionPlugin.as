package ide.plugins {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import ide.App;
	import ide.events.SceneEvent;
	import ide.panel.Gizmo;
	import ide.utils.MathUtils;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.entities.Axis3D;
	import monkey.core.entities.Cube;
	import monkey.core.entities.DebugBounds;
	import monkey.core.entities.DebugCamera;
	import monkey.core.entities.DebugLight;
	import monkey.core.entities.DebugWireframe;
	import monkey.core.entities.Mesh3D;
	import monkey.core.light.Light3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Input3D;
	
	import ui.core.interfaces.IPlugin;

	public class SelectionPlugin implements IPlugin {

		private static const wires 		: Dictionary = new Dictionary();
				
		private var _app 				: App;					// app
		private var _boundings			: DebugBounds;			// bounds线框
		private var _padding			: Number = 0.001;		// padding
		private var _light 				: DebugLight;			// light线框
		private var _axis 				: Axis3D;				// 轴
		private var _selection 			: Array;				// 选中物体
		private var _currentGizmo 		: Gizmo;				// gizmo
		private var _showAxis 			: Boolean = true;		// 显示坐标系
		private var _showBoundings 		: Boolean = true;		// 显示包围盒
		private var _showWireframe 		: Boolean = true;		// 显示线框
		private var _showPivots 		: Boolean = true;		// 显示Pivot图标
		private var _showLights 		: Boolean = true;		// 显示灯光图标
		private var _showCameras 		: Boolean = true;		// 显示相机图标
		private var _showShapes 		: Boolean = true;		// 显示shape
		private var _showParticles 		: Boolean = true;		// 显示粒子图标
		private var _selecting 			: Boolean = false;		// 选中状态
		private var _sprite 			: Sprite;				// sprite
		private var _showGizmo 			: Boolean = true;		// 显示gizmo
		private var gizmos 				: Dictionary;			// gizmos
		private var cameraGizmos		: Dictionary;			// debug cameras
		
		public function SelectionPlugin() {
			var cube : Object3D = new Object3D();
			cube.addComponent(new Cube(1, 1, 1));
			this._boundings   = new DebugBounds(cube);
			this._light 	  = new DebugLight(null, 0xFFCB00, 0.75);
			this._selection   = [];
			this._sprite 	  = new Sprite();
			this._axis 		  = new Axis3D();
			this.gizmos 	  = new Dictionary(true);
			this.cameraGizmos = new Dictionary(true);
		}
		
		public function init(app : App) : void {
			this._app = app;
			this._app.addEventListener(SceneEvent.POST_RENDER_EVENT, 	postRenderEvent, 		false, 0, true);
			this._app.addEventListener(SceneEvent.UPDATE_EVENT, 		updateEvent, 			false, -1000);
			this._app.addMenu("Helper/ShowAxis",		showAxis);
			this._app.addMenu("Helper/ShowWireframe",	showWireframe);
			this._app.addMenu("Helper/ShowObject",		showObjects);			
			this._app.addMenu("Helper/SHowLights",		showLights);
			this._app.addMenu("Helper/ShowCameras",		showCameras);
			this._app.addMenu("Helper/ShowParticles",	showParticles);
			this._app.addMenu("Helper/ShowBoundings",	showBoundings);
			this._app.addMenu("Helper/ShowShapes",		showShapes);
			this._app.addMenu("Helper/ShowGizmo",		showGizmo);
			this._app.addMenu("Helper/ResetCamera",		resetCamera);
		}
		
		private function resetCamera(e : Event) : void {
			this._app.scene.camera.transform.setPosition(0, 100, -100);
			this._app.scene.camera.transform.lookAt(0, 0, 0);
		}
		
		private function showGizmo(e : Event) : void {
			this._showGizmo = !this._showGizmo;
		}
		
		private function showShapes(e : Event) : void {
			this._showShapes = !this._showShapes;
		}

		private function showBoundings(e : Event) : void {
			this._showBoundings = !this._showBoundings;
		}

		private function showParticles(e : Event) : void {
			this._showParticles = !this._showParticles;
		}

		private function showCameras(e : Event) : void {
			this._showCameras = !this._showCameras;
		}

		private function showLights(e : Event) : void {
			this._showLights = !this._showLights;
		}

		private function showObjects(e : Event) : void {
			this._showPivots = !this._showPivots;
		}

		private function showWireframe(e : Event) : void {
			this._showWireframe = !this._showWireframe;
		}

		private function showAxis(e : Event) : void {
			this._showAxis = !this._showAxis;
		}
		
		private function updateEvent(event : SceneEvent) : void {
			if (event.isDefaultPrevented()) {
				return;
			}
			var inScene : Boolean = this._app.scene.viewPort.contains(Input3D.mouseX, Input3D.mouseY);
			if (inScene && Input3D.mouseHit && !Input3D.keyDown(Input3D.CONTROL)) {
				if (this._currentGizmo != null) {
					if (Input3D.keyDown(Input3D.ALTERNATE)) {
						this._app.selection.remove([this._currentGizmo.object]);
					} else if (this._app.selection.objects.indexOf(this._currentGizmo.object) == -1) {
						this._app.selection.objects = [];
						this._app.selection.push([this._currentGizmo.object]);
					}
					this._currentGizmo = null;
				} 
//				else if (ScenePlugin(this._app.scene).mouse.test(Studio.stage.mouseX, Studio.stage.mouseY)) {
//					var pickInfo : CollisionInfo = ScenePlugin(this._app.scene).mouse.data[0];
//					if (Input3D.keyDown(Input3D.CONTROL)) {
//						this._selecting = true;
//					} else if (this._app.selection.objects.indexOf(pickInfo.mesh) == -1) {
//						this._app.selection.objects = [];
//						this._app.selection.push([pickInfo.mesh]);
//						this._app.selection.shader = (pickInfo.mesh as Mesh3D).material.shader;
//						this._app.selection.surface = pickInfo.geometry;
//					}
//				} 
				else if (!Input3D.keyDown(Input3D.CONTROL) || !Input3D.keyDown(Input3D.ALTERNATE)) {
					this._app.selection.objects = [];
				}
			}
		}
		
		private function postRenderEvent(event : Event) : void {
			// 显示线框
			if (this._showWireframe) {
				for each (var pivot : Object3D in this._app.selection.objects) {
					if (!wires[pivot]) {
						wires[pivot] = new DebugWireframe(pivot, 0xFFFFFF, 0.25);
					}
					var wireframe : DebugWireframe = wires[pivot];
					wireframe.transform.world = pivot.transform.world;
					wireframe.draw(Device3D.scene);
				}
			}
			// 显示图标
			if (this._showGizmo) {
				this._app.scene.forEach(drawGizmos);
				var gizmos : Array = [];
				var gizmo : Gizmo  = null;
				for each (gizmo in this.gizmos) {
					gizmo.selected = false;
					gizmos.push(gizmo);
				}
				gizmos.sortOn('w', Array.NUMERIC);
				for each (gizmo in gizmos) {
					if (gizmo.visible && gizmo.object.visible) {
						if (this._app.selection.objects.indexOf(gizmo.object) != -1) {
							gizmo.selected = true;
						}
						this._sprite.addChildAt(gizmo, 0);
					}
				}
			}
			this.overlayRender();
		}
		
		/**
		 * 绘制图标 
		 * @param object3d
		 * 
		 */		
		private function drawGizmos(object3d : Object3D) : void {
			var pos : Vector3D = object3d.getScreenCoords();
			var gizmo : Gizmo  = gizmos[object3d];
			if (!gizmo) {
				gizmo = new Gizmo(object3d);
				this.gizmos[object3d] = gizmo;
			}
			gizmo.addEventListener(MouseEvent.MOUSE_DOWN, gizmoMouseDown, false, 0, true);
			gizmo.x = pos.x;
			gizmo.y = pos.y;
			gizmo.w = pos.w;
			gizmo.scaleX = gizmo.scaleY = 1;
			gizmo.visible = gizmo.w > 0;
			if (!object3d.visible) {
				gizmo.visible = false;
			}
			// camera
			if (object3d is Camera3D && this._app.selection.objects.indexOf(object3d) != -1) {
				var debugCamera : DebugCamera = cameraGizmos[object3d];
				if (!debugCamera) {
					debugCamera = new DebugCamera(object3d as Camera3D);
					cameraGizmos[object3d] = debugCamera;
				}
				debugCamera.transform.world = object3d.transform.world;
				debugCamera.draw(Device3D.scene);
			// light
			} else if (object3d is Light3D && this._app.selection.objects.indexOf(object3d) != -1) {
				this._light.light = object3d as Light3D;
				this._light.draw(Device3D.scene);
			}
		}
		
		private function gizmoMouseDown(event : MouseEvent) : void {
			this._currentGizmo = event.target as Gizmo;
		}
		
		private function overlayRender() : void {
			for each (var pivot : Object3D in this._app.selection.objects) {
				if (pivot is Scene3D || !pivot.visible) {
					continue;
				}
				// 显示包围盒
				if (this._showBoundings) {
					var bounds : Bounds3D = getBounds(pivot);
					var center : Vector3D = bounds.center;
					var scale  : Vector3D = pivot.transform.getScale();
					pivot.transform.localToGlobal(center, center);
					this._boundings.transform.local.copyFrom(pivot.transform.world);
					this._boundings.transform.setPosition(center.x, center.y, center.z);
					this._boundings.transform.setScale(scale.x * bounds.length.x + _padding, scale.y * bounds.length.y + _padding, scale.z * bounds.length.z + _padding);
					this._boundings.draw(this._app.scene);
					this._app.selection.bounds = scale;
				}
				// 显示坐标轴
				if (this._showAxis) {
					var dir    : Vector3D = this._app.scene.camera.transform.getDir(true);
					var dist   : Number = MathUtils.pointPlane(dir, this._app.scene.camera.transform.getPosition(false), pivot.transform.getPosition(false)) * 2 * this._app.scene.camera.zoom / this._app.scene.viewPort.width;
					var scale0 : Number = Math.max(Math.abs(dist * 1.3), 0.0001);
					this._axis.transform.local.copyFrom(pivot.transform.world);
					this._axis.transform.setScale(scale0, scale0, scale0);
					this._axis.draw(this._app.scene);
				}
			}
		}
		
		private function getBounds(pivot : Object3D) : Bounds3D {
			
			var bounds : Bounds3D = new Bounds3D();
			var mesh : Mesh3D = pivot.getComponent(Mesh3D) as Mesh3D;
			if (mesh && pivot.children.length == 0) {
				bounds.copyFrom(mesh.bounds);
				return bounds;
			} else if (!mesh && pivot.children.length == 0) {
				return bounds;
			}
			
			bounds.max.setTo(Number.MIN_VALUE, Number.MIN_VALUE, Number.MIN_VALUE);
			bounds.min.setTo(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			
			pivot.forEach(function(child : Object3D) : void {
				mesh = child.getComponent(Mesh3D) as Mesh3D;
				if (mesh) {
					if (bounds.min.x > mesh.bounds.min.x) {
						bounds.min.x = mesh.bounds.min.x;
					}
					if (bounds.min.y > mesh.bounds.min.y) {
						bounds.min.y = mesh.bounds.min.y;
					}
					if (bounds.min.z > mesh.bounds.min.z) {
						bounds.min.z = mesh.bounds.min.z;
					}
					if (bounds.max.x < mesh.bounds.max.x) {
						bounds.max.x = mesh.bounds.max.x;
					}
					if (bounds.max.y < mesh.bounds.max.y) {
						bounds.max.y = mesh.bounds.max.y;
					}
					if (bounds.max.z < mesh.bounds.max.z) {
						bounds.max.z = mesh.bounds.max.z;
					}					
				}
			});
		
			bounds.length.x = bounds.max.x - bounds.min.x;
			bounds.length.y = bounds.max.y - bounds.min.y;
			bounds.length.z = bounds.max.z - bounds.min.z;
			bounds.center.x = bounds.length.x * 0.5 + bounds.min.x;
			bounds.center.y = bounds.length.y * 0.5 + bounds.min.y;
			bounds.center.z = bounds.length.z * 0.5 + bounds.min.z;
			bounds.radius = Vector3D.distance(bounds.center, bounds.max);
			
			return bounds;
		}
		
		public function start() : void {
			this._app.studio.stage.addChildAt(this._sprite, 0);
		}
	}
}
