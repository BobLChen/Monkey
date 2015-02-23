package ide.events {

	import flash.events.Event;

	public class FrameEvent extends Event {

		public static const CHANGE   : String = "frame:change";
		public static const CHANGING : String = "frame:changing";

		public function FrameEvent(type : String) {
			super(type);
		}
		
		override public function clone() : Event {
			return new FrameEvent(type);
		}

		override public function toString() : String {
			return formatToString("FrameEvent", "type");
		}

	}
}
