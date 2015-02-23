package ide.plugins.groups.properties {
	
	import com.adobe.images.PNGEncoder;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	
	import L3D.core.camera.Camera3D;
	import L3D.core.camera.lenses.OrthogrhicLens;
	import L3D.core.camera.lenses.PerspectiveLens;
	import L3D.system.Device3D;
	
	import ide.plugins.ScenePlugin;
	
	import ide.App;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Image;
	import ui.core.controls.InputText;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class CameraGroup extends PropertiesGroup {
		
		
		private var _app : App;
		private var _camera : Camera3D;
		
		private var _near : Spinner;
		private var _far : Spinner;
		private var _fieldOfView : Spinner;
		private var _image : Image;
		private var _useCamera : CheckBox;
		private var _lookAtX : Spinner;
		private var _lookAtY : Spinner;
		private var _lookAtZ : Spinner;
		private var _orthogrhCamera : CheckBox;
		private var _perspectCamera : CheckBox;
		private var _widthSpinner : Spinner;
		private var _heightSpinner : Spinner;
		private var _render : InputText;
		
		
		public function CameraGroup() {
			super("Camera");
			accordion.contentHeight = 250;
			layout.margins = 5;
			
			layout.addHorizontalGroup();
			_useCamera = layout.addControl(new CheckBox(), "UseCamera:") as CheckBox;
			_render = layout.addControl(new InputText("Render")) as InputText;
			_render.textField.selectable = false;
			layout.endGroup();
			
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup();
			_orthogrhCamera = layout.addControl(new CheckBox(), "OrthogrhicLens") as CheckBox;
			_perspectCamera = layout.addControl(new CheckBox(), "PerspectiveLens") as CheckBox;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			
			_near = layout.addControl(new Spinner(), "Near:") as Spinner;
			_far = layout.addControl(new Spinner(), "Far:") as Spinner;
			_fieldOfView = layout.addControl(new Spinner(), "Field Of View:") as Spinner;
			
			layout.addHorizontalGroup("LookAt:");
			_lookAtX = layout.addControl(new Spinner()) as Spinner;
			_lookAtY = layout.addControl(new Spinner()) as Spinner;
			_lookAtZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			
			layout.addHorizontalGroup();
			layout.labelWidth = 55;
			_widthSpinner = layout.addControl(new Spinner(), "Width:") as Spinner;
			_heightSpinner = layout.addControl(new Spinner(), "Height:") as Spinner;
			layout.endGroup();
			
			_image = layout.addControl(new Image(Device3D.nullBitmapData, true, 220, 120)) as Image;
			_image.x = 10;
			
			_near.addEventListener(ControlEvent.STOP, changeCamera);
			_far.addEventListener(ControlEvent.STOP, changeCamera);
			_fieldOfView.addEventListener(ControlEvent.STOP, changeCamera);
			_lookAtX.addEventListener(ControlEvent.STOP, changeLookAt);
			_lookAtY.addEventListener(ControlEvent.STOP, changeLookAt);
			_lookAtZ.addEventListener(ControlEvent.STOP, changeLookAt);
			
			_useCamera.addEventListener(ControlEvent.CHANGE, useThisCamera);
			_orthogrhCamera.addEventListener(ControlEvent.CHANGE, changeCameraLens);
			_perspectCamera.addEventListener(ControlEvent.CHANGE, changeCameraLens);
			_widthSpinner.addEventListener(ControlEvent.CHANGE, changeOrLens);
			_heightSpinner.addEventListener(ControlEvent.CHANGE, changeOrLens);
			_render.addEventListener(ControlEvent.CLICK, render);
		}
		
		protected function render(event:Event) : void {
			var rect : Rectangle = _camera.viewPort == null ? _app.scene.viewPort : _camera.viewPort;
			var bitmap : BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			ScenePlugin(this._app.scene).renderToBitmapData(this._camera, bitmap);	
			var file : FileReference = new FileReference();
			file.save(PNGEncoder.encode(bitmap));
		}
		
		protected function changeOrLens(event:Event) : void {
			OrthogrhicLens(_camera.lens).viewPort = new Rectangle(0, 0, _widthSpinner.value, _heightSpinner.value);
		}
		
		protected function changeCameraLens(event:Event) : void {
			switch(event.target) {
				case _orthogrhCamera: {
					_orthogrhCamera.enabled = false;
					_perspectCamera.enabled = true;
					_widthSpinner.enabled = true;
					_heightSpinner.enabled = true;
					_perspectCamera.value = false;
					var w : Number = _app.scene.viewPort.width;
					var h : Number = _app.scene.viewPort.height;
					_widthSpinner.value = w;
					_heightSpinner.value = h;
					_camera.lens = new OrthogrhicLens(-w/2, w/2, -h/2, h/2, _camera.near, _camera.far);
					break;
				}
				case _perspectCamera: {
					_perspectCamera.enabled = false;
					_widthSpinner.enabled = false;
					_heightSpinner.enabled = false;
					_orthogrhCamera.enabled = true;
					_orthogrhCamera.value = false;
					break;
				}
				default: {
					break;
				}
			}
		}
		
		protected function useThisCamera(event:Event) : void {
			if (_useCamera.value) {
				if (this._app.scene.camera != this._camera) {
					this._app.scene.camera = this._camera;
				}
			} else {
				if (this._app.scene.camera == this._camera) {
					this._app.scene.camera = ScenePlugin(this._app.scene).sceneCamera;
				}
			}
		}
		
		protected function changeLookAt(event:Event) : void {
			_camera.lookAt(_lookAtX.value, _lookAtY.value, _lookAtZ.value);			
		}
		
		protected function changeCamera(event:Event) : void {
			_camera.near = _near.value;
			_camera.far = _far.value;
			if (_camera.lens is PerspectiveLens) {
				(_camera.lens as PerspectiveLens).fieldOfView = _fieldOfView.value;
			}
		}
		
		private function updateCamera() : void {
			
			if (this._app.scene.camera == this._camera) {
				_useCamera.value = true;
			} else {
				_useCamera.value = false;
			}
			
			if (this._camera.lens is PerspectiveLens) {
				_perspectCamera.value = true;
				_perspectCamera.enabled = false;
				_orthogrhCamera.value = false;
				_widthSpinner.enabled = false;
				_heightSpinner.enabled = false;
			} else if (this._camera.lens is OrthogrhicLens) {
				_orthogrhCamera.value = true;
				_orthogrhCamera.enabled = false;
				_perspectCamera.value = false;
				_widthSpinner.enabled = true;
				_heightSpinner.enabled = true;
				
				_widthSpinner.value = OrthogrhicLens(_camera.lens).right * 2;
				_heightSpinner.value = OrthogrhicLens(_camera.lens).bottom * 2;
			}
			
			var rect : Rectangle = null;
			if (this._camera.viewPort == null) {
				rect = this._app.scene.viewPort;
			} else {
				rect = this._camera.viewPort;
			}
			var bitmap : BitmapData = new BitmapData(rect.width || 1, rect.height || 1, true, 0);
			ScenePlugin(this._app.scene).renderToBitmapData(this._camera, bitmap);			
			_image.source = bitmap;
			this._near.value = _camera.near;
			this._far.value = _camera.far;
			if (_camera.lens is PerspectiveLens) {
				this._fieldOfView.value = (_camera.lens as PerspectiveLens).fieldOfView;
			}
		}
		
		override public function update(app:App):Boolean {
			this._app = app;
			if (this._app.selection.objects.length == 1 && this._app.selection.objects[0] is Camera3D) {
				this._camera = this._app.selection.main as Camera3D;
				this.updateCamera();
				return true;
			}
			return false;
		}
				
		
	}
}
