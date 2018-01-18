package ui.core.event {

	import flash.events.Event;

	public class PanelEvent extends Event {

		public static const ACTIVATE : String = "panel:activate";
		public static const DEACTIVATE : String = "panel:deactivate";

		public function PanelEvent(type : String) {
			super(type);
		}

		override public function clone() : Event {
			return new PanelEvent(type);
		}

		override public function toString() : String {
			return formatToString("PanelEvent", "type");
		}

	}
}
