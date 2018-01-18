package ui.core.controls {

	public class Spacer extends Control {
		public function Spacer(min : Number = -1, max : Number = -1) {
			super("", 0, 0, 20, 20);
			this.flexible = 1;
			if (min != -1) {
				this.minWidth = (maxWidth = min)
			}
			if (max != -1) {
				this.minHeight = (maxHeight = max);
			}
		}
	}
}
