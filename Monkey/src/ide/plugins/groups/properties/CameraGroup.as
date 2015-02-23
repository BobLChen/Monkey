package ide.plugins.groups.properties {

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import ide.App;
	
	import monkey.core.camera.Camera3D;
	import monkey.core.camera.lens.OrthogrhicLens;
	import monkey.core.camera.lens.PerspectiveLens;
	
	import ui.core.container.Box;
	import ui.core.controls.CheckBox;
	import ui.core.controls.ComboBox;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	/**
	 * 相机group
	 * @author Neil
	 *
	 */
	public class CameraGroup extends PropertiesGroup {

		[Embed(source = "menuicon.png")]
		private static const MenuIcon : Class;
		private static const menuIcon : BitmapData = new MenuIcon().bitmapData;
		
		/** 透视投影矩阵 */
		private static const PERSPECTIVE : String = "Perspective";
		/** 正交投影 */
		private static const ORTHOGRHIC  : String = "Orthogrhic";
		
		private var _app 		: App;
		private var _camera 	: Camera3D;
		private var _mainCamera : CheckBox;
		private var _lens		: ComboBox;
		private var _near 		: Spinner;
		private var _far 		: Spinner;
		private var _fieldOfView: Spinner;				// 透视投影
		private var _left		: Spinner;				// 正交:left
		private var _right		: Spinner;				// 正交:right
		private var _top		: Spinner;				// 正交:top
		private var _bottom		: Spinner;				// 正交:bottom
		private var _baseGroup	: Box;
		private var _persGroup  : Box;
		private var _orthGroup	: Box;
				
		public function CameraGroup() {
			super("Camera");
			this.accordion.contentHeight = 140;
			this.layout.margins = 5;
			// base
			this._baseGroup = this.layout.addVerticalGroup();
			this._mainCamera = this.layout.addControl(new CheckBox(), "MainCamera:") as CheckBox;
			this._lens = this.layout.addControl(new ComboBox([PERSPECTIVE, ORTHOGRHIC], [PERSPECTIVE, ORTHOGRHIC]), "Lens:") as ComboBox;
			this._lens.addEventListener(ControlEvent.CHANGE, changeLens);
			this._near = layout.addControl(new Spinner(), "Near:") as Spinner;
			this._far = layout.addControl(new Spinner(), "Far:") as Spinner;
			this.layout.endGroup();
			// perspective
			this._persGroup = this.layout.addVerticalGroup();
			this._fieldOfView = layout.addControl(new Spinner(), "Field Of View:") as Spinner;
			this.layout.endGroup();
			// orth
			this._orthGroup = this.layout.addVerticalGroup();
			this._left 	 = layout.addControl(new Spinner(), "Left:") as Spinner;
			this._right  = layout.addControl(new Spinner(), "Right:") as Spinner;
			this._bottom = layout.addControl(new Spinner(), "Bottom:") as Spinner;
			this._top 	 = layout.addControl(new Spinner(), "Top:") as Spinner;
			this.layout.endGroup();
			
			this._near.addEventListener(ControlEvent.CHANGE, changeNearFar);
			this._far.addEventListener(ControlEvent.CHANGE, changeNearFar);
			this._fieldOfView.addEventListener(ControlEvent.CHANGE, changeFieldOfView);
			this._left.addEventListener(ControlEvent.CHANGE, changeOrth);
			this._mainCamera.addEventListener(ControlEvent.CHANGE, setMainCamera);
		}
		
		private function setMainCamera(event:Event) : void {
			if (this._mainCamera.value) {
				this._app.scene.camera = this._camera;
			} else {
				
			}
		}
		
		private function changeOrth(event:Event) : void {
			(this._camera.lens as OrthogrhicLens).setOrth(this._left.value, this._right.value, this._bottom.value, this._top.value);
		}
		
		private function changeFieldOfView(event:Event) : void {
			(this._camera.lens as PerspectiveLens).fieldOfView = this._fieldOfView.value;
		}
		
		private function changeNearFar(event:Event) : void {
			this._camera.near = this._near.value;
			this._camera.far  = this._far.value;
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			if (this._app.selection.objects.length == 1 && this._app.selection.objects[0] is Camera3D) {
				this._camera = this._app.selection.main as Camera3D;
				this.updateCamera();
				return true;
			}
			return false;
		}
		
		private function updateCamera() : void {
			this.layout.removeAllControls();
			this.layout.addControl(this._baseGroup);
			this._near.value = this._camera.near;
			this._far.value = this._camera.far;
			if (this._camera.lens is PerspectiveLens) {
				this.accordion.contentHeight = 140;
				this.layout.addControl(this._persGroup);
				this._fieldOfView.value = (this._camera.lens as PerspectiveLens).fieldOfView;
			} else if (this._camera.lens is OrthogrhicLens) {
				this.accordion.contentHeight = 160;
				this.layout.addControl(this._orthGroup);
				this._left.value = (this._camera.lens as OrthogrhicLens).left;
				this._right.value = (this._camera.lens as OrthogrhicLens).right;
				this._top.value = (this._camera.lens as OrthogrhicLens).top;
				this._bottom.value = (this._camera.lens as OrthogrhicLens).bottom;
			}
			this.layout.draw();
		}
		
		private function changeLens(event:Event) : void {
			var lensStr : String = this._lens.selectData as String;
			var viewprot: Rectangle = this._app.scene.viewPort;
			switch(lensStr) {
				case PERSPECTIVE: {
					this._camera.lens = new PerspectiveLens();
					break;
				}
				case ORTHOGRHIC: {
					this._camera.lens = new OrthogrhicLens(0, 0, 0, 0);
					break;
				}
				default: {
					break;
				}
			}
			this._camera.setViewPort(0, 0, viewprot.width, viewprot.height);
			this.updateCamera();
		}
	}
}
