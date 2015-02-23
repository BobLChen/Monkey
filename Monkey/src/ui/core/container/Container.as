package ui.core.container {

	import flash.display.Shape;
	import flash.display.Sprite;
	
	import ui.core.Style;
	import ui.core.controls.Control;
	import ui.core.event.ControlEvent;
	
	/**
	 * 容器 
	 * @author neil
	 */	
	public class Container extends Control {
		
		public var background 		: Boolean = false;
		public var backgroundColor 	: int;
		
		private var _controls : Vector.<Control>;
		private var _borders  : Shape;
		private var _content  : Sprite;
		
		public function Container() {
			super("", 0, 0, 100, 100);
			this.backgroundColor= Style.backgroundColor;
			this._controls 		= new Vector.<Control>();
			this._borders 		= new Shape();
			this._content 		= new Sprite();
			this.showBorders 	= false;
			this.view.addChild(this._content);
			this.view.addChild(this._borders);
			this.flexible = 1;
		}
		
		public function addControl(controls : Control) : void {
			this.addControlAt(controls, this.controls.length);
		}
		
		public function addControlAt(control : Control, index : int = 0) : void {
			if (control.parent == this) {
				return;
			}
			if (control.parent) {
				control.parent.removeControl(control);
			}
			this.controls.splice(index, 0, control);
			control.parent = this;
			control.addEventListener(ControlEvent.CLICK, dispatchEvent);
			control.addEventListener(ControlEvent.UNDO, dispatchEvent);
			control.addEventListener(ControlEvent.STOP, dispatchEvent);
			control.addEventListener(ControlEvent.CHANGE, dispatchEvent);
			this._content.addChild(control.view);
		}
		
		public function removeAllControls() : void {
			while (this.controls.length > 0) {
				this.removeControl(this.controls[0]);
			}
		}
		
		public function removeControl(control : Control) : void {
			var idx : int = this.controls.indexOf(control);
			if (idx != -1) {
				this.controls.splice(idx, 1);
				this._content.removeChild(control.view);
				control.parent = null;
				control.removeEventListener(ControlEvent.CLICK, dispatchEvent);
				control.removeEventListener(ControlEvent.UNDO, dispatchEvent);
				control.removeEventListener(ControlEvent.STOP, dispatchEvent);
				control.removeEventListener(ControlEvent.CHANGE, dispatchEvent);
			}
		}
		
		/**
		 * get control by name 
		 * @param name
		 * @param index
		 * @return 
		 * 
		 */		
		public function getControlByName(name : String, index : int = 0) : Control {
			for each (var control : Control in this.controls) {
				if (control.name == name && --index < 0) {
					return control;
				}
				if (control is Container) {
					var result : Control = Container(control).getControlByName(name, index);
					if (result != null) {
						return result; 
					}
				}
			}
			return null;
		}

		public function get content() : Sprite {
			return this._content;
		}

		public function get showBorders() : Boolean {
			return this._borders.visible;
		}

		public function set showBorders(value : Boolean) : void {
			this._borders.visible = value;
		}

		public function get controls() : Vector.<Control> {
			return this._controls;
		}

		public function update() : void {
			
		}

		override public function draw() : void {
			this._borders.graphics.clear();
			if (this._borders.visible) {
				this._borders.graphics.lineStyle(1, Style.borderColor2, 1, true);
				this._borders.graphics.drawRect(0, 0, width, height);
			}
			this.view.graphics.clear();
			if (this.background) {
				this.view.graphics.beginFill(this.backgroundColor);
				this.view.graphics.drawRect(0, 0, width, height);
			}
		}

	}
}
