package ide.panel {

	import com.greensock.TweenLite;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import L3D.core.base.Pivot3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.render.SkeletonRender;
	import L3D.core.scene.Scene3D;
	
	import ui.core.Style;
	import ui.core.controls.Control;
	import ui.core.controls.List;
	import ui.core.event.ControlEvent;
	import ui.core.event.DragDropEvent;

	public class PivotTree extends Control {
		
		private var _list 		: List;
		private var _pivot 		: Pivot3D;
		private var _items 		: Dictionary;
		private var _closed 	: Dictionary;
		private var _labels 	: Array;
		private var _lastAction : Boolean;
		private var _multiSelect: Boolean = true;
		
		public function PivotTree(pivot : Pivot3D = null) {
			super();
			
			this._list = new List();
			this._list.addEventListener(ControlEvent.CLICK,	 		listClickEvent);
			this._list.addEventListener(ControlEvent.CHANGE, 		listChangeEvent);
			this._list.addEventListener(DragDropEvent.DRAG_DROP, 	dispatchEvent);
			this._list.enableDragAndDrop = true;
			this._list.multiSelect = true;
			
			this._items  = new Dictionary(true);
			this._closed = new Dictionary(true);
			this._labels = [];
			
			this._pivot = pivot;
			
			this.view.addChild(this._list.view);
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownEvent);
			this.view.focusRect 	= false;
			this.view.cacheAsBitmap = true;
			
			this.flexible = 1;
		}

		private function listChangeEvent(e : ControlEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function listClickEvent(e : ControlEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function mouseDownEvent(e : MouseEvent) : void {
			this.view.stage.focus = view;
		}
		
		override public function draw() : void {
			this._list.width  = width;
			this._list.height = height;
			this._list.draw();
		}
		
		private function createItems(pivot : Pivot3D, level : int = 0) : void {
			var item : PivotTreeItem = this._items[pivot];
			if (!item) {
				item = new PivotTreeItem(pivot, 5 + level * 15);
			}
			item.addEventListener(PivotTreeItem.CLOSE, 				closeEvent, 	 false, 0, true);
			item.addEventListener(PivotTreeItem.LABEL_DOUBLECLICK, 	closeEvent, 	 false, 0, true);
			item.addEventListener(PivotTreeItem.LABEL_RIGHTCLICK, 	rightClickEvent, false, 0, true);
			item.label.text    = pivot.name + " ";
			item.view.alpha    = pivot.visible ? 1 : 0.5;
			item.level 	       = level * 15;
			item.arrow.visible = (item.pivot.children.length > 1 ? true : false);
			
			this._labels.push(item);
			
			if (this._closed[pivot] == undefined) {
				if ((pivot.parent == null) && ((pivot is Scene3D) == false)) {
					this._closed[pivot] = true;
				} else {
					this._closed[pivot] = false;
				}
			}
			item.closed = this._closed[pivot];

			if (!item.closed) {
				if ((pivot.frames != null) && (pivot.frames.length > 0)) {
					item.label.textColor = Style.labelsColor2;
					item.label.draw();
				}
				if (pivot.children.length > 0) {
					for each (var child : Pivot3D in pivot.children) {
						this.createItems(child, level + 1);
					}
				}
				if (pivot is Mesh3D) {
					if (Mesh3D(pivot).render is SkeletonRender) {
						this.createItems(SkeletonRender(Mesh3D(pivot).render).rootBone, level + 1);
					}
				}
			} else {
				item.arrow.rotation = 0;
			}
			this._items[pivot] = item;
		}
		
		private function rightClickEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.RIGHT_CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function closeEvent(e : ControlEvent) : void {
			var item : PivotTreeItem = e.target as PivotTreeItem;
			item.closed = !item.closed;
			TweenLite.to(item.arrow, 0.5, {rotation: (item.closed ? 0 : 90)});
			this._closed[item.pivot] = item.closed;
			this.update();
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}

		public function update() : void {
			this._labels = [];
			if (this._pivot) {
				this.createItems(this._pivot);
			}
			this._list.items = this._labels;
			this.draw();
		}
		
		public function clearCache() : void {
			for each (var item : PivotTreeItem in this._labels) {
				if (item.pivot.parent == null) {
					this.clearCacheAux(item.pivot);
				}
			}
		}
		
		private function clearCacheAux(pivot : Pivot3D) : void {
			delete this._items[pivot];
			for each (var child : Pivot3D in pivot.children) {
				this.clearCacheAux(child);
			}
		}
		
		public function set pivot(pivot : Pivot3D) : void {
			this._pivot = pivot;
			this.clearCache();
			this.update();
		}

		public function get pivot() : Pivot3D {
			return this._pivot;
		}

		public function get multiSelect() : Boolean {
			return this._multiSelect;
		}

		public function set multiSelect(value : Boolean) : void {
			this._multiSelect = value;
		}

		public function get list() : List {
			return this._list;
		}

		public function get labels() : Array {
			return this._labels;
		}

		public function filter(func : Function = null) : void {
			var arr : Array = [];
			for each (var item : PivotTreeItem in this._items) {
				if (func == null || func(item)) {
					item.reset();
					arr.push(item);
				}
			}
			this._list.items = arr;
			this._list.selected = [];
			this.draw();
		}
		
		public function selectAllItems() : void {
			if (this._list.items.length > 0) {
				this._list.selected = this._list.items;
			}
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}
		
		public function deselectAll() : void {
			this._list.selected = [];
		}
		
		public function get selected() : Array {
			var arr : Array = [];
			for each (var item : PivotTreeItem in this._list.selected) {
				arr.push(item.pivot);
			}
			return arr;
		}
		
		public function set selected(items : Array) : void {
			var arr : Array = [];
			for each (var child : Pivot3D in items) {
				for each (var item : PivotTreeItem in this._list.items) {
					if (item.pivot == child) {
						arr.push(item);
					}
				}
			}
			this._list.selected = arr;
		}

	}
}
