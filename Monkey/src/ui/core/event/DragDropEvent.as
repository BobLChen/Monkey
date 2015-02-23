package ui.core.event {

	import flash.events.Event;

	public class DragDropEvent extends Event {

		public static const DRAG_DROP : String = "list:dragDrop";

		public var dropOver : Boolean;
		public var dropIndex : int;

		public function DragDropEvent(dropIdx : int, dropOver : Boolean) {
			super(DRAG_DROP);
			this.dropIndex = dropIdx;
			this.dropOver = dropOver;
		}

		override public function clone() : Event {
			return (new DragDropEvent(this.dropIndex, this.dropOver));
		}
		
		override public function toString() : String {
			return (formatToString("DragDropEvent", "dropOver", "dropIndex"));
		}

	}
}
