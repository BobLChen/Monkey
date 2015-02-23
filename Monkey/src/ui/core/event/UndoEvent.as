package ui.core.event {

	import flash.events.Event;
	import ui.core.interfaces.IUndoOperation;

	public class UndoEvent extends Event {

		public static const UNDO : String = "undo";
		public static const REDO : String = "redo";
		public static const PUSH : String = "pushUndo";
		public static const POP : String = "popUndo";

		private var _operation : IUndoOperation;

		public function UndoEvent(type : String, operation : IUndoOperation) {
			super(type, bubbles, cancelable);
			this._operation = operation;
		}

		override public function clone() : Event {
			return new UndoEvent(type, this.operation);
		}

		override public function toString() : String {
			return formatToString("UndoRedoEvent", "type", "operation");
		}

		public function get operation() : IUndoOperation {
			return this._operation;
		}

	}
}
