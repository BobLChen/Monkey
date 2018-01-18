package ui.core.controls {

	import flash.display.Sprite;

	/**
	 * view
	 * @author neil
	 *
	 */
	public class View extends Sprite {

		private var _control : Control;		
		
		/**
		 * 初始化view 
		 * @param conttol	控制器
		 * 
		 */		
		public function View(conttol : Control) {
			this._control   = conttol;
			this.tabEnabled = false;
			this.focusRect  = false;
		}
		
		/**
		 * 控制器 
		 * @return 
		 * 
		 */		
		public function get control() : Control {
			return this._control;
		}

	}
}
