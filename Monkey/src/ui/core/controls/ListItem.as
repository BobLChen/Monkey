package ui.core.controls {

	import ui.core.type.Align;

	public class ListItem extends Label {

		public var data : Object;
		
		public function ListItem(txt : String = "", data : Object = null) {
			super(txt, -1, Align.LEFT);
			this.data = data;
		}
	}
}
