package ide.events {

	import flash.events.Event;

	public class SelectionEvent extends Event {

		public static const CHANGE 			: String = "selection:change";
		public static const CHANGE_MATERIAL : String = "selection:changeMaterial";
		public static const CHANGE_GEOMETRY : String = "selection:changeGeometry";
		
		public function SelectionEvent(type : String) {
			super(type, false, false);
		}
	}
}
