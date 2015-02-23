package ui.core.controls {

	import ui.core.Style;

	public class Separator extends Control {

		public static const VERTICAL : String = "vertical";
		public static const HORIZONTAL : String = "horizontal";

		private var _orientation : String;

		public function Separator(model : String = "horizontal") {
			this._orientation = model;

			if (model == HORIZONTAL) {
				maxHeight = 4;
				minHeight = 4;
			} else {
				maxWidth = 4;
				minWidth = 4;
			}
			flexible = 1;
		}

		override public function draw() : void {
			view.graphics.clear();
			view.graphics.lineStyle(1, Style.borderColor3, 1, true);

			if (this._orientation == HORIZONTAL) {
				view.graphics.moveTo(0, 2);
				view.graphics.lineTo(width, 2);
			} else {
				view.graphics.moveTo(2, 0);
				view.graphics.lineTo(2, height);
			}
		}

	}
}
