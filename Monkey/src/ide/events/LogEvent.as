package ide.events {

	import flash.events.Event;

	public class LogEvent extends Event {
		
		public static const LOG 	: String = "LogEvent:log";
		public static const ERROR 	: String = "LogEvent:error";
		public static const NORMAL 	: String = "LogEvent:normal";
		public static const WARNING : String = "LogEvent:warning";
				
		public var level: String;
		public var log 	: String;
		
		public function LogEvent(msg : String, level : String = LOG) {
			super(LOG);
			this.log   = msg;
			this.level = level;
		}
	}
}
