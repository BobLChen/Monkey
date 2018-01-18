package ide.plugins {

	import flash.events.Event;
	
	import ide.App;
	import ide.events.SceneEvent;
	import ide.events.SelectionEvent;
	import ide.panel.PivotTree;
	
	import monkey.core.base.Object3D;
	
	import ui.core.container.Panel;
	import ui.core.controls.Layout;
	import ui.core.event.ControlEvent;
	import ui.core.event.DragDropEvent;
	import ui.core.interfaces.IPlugin;
		
	/**
	 * Hierarchy
	 * @author Neil
	 * 
	 */	
	public class HierarchyPlugin implements IPlugin {

		private var _app 		: App;
		private var _panel 		: Panel;
		private var _filterText : String;
		private var _autoSelect : Boolean = true;
		private var _sceneTree 	: PivotTree;
		private var _filterExp 	: RegExp;
		
		public function HierarchyPlugin() {
			super();
		}

		public function init(app : App) : void {
			this._app = app;
			this._panel = new Panel("HIERARCHY", 260, 400, false);
			this._panel.minWidth = 260;
			this._panel.minHeight = 50;
			
			var layout : Layout = new Layout();
			this._sceneTree = layout.addControl(new PivotTree()) as PivotTree;
			this._sceneTree.addEventListener(ControlEvent.CLICK, this.treeClickEvent);
			this._sceneTree.addEventListener(DragDropEvent.DRAG_DROP, this.dragDropEvent);
			this._panel.addControl(layout);
						
			this._app.addEventListener(SceneEvent.CHANGE, this.sceneChangeEvent);
			this._app.addEventListener(SelectionEvent.CHANGE, this.changeSelectionEvent);
			this._app.studio.hierarchy.addPanel(this._panel);
			this._app.studio.hierarchy.open();
		}
		
		private function changeSelectionEvent(event : Event) : void {
			this._sceneTree.selected = this._app.selection.objects;
			this._sceneTree.draw();
		}

		private function sceneChangeEvent(event : Event) : void {
			this._sceneTree.pivot = this._app.scene;
			this._sceneTree.draw();
		}
		
		private function dragDropEvent(event : DragDropEvent) : void {
			if (event.dropOver == false) {
				return;
			}
			if (this._sceneTree.selected.length >= 2) {
				return;
			}
			var selected : Array = this._sceneTree.selected;
			var overPivot : Object3D = this._sceneTree.list.items[event.dropIndex].pivot;
			if (selected.indexOf(overPivot) != -1) {
				return;
			}
			for each (var pivot : Object3D in selected) {
				if (overPivot.parent == pivot) {
					continue;
				}
				pivot.parent = overPivot;
			}
			this._app.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
		}
			
		private function treeChangeEvent(event : Event) : void {
			this._app.selection.objects = this._sceneTree.selected;
		}
		
		private function treeClickEvent(event : Event) : void {
			this._app.selection.objects = this._sceneTree.selected;
		}

		public function start() : void {

		}
	}
}
