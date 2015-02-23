package ui.core.event {

	import flash.events.Event;

	public class AppEvent extends Event {

		public static const CLOSING : String = "app:closing";

		public function AppEvent(type : String) {
			super(type);
		}

		override public function clone() : Event {
			return new AppEvent(type);
		}

		override public function toString() : String {
			return formatToString("AppEvent", "type");
		}

	}
}
