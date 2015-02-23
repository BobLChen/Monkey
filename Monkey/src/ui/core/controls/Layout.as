package ui.core.controls {

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import ui.core.container.Accordion;
	import ui.core.container.Box;
	import ui.core.container.Container;
	import ui.core.container.ScrollArea;
	import ui.core.event.ControlEvent;

	public class Layout extends Control {

		public var labelWidth 		: Number = 70;
		public var labelAlign 		: uint = 1;
		public var shrinkEnabled 	: Boolean = false;
		public var undoCallback 	: Function;
		
		private var _containers 	: Vector.<Container>;
		private var _current 		: Container;
		private var _area 			: Container;
		private var _enableScroll 	: Boolean;
		private var _space 			: Number = 4;
		private var _labels 		: Dictionary;
		
		public function Layout(scroll : Boolean = true) {
			super();
			this._containers 	= new Vector.<Container>();
			this._enableScroll 	= scroll;
			this.flexible 		= 1;
			this.minWidth 		= 50;
			this.minHeight 		= 50;
			var box : Box 		= new Box();
			box.orientation 	= Box.VERTICAL;
			box.margins 		= 5;
			box.space	 		= this._space;
			this._current 		= box;
			this._containers.push(this._current);
			if (scroll) {
				this._area = new ScrollArea();
				this._area.background = false;
			} else {
				this._area = new Box();
			}
			this._area.addControl(this._current);
			this.view.addChild(this._area.view);
		}
		
		public function set margins(value : Number) : void {
			var box : Box = this._current as Box;
			if (box != null) {
				box.margins = value;
			}
		}

		public function get margins() : Number {
			var box : Box = this._current as Box;
			if (box != null) {
				return box.margins;
			}
			return 0;
		}

		public function get space() : Number {
			var box : Box = this._current as Box;
			if (box != null) {
				return box.space;
			}
			return 0;
		}

		public function set space(value : Number) : void {
			var box : Box = this._current as Box;
			if (box != null) {
				box.space = value;
			}
		}

		public function addScrollAreaGroup(value : String = null) : ScrollArea {
			var scroll : ScrollArea = new ScrollArea();
			scroll.showBorders = true;
			if (value != null) {
				this.addHorizontalGroup();
				var label : Label = new Label(value, this.labelWidth, this.labelAlign);
				this._current.addControl(label);
				this._current.addControl(scroll);
				this.endGroup();
			} else {
				this._current.addControl(scroll);
			}
			this._containers.push(scroll);
			this._current = scroll;
			return scroll;
		}

		public function addAccordionGroup(txt : String = null, open : Boolean = true) : Accordion {
			var accordion : Accordion = new Accordion();
			accordion.open = open;
			accordion.text = txt;
			this._current.addControl(accordion);
			this._containers.push(accordion);
			this._current = accordion;
			return accordion;
		}

		public function addHorizontalGroup(txt : String = null, flexible : Number = 1, height : Number = -1) : Box {
			var box : Box 	= new Box();
			box.orientation = Box.HORIZONTAL;
			box.space 		= this._space;
			box.flexible 	= flexible;
			if (height != -1) {
				box.minHeight = height;
				box.maxHeight = height;
			}
			if (txt != null) {
				this.addHorizontalGroup();
				var label : Label = new Label(txt, this.labelWidth, this.labelAlign);
				this._current.addControl(label);
				this._current.addControl(box);
				this.endGroup();
			} else {
				this._current.addControl(box);
			}
			this._containers.push(box);
			this._current = box;
			return box;
		}

		public function addVerticalGroup(txt : String = null, flexible : Number = 1, width : Number = -1) : Box {
			var box : Box 	= new Box();
			box.orientation = Box.VERTICAL;
			box.space 		= this._space;
			box.flexible 	= flexible;
			if (width != -1) {
				box.maxWidth = width;
				box.minWidth = width;
			}
			if (txt != null) {
				this.addHorizontalGroup();
				var label : Label = new Label(txt, this.labelWidth, this.labelAlign);
				this._current.addControl(label);
				this._current.addControl(box);
				this.endGroup();
			} else {
				this._current.addControl(box);
			}
			this._containers.push(box);
			this._current = box;
			return box;
		}

		public function addSpace(widht : Number = -1, height : Number = -1) : Spacer {
			var box 	: Box = this._current as Box;
			var spacer 	: Spacer = new Spacer();
			if ((box != null) && (box.orientation == Box.HORIZONTAL)) {
				spacer.maxHeight = 1;
			}
			if ((box != null) && (box.orientation == Box.VERTICAL)) {
				spacer.maxWidth = 1;
			}
			if (widht != -1) {
				spacer.minWidth = spacer.maxWidth = widht;
			}
			if (height != -1) {
				spacer.minHeight = spacer.maxHeight = height;
			}
			this._current.addControl(spacer);
			return spacer;
		}

		public function addControl(control : Control, txt : String = null, name : String = null, tiptxt : String = null, conDescrip : String = null) : Control {
			if (txt != null) {
				this.addHorizontalGroup();
				var label : Label = new Label(txt, this.labelWidth, this.labelAlign);
				if (name != null) {
					control.name = name;
				}
				if (tiptxt != null) {
					control.toolTip = tiptxt;
					this._current.toolTip = tiptxt;
				}
				this._current.addControl(label);
				this._current.addControl(control);
				this.endGroup();
			} else {
				this._current.addControl(control);
			}
			var controlName : String = conDescrip || name || tiptxt;
			if (controlName) {
				if (controlName.substr(-1) == ":") {
					controlName = controlName.substr(0, -1);
				}
				if (this._labels == null) {
					this._labels = new Dictionary(true);
				}
				this._labels[control] = controlName;
			}
			control.addEventListener(ControlEvent.CLICK, dispatchEvent);
			control.addEventListener(ControlEvent.UNDO, dispatchEvent);
			control.addEventListener(ControlEvent.STOP, dispatchEvent);
			control.addEventListener(ControlEvent.CHANGE, dispatchEvent);
			return control;
		}

		public function getControlDescription(control : Control) : String {
			if (this._labels == null) {
				return "";
			}
			return this._labels[control] || "";
		}

		public function endGroup() : void {
			if (this._containers.length <= 1) {
				return;
			}
			this._containers.pop();
			this._current = this._containers[(this._containers.length - 1)];
		}

		public function removeAllControls() : void {
			this._containers[0].removeAllControls();
		}

		override public function get minHeight() : Number {
			return (this._enableScroll || this.shrinkEnabled) ? super.minHeight : this.root.minHeight;
		}

		override public function get minWidth() : Number {
			return (this._enableScroll || this.shrinkEnabled) ? super.minWidth : this.root.minWidth;
		}

		public function get root() : Container {
			return this._containers[0];
		}

		override public function draw() : void {
			if (!visible) {
				return;
			}
			this._area.width = width;
			this._area.height = height;
			this._area.update();
			this._area.draw();
			if ((view.scrollRect == null) || (width != view.scrollRect.width) || (height != view.scrollRect.height)) {
				this.view.scrollRect = new Rectangle(0, 0, width, height);
			}
		}

	}
}
