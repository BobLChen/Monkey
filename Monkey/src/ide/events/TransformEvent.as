package ide.events {

	import flash.events.Event;

	public class TransformEvent extends Event {

		public static var SELECT	: String = "transform:select";
		public static var MOVE 		: String = "transform:move";
		public static var ROTATE 	: String = "transform:rotate";
		public static var SCALE 	: String = "transform:scale";
		public static var CHANGE	: String = "transform:change";
		
		public function TransformEvent(type : String) {
			super(type, false, false);
		}

		override public function clone() : Event {
			return new TransformEvent(type);
		}

		override public function toString() : String {
			return formatToString("TransformEvent", "type");
		}
		
	}
}
