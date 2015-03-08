package ui.core.controls {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import ui.core.container.Panel;
	
	/**
	 * window 
	 * @author neil
	 * 
	 */	
	public class Window extends Panel {
		
		[Embed(source="close.png")]
		private static const CloseIcon : Class;
		private static const MARGIN : Number = 15;
		
		public static const CENTER : String = "center";
		public static const NONE : String = "none";
		
		private static var _popWindow:Window;
		
		private var _layout : Layout;
		private var _colorBar : Control;
		private var _colorTable : Control;
		private var _imgBtn : ImageButton;
		private var _window : Control;
		private var _mode : String;
		private var _bar : Panel;
		
		public function Window(mode : String = "none") {
			super("window", 250, 250, false);
			this.width = 250;
			this.height = 250;
			this.visible = true;
			this._mode = mode;
			this._bar = new Panel("bar", 200, 20, false);
			this._bar.maxHeight = 15;
			this._bar.height = 15;
			this._bar.background = true;
			this._bar.visible = true;
			this._bar.view.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownEvent);
			this._bar.view.addEventListener(MouseEvent.MOUSE_UP, mouseUpEvent);
			this._imgBtn = new ImageButton(new CloseIcon());
			this._imgBtn.maxHeight = 18;
			this._imgBtn.height = 18;
			this._imgBtn.addEventListener(MouseEvent.CLICK, onClickCloseEvent);
			this._layout = new Layout();
			this.setLayout();
			this.addControl(this._layout);
			this.update();
			this.draw();
		}
		
		public static function get popWindow():Window {
			if (_popWindow == null)
				_popWindow = new Window();
			return _popWindow;
		}

		protected function mouseUpEvent(event:Event) : void {
			this.view.stopDrag();
		}
		
		protected function mouseDownEvent(event:MouseEvent) : void {
			this.view.startDrag(false);
		}
		
		public function get mode():String {
			return _mode;
		}

		public function set mode(value:String):void {
			_mode = value;
		}
		
		override public function close():void {
			this.visible = false;
		}
		
		override public function open():void {
			this.visible = true;
			if (this._mode == CENTER) {
				if (this.view.stage != null) {
					this.x = 0;
					this.y = 0;
					var point : Point = new Point(this.view.stage.mouseX, this.view.stage.mouseY);
					point = this.view.globalToLocal(point);
					this.x = point.x;
					this.y = point.y + 20;
				}
			}
		}
		
		private function setLayout() : void {
			this._layout.removeAllControls();
			this._layout.addVerticalGroup();
			this._layout.addHorizontalGroup();
			this._layout.addControl(_imgBtn);
			this._layout.addControl(_bar);
			this._layout.endGroup();
		}
		
		public function set window(control : Control) : void {
			if (this._window != null) {
				this.setLayout();
			}
			this.minWidth = control.width;
			this.minHeight = control.height + this._imgBtn.height + MARGIN;
			this.width = control.width;
			this.height = control.height + this._imgBtn.height + MARGIN;
			this._layout.height = this.height;
			this._layout.addControl(control);
			this.update();
			this.draw();
		}
		
		protected function onClickCloseEvent(event:Event) : void {
			this.visible = false;
		}
		
	}
}
