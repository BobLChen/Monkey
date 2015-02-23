package ui.core {

	import flash.events.EventDispatcher;
	
	import ui.core.event.UndoEvent;
	import ui.core.interfaces.IUndoOperation;

	/**
	 * Undo event
	 * @author neil
	 */
	public class Undo extends EventDispatcher {

		private var _invalidate : Boolean = false;
		private var _operations : Vector.<IUndoOperation>;
		private var _index 		: int = -1;
		
		public function Undo() {
			this.clearAll();
		}

		public function clearAll() : void {
			this._operations = new Vector.<IUndoOperation>();
		}

		public function push(operation : IUndoOperation) : void {
			if (this._invalidate) {
				return;
			}
			this._operations.splice((this._index + 1), this._operations.length, operation);
			this._index = this._operations.length - 1;
			this.dispatchEvent(new UndoEvent(UndoEvent.PUSH, operation));
		}

		public function pop() : IUndoOperation {
			if (this._invalidate) {
				return null;
			}
			if (this._index < 0) {
				return null;
			}
			var operation : IUndoOperation = this._operations[this._index];
			this._operations.splice(this._index, 1);
			this.dispatchEvent(new UndoEvent(UndoEvent.POP, operation));
			return operation;
		}

		public function undo() : void {
			this._invalidate = true;

			if (this._index >= 0) {
				var operation : IUndoOperation = this._operations[this._index];
				operation.undo();
				this._index--;
				this.dispatchEvent(new UndoEvent(UndoEvent.UNDO, operation));
			}
			this._invalidate = false;
		}

		public function redo() : void {
			this._invalidate = true;

			if (this._index < (this._operations.length - 1)) {
				this._index++;
				var operation : IUndoOperation = this._operations[this._index];
				operation.redo();
				dispatchEvent(new UndoEvent(UndoEvent.REDO, operation));
			}
			this._invalidate = false;
		}

		public function canUndo() : IUndoOperation {
			return ((this._index >= 0) ? this._operations[this._index] : null);
		}

		public function canRedo() : IUndoOperation {
			return ((this._index < (this._operations.length - 1)) ? this._operations[(this.index + 1)] : null);
		}

		public function get index() : int {
			return this._index;
		}

		public function set index(idx : int) : void {
			if (this._index < idx) {
				while (this._index < idx) {
					this.redo();
				}
			} else {
				while (this._index > idx) {
					this.undo();
				}
			}
		}

		public function get operations() : Vector.<IUndoOperation> {
			return (this._operations);
		}

	}
}
