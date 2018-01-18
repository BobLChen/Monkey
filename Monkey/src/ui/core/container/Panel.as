package ui.core.container {

	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import ui.core.controls.TabControl;
	
	/**
	 * 
	 * @author neil
	 * 
	 */	
	public class Panel extends Box {
		
		public var tabControl : TabControl;
		public var tabIndex : int;
		private var _text : String;
		private var _blocker : Sprite;
		private var _closed : Boolean = false;
		private var _dockeable : Boolean = true;
		
		public function Panel(name : String, width : Number = 250, height : Number = 250, closed : Boolean = true) {
			this._blocker = new Sprite();
			this._blocker.graphics.beginFill(0, 0.1);
			this._blocker.graphics.drawRect(0, 0, 1, 1);
			this._blocker.visible = false;
			this._blocker.mouseEnabled = false;
			this.tabIndex = -1;
			this.margins = 0;
			this.minWidth = 20;
			this.minHeight = 20;
			this.width = width;
			this.height = height;
			this.name = name;
			this.text = name;
			this.visible = false;
			this.background = true;
			this.view.addChild(this._blocker);
			this._dockeable = closed;
		}
		
		public function open() : void {
			if (enabled) {
				view.alpha = 0;
				setTimeout(TweenLite.to, 100, view, 0.2, {alpha: 1, onUpdate: function() : void {
					if (!enabled) {
						TweenLite.killTweensOf(view);
						view.alpha = 0.5;
					}
				}});
			}
			this._closed = false;
			this.visible = true;
			if (tabControl != null) {
				this.tabControl.open();
				this.tabControl.setCurrentPanel(this);
			}
		}
		
		public function close() : void {
			var showPanel : Panel;
			if (!this._dockeable) {
				return;
			}
			this._closed = true;
			this.visible = false;
			for each (var panel : Panel in this.tabControl.panels) {
				if (panel.closed == false) {
					showPanel = panel;
				}
			}
			if (showPanel == null) {
				this.tabControl.close();
			} else {
				this.tabControl.setCurrentPanel(showPanel);
			}
		}

		public function get text() : String {
			return this._text;
		}

		public function set text(txt : String) : void {
			this._text = txt;
		}

		public function get dockeable() : Boolean {
			return this._dockeable;
		}
		
		public function get closed() : Boolean {
			return this._closed;
		}
		
		override public function draw() : void {
			super.draw();
			this._blocker.width = width;
			this._blocker.height = height;
		}
		
	}
}
