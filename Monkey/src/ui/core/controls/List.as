package ui.core.controls {

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import ui.core.Style;
	import ui.core.container.Box;
	import ui.core.container.ScrollArea;
	import ui.core.event.ControlEvent;
	import ui.core.event.DragDropEvent;

	public class List extends Control {

		private var _items : Array;
		private var _selected : Array;
		private var _currentIndex : int;
		private var _multiSelect : Boolean = false;
		private var _scrollArea : ScrollArea;
		private var _container : Box;
		private var _firstSelected : Control = null;
		private var _lastSelected : Control = null;
		private var _prevFirstShownIndex : int = -1;
		private var _prevLastShownIndex : int = -1;
		private var _dragSpeed : Number = 0;
		private var _dropOver : Boolean;
		private var _dropIndex : int;
		private var _lastX : Number;
		private var _lastY : Number;
		private var _enableDragAndDrop : Boolean = false;
		
		public function List(items : Array = null) {
			super();
			this._items = [];
			this._selected = [];
			this._container = new Box();
			this._container.space = 1;
			this._container.margins = 5;
			this._container.content.doubleClickEnabled = true;
			this._scrollArea = new ScrollArea();
			this._scrollArea.background = true;
			this._scrollArea.showBorders = true;
			this._scrollArea.addControl(this._container);
			this.view.focusRect = false;
			this.view.doubleClickEnabled = true;
			this.view.addChild(this._scrollArea.view);
			this.view.addEventListener(KeyboardEvent.KEY_DOWN, this.keyEvent);
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, this.clickEvent);
			this.view.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, this.clickEvent);
			this.view.addEventListener(MouseEvent.DOUBLE_CLICK, this.doubleClick);
			this.flexible = 1;
			this.minHeight = 30;

			if (items) {
				this.items = items;
			}
		}

		private function doubleClick(e : MouseEvent) : void {
			dispatchEvent(new ControlEvent(ControlEvent.DOUBLE_CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		public function keyEvent(e : KeyboardEvent) : void {

			e.stopImmediatePropagation();

			if (this._items.length == 0) {
				return;
			}
			this._currentIndex = this._items.indexOf(this._lastSelected);

			if (e.keyCode == Keyboard.UP && this._currentIndex > 0) {
				this._currentIndex--;
			} else if ((e.keyCode == Keyboard.DOWN) && (this._currentIndex < this._items.length - 1)) {
				this._currentIndex++;
			} else if (e.keyCode == Keyboard.HOME) {
				this._currentIndex = 0;
			} else if (e.keyCode == Keyboard.END) {
				this._currentIndex = this._items.length - 1;
			} else if (e.keyCode == Keyboard.PAGE_UP) {
				this._currentIndex = this.firstShownIndex();
			} else if (e.keyCode == Keyboard.PAGE_DOWN) {
				this._currentIndex = this.lastShownIndex();
			} else {
				return;
			}

			var control : Control = this._items[this._currentIndex];

			if (!e.shiftKey && this._firstSelected) {
				this._firstSelected = null;
			}

			if (!e.shiftKey && !e.ctrlKey && !this._firstSelected) {
				this._selected = [];
			}

			if (e.shiftKey && !this._firstSelected) {
				this._firstSelected = this._lastSelected;
			}

			if (this._firstSelected && this._multiSelect) {
				var firstIdx : int = this._items.indexOf(this._firstSelected);
				var curIdx : int = this._currentIndex;

				if (firstIdx > curIdx) {
					var tmp : int = firstIdx;
					firstIdx = curIdx;
					curIdx = tmp;
				}
				this._selected = this._items.slice(firstIdx, curIdx + 1);
			} else {
				this._selected = [this._items[this._currentIndex]];
			}
			this._lastSelected = this._items[this._currentIndex];
			this.scrollTo();
			this.drawSelection();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function firstShownIndex() : int {
			var num : int = this._scrollArea.contentHeight / this._items[0].height - 1;
			var idx : int;

			if (this._currentIndex >= num) {
				idx = this._currentIndex - num;
			}
			return idx;
		}

		private function lastShownIndex() : int {
			var idx : int = this._scrollArea.contentHeight / this._items[0].height - 1;
			var result : int = (this._items.length - 1);

			if (this._currentIndex + idx <= this._items.length - 1) {
				result = this._currentIndex + idx;
			}
			return result;
		}

		public function scrollTo(control : Control = null) : void {

			var selControl : Control = null;

			if (control == null) {
				selControl = this._lastSelected;
			} else {
				selControl = control;
			}

			if (selControl == null) {
				return;
			}

			if (selControl.y < this._scrollArea.scrollY) {
				this._scrollArea.scrollY = (selControl.y - this._container.margins);
			} else if (selControl.y + selControl.height > this._scrollArea.scrollY + this._scrollArea.contentHeight) {
				this._scrollArea.scrollY = selControl.y + selControl.height - this._scrollArea.contentHeight + this._container.margins;
			}

		}

		private function clickEvent(e : MouseEvent) : void {

			var clickY : Number = this._container.view.mouseY;

			view.stage.focus = view;

			var i : int = 0;
			var clickControl : Control;

			while (i < this._container.controls.length) {
				clickControl = this._container.controls[i];

				if ((clickY > (clickControl.y - this._container.space)) && (clickY < (clickControl.y + clickControl.height + this._container.space))) {
					break;
				}
				i++;
			}

			if (i == this._container.controls.length) {
				return;
			}
			this._lastSelected = clickControl;

			if (this._firstSelected == null) {
				this._firstSelected = clickControl;
			}

			if (e.type == MouseEvent.RIGHT_MOUSE_DOWN) {
				if (this._selected.indexOf(clickControl) != -1) {
					e.ctrlKey = true;
				}
			}

			if (e.ctrlKey && this._multiSelect) {
				i = this._selected.indexOf(clickControl);

				if (i == -1) {
					this._selected.push(clickControl);
				} else if (e.type != MouseEvent.RIGHT_MOUSE_DOWN) {
					this._selected.splice(i, 1);
				}
			} else if (e.shiftKey && this._multiSelect) {
				this._selected = [];
				var firIdx : int = this._items.indexOf(this._firstSelected);
				var cliIdx : int = this._items.indexOf(clickControl);
				if ((firIdx > -1) && (cliIdx > -1)) {
					var tmp : int = 0;

					if (firIdx > cliIdx) {
						tmp = firIdx;
						firIdx = cliIdx;
						cliIdx = tmp;
					}
					var arr : Array = this._items.slice(firIdx, cliIdx + 1);
					this._selected = arr;
				}
			} else if (!this.enableDragAndDrop || (this._selected.indexOf(clickControl) == -1) || (e.type != MouseEvent.MOUSE_DOWN)) {
				this._firstSelected = clickControl;
				this._selected = [clickControl];
			}
			this.scrollTo();
			this.drawSelection();
			this.dispatchEvent(new ControlEvent(ControlEvent.CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
			this._lastX = e.stageX;
			this._lastY = e.stageY;
			
			this.drawDragDrop();
			
			if (this.enableDragAndDrop && (e.type == MouseEvent.MOUSE_DOWN) && !e.ctrlKey && !e.shiftKey) {
				view.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveEvent);
				view.stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			}
		}
		
		private function mouseUpEvent(e : MouseEvent) : void {
			if (enableDragAndDrop) {
				this.drawDragDrop();
				this.drawSelection();
				this.dispatchEvent(new DragDropEvent(this._dropIndex, this._dropOver));
			}
//			if ((Math.abs(this._lastX - e.stageX) < 8) && (Math.abs(this._lastY - e.stageY) < 8)) {
//				this.clickEvent(e);
//			}
			view.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveEvent);
			view.stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			view.stage.removeEventListener(Event.ENTER_FRAME, this.updateDragEvent);
		}
		
		private function mouseMoveEvent(e : MouseEvent) : void {
			if ((Math.abs(this._lastX - e.stageX) > 8) || (Math.abs(this._lastY - e.stageY) > 8)) {
				this._dragSpeed = 0;
				view.stage.addEventListener(Event.ENTER_FRAME, this.updateDragEvent);
			}
		}

		private function updateDragEvent(e : Event) : void {
			if ((view.mouseX < 0) || (view.mouseX > width)) {
				return;
			}
			if (view.mouseY < 20) {
				this._dragSpeed = this._dragSpeed - 0.2;
				if (this._dragSpeed < -15) {
					this._dragSpeed = -15;
				}
				this._scrollArea.scrollY = (this._scrollArea.scrollY + this._dragSpeed);
			} else if (view.mouseY > (height - 20)) {
				this._dragSpeed = this._dragSpeed + 0.2;
				if (this._dragSpeed > 15) {
					this._dragSpeed = 15;
				}
				this._scrollArea.scrollY = this._scrollArea.scrollY + this._dragSpeed;
			} else {
				this._dragSpeed = 0;
			}
			drawDragDrop();
		}

		private function clear() : void {
			while (this._container.controls.length) {
				this._container.removeControl(this._container.controls[0]);
			}
			this._items = [];
		}

		public function get items() : Array {
			return this._items;
		}

		public function set items(item : Array) : void {
			this.clear();
			this._items = item;
			var i : int;
			while (i < this._items.length) {
				this._container.addControlAt(this._items[i], i);
				i++;
			}
			this._container.update();
			this.draw();
		}

		public function refresh() : void {
			this.items = this._items;
		}

		public function get selected() : Array {
			return this._selected;
		}

		public function set selected(arr : Array) : void {
			this._selected = arr;
			this.drawSelection();
			if (this._selected) {
				this.scrollTo();
			}
		}

		public function set multiSelect(value : Boolean) : void {
			this._multiSelect = value;
		}

		public function get multiSelect() : Boolean {
			return this._multiSelect;
		}

		public function isSelected(control : Control) : Boolean {
			var idx : int = this._selected.indexOf(control);
			if (idx > -1) {
				return true;
			}
			return false;
		}

		public function clearSelection() : void {
			this._selected = [];
			dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		private function drawSelection() : void {
			var control : Control;
			var spa : Number = this._container.space;
			this._container.content.graphics.clear();
			for each (control in this._selected) {
				this._container.content.graphics.beginFill(Style.selectionColor);
				this._container.content.graphics.drawRect(0, (control.y - spa), this._scrollArea.totalWidth, (control.height + (spa * 2)));
			}
		}

		private function drawDragDrop() : void {
			this.drawSelection();
			this._container.content.graphics.lineStyle(1, 5271807, 1, true);
			this._container.content.graphics.beginFill(5271807, 0.25);
			this._dropOver = false;
			this._dropIndex = 0;
			var spa : Number = this._container.space;
			for each (var item : Control in this.items) {
				if ((this._container.content.mouseY >= (item.y - spa)) && (this._container.content.mouseY <= (item.y + item.height + (spa * 2))) ) {
					var h : int = item.y + (item.height * 0.5);
					if (this._container.content.mouseY > (h + 4)) {
						this._container.content.graphics.drawRect(0, item.y + item.height - 1, this._scrollArea.totalWidth, 2);
					} else {
						this._dropOver = true;
						this._container.content.graphics.drawRect(0, item.y, this._scrollArea.totalWidth, item.height);
					}
					break;
				}
				this._dropIndex++;
			}
		}
		
		override public function draw() : void {
			this._scrollArea.backgroundColor = Style.backgroundColor;
			this._scrollArea.width = width;
			this._scrollArea.height = height;
			this._scrollArea.view.graphics.clear();
			this._scrollArea.update();
			this._scrollArea.draw();
			this.drawSelection();
		}

		public function get length() : int {
			return this._items != null ? this._items.length : 0;
		}

		public function get enableDragAndDrop() : Boolean {
			return this._enableDragAndDrop;
		}

		public function set enableDragAndDrop(value : Boolean) : void {
			this._enableDragAndDrop = value;
		}
		
		
	}
}
