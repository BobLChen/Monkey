package ui.core.interfaces {

	public interface IUndoOperation {

		function undo() : void;
		function redo() : void;
		function toString() : String;

	}
}
