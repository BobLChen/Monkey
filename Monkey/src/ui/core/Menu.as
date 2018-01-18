package ui.core {

	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	/**
	 * menu 
	 * @author neil
	 * 
	 */	
	public class Menu extends EventDispatcher {
		
		private var _menu : ContextMenu;
		
		public function Menu() : void {
			this._menu = new ContextMenu();
		}
		
		public function get menu():ContextMenu {
			return this._menu;
		}
		
		public function items() : Array {
			return this._menu.customItems;
		}
		
		/**
		 * call menuItem 
		 * @param menutxt
		 * @return 
		 * 
		 */		
		public function callMenuItem(menutxt : String) : Boolean {
			var item : ContextMenuItem = this.getMenuItem(menutxt);
			if (item) {
				item.dispatchEvent(new Event(Event.SELECT));
			} else {
				return false;
			}
			return true;
		}
		
		/**
		 * get item 
		 * @param txt
		 * @return 
		 * 
		 */		
		public function getMenuItem(txt : String) : ContextMenuItem {
			for (var i:int = 0; i < _menu.customItems.length; i++) {
				if (_menu.customItems[i] is ContextMenuItem) {
					var item : ContextMenuItem = _menu.customItems[i] as ContextMenuItem;
					if (item.caption == txt) {
						return item;
					}
				}
			}
			return null;
		}
		
		/**
		 * 添加一个Item
		 * @param txt			名称
		 * @param callback		回调函数
		 * @param keys			快捷键
		 * @param short			组合键
		 * @return 
		 * 
		 */		
		public function addMenuItem(txt : String = null, callback : Function = null) : ContextMenuItem {
			var item : ContextMenuItem = null;
			for (var i:int = 0; i < _menu.customItems.length; i++) {
				if (_menu.customItems[i] is ContextMenuItem) {
					item = _menu.customItems[i] as ContextMenuItem;
					if (item.caption == txt) {
						return item;
					}
				}
			}
			item = new ContextMenuItem(txt);
			this._menu.customItems.push(item);
			if (callback != null) {
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, callback);
			}
			return item;
		}
		
	}
}
