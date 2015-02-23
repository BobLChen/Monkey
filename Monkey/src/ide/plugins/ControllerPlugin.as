package ide.plugins {

	import flash.events.Event;
	import flash.utils.getTimer;
	
	import ide.App;
	import ide.Studio;
	import ide.events.SceneEvent;
	
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Input3D;
	
	import ui.core.container.Panel;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Layout;
	import ui.core.controls.Spinner;
	import ui.core.controls.TabControl;
	import ui.core.event.ControlEvent;
	import ui.core.interfaces.IPlugin;
	
	public class ControllerPlugin implements IPlugin {

		private var _app 			: App;
		private var _panel 			: Panel;
		private var _layout 		: Layout;
		private var _speed 			: Spinner;
		private var _rotSpeed 		: Spinner;
		private var _enableControl 	: CheckBox;
		private var _fpsModel 		: CheckBox;
		private var _preTime 		: int;
		private var _curTime 		: int;
		
		public function ControllerPlugin() {
			this._panel = new Panel("CONTROL");
			this._panel.minWidth = 200;
			this._layout = new Layout();
			this._layout.maxHeight = 100;
			this._panel.addControl(this._layout);
			this._enableControl = this._layout.addControl(new CheckBox(), "EnableControl:") as CheckBox;
			this._enableControl.toolTip = "控制说明:\n前:W\n后:S\n左:A\n右:D\n自动移动:R";
			this._speed = _layout.addControl(new Spinner(40), "Speed:") as Spinner;
			this._speed.toolTip = "移动速度";
			this._rotSpeed = _layout.addControl(new Spinner(30), "RotSpeed:") as Spinner;
			this._rotSpeed.toolTip = "转向速度";
			this._fpsModel = _layout.addControl(new CheckBox(), "FPS:") as CheckBox;
			this._enableControl.addEventListener(ControlEvent.CHANGE, changeControl);
		}
		
		private function changeControl(event : Event) : void {
			if (this._enableControl.value) {
				this._app.addEventListener(SceneEvent.UPDATE_EVENT, update);
				this._preTime = getTimer();
			} else {
				this._app.removeEventListener(SceneEvent.UPDATE_EVENT, update);
			}
		}
		
		private function update(event : Event) : void {
			_curTime = getTimer();
			if (this._app.selection.main == null || this._app.selection.main is Scene3D) {
				_preTime = _curTime;
				return;
			}
			var dist : Number = (_curTime - _preTime) / 1000 * _speed.value;
			var rot : Number = (_curTime - _preTime) / 1000 * _rotSpeed.value;
			if (Input3D.keyDown(Input3D.W)) {
				this._app.selection.main.translateZ(dist);
			}
			if (Input3D.keyDown(Input3D.S)) {
				this._app.selection.main.translateZ(-dist);
			}
			if (Input3D.keyDown(Input3D.A)) {
				if (this._fpsModel.value) {
					this._app.selection.main.rotateY(-rot);
				} else {
					this._app.selection.main.translateX(-dist);
				}
			}
			if (Input3D.keyDown(Input3D.D)) {
				if (this._fpsModel.value) {
					this._app.selection.main.rotateY(rot);
				} else {
					this._app.selection.main.translateX(dist);
				}
			}
			_preTime = _curTime;
		}

		public function init(app : App) : void {
			this._app = app;
			var tab : TabControl = this._app.ui.getPanel(Studio.MIDDLE_TAB) as TabControl;
			tab.addPanel(this._panel);
		}
		
		public function start() : void {

		}
	}
}
