package ui.core.event {

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ui.core.controls.Control;

	public class ControlEvent extends MouseEvent {

		public static const CLICK : String = "click";
		public static const CLICK_ITEM : String = "click_ITEM";
		public static const RIGHT_CLICK : String = "rightClick";
		public static const DOUBLE_CLICK : String = "doubleClick";
		public static const CHANGE : String = "change";
		public static const STOP : String = "stop";
		public static const UNDO : String = "undo";
		public static const DRAW:String = "draw";
		
		private var _target : Control;

		public function ControlEvent(type : String, target : Control, ctrlKey : Boolean = false, altKey : Boolean = false, shiftKey : Boolean = false, buttonDown : Boolean = false) {
			super(type, false, false, NaN, NaN, ((target != null) ? target.view : null), ctrlKey, altKey, shiftKey, buttonDown); 
			this._target = target;
		}  

		override public function get target() : Object {
			return this._target;
		}

		override public function get currentTarget() : Object {
			return this._target;
		}

		override public function clone() : Event {
			return new ControlEvent(type, this._target, ctrlKey, altKey, shiftKey, ctrlKey);
		}

		override public function toString() : String {
			return formatToString("ControlEvent", "type", "target");
		}

	}
}
