package ui.core.controls {

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 *
	 * @author neil
	 *
	 */
	public class ToolTip extends Sprite {

		private static var _toolTip  : ToolTip = new ToolTip();
		private static var _texts 	 : Dictionary = new Dictionary(true);
		private static var _interval : int = -1;
		private static var _temp 	 : Point = new Point();

		private var _sprite : Sprite;
		private var _text 	: String;
		private var _info 	: TextField;

		public static function get toolTip() : ToolTip {
			return _toolTip;
		}
		
		public function ToolTip() {
			this._sprite = new Sprite();
			this._info   = new TextField();
			this._info.selectable = false;
			this._info.textColor  = 0x808080;
			this._info.defaultTextFormat = new TextFormat("calibri", 11, 0);
			this._info.wordWrap  = false;
			this._info.multiline = false;
			this._info.autoSize  = TextFieldAutoSize.LEFT;
			this._sprite.addChild(this._info);
			this._sprite.filters = [new DropShadowFilter(4, 45, 0, 0.5, 4, 4)];
			this.width   = 200;
			this.height  = 200;
			this.visible = false;
			this.addChild(_sprite);
		}
		
		/**
		 * 设置ToolTip
		 * @param control
		 * @param txt
		 *
		 */
		public static function setToolTip(control : Control, txt : String = null) : void {
			if (txt != null) {
				control.view.addEventListener(MouseEvent.MOUSE_MOVE, toolTipMouseOverEvent, false, 0, true);
				control.view.addEventListener(MouseEvent.MOUSE_OUT, toolTipMouseOutEvent, false, 0, true);
				if (control.view.stage) {
					control.view.stage.addEventListener(MouseEvent.MOUSE_DOWN, toolTipMouseOutEvent, false, 0, true);
				}
				_texts[control] = txt;
			} else {
				control.view.removeEventListener(MouseEvent.MOUSE_MOVE, toolTipMouseOverEvent);
				control.view.removeEventListener(MouseEvent.MOUSE_OUT, toolTipMouseOutEvent);
				if (control.view.stage) {
					control.view.stage.removeEventListener(MouseEvent.MOUSE_DOWN, toolTipMouseOutEvent);
				}
				delete _texts[control];
			}
		}

		/**
		 * 获取control的tip
		 * @param control
		 * @return
		 *
		 */
		public static function getToolTip(control : Control) : String {
			return _texts[control];
		}

		/**
		 * mouse out event
		 * @param e
		 *
		 */
		private static function toolTipMouseOutEvent(e : MouseEvent = null) : void {
			if (_interval >= 0) {
				clearTimeout(_interval);
			}
			_toolTip.visible = false;
		}

		/**
		 * mouse over
		 * @param e
		 */
		private static function toolTipMouseOverEvent(e : MouseEvent) : void {
			var view : View = e.currentTarget as View;
			_temp.setTo(view.mouseX, view.mouseY);
			var pos : Point = view.localToGlobal(_temp);
			_toolTip.x = (pos.x + 20);
			_toolTip.y = (pos.y + 20);
			_toolTip.text = _texts[view.control];
			if (_interval >= 0) {
				clearTimeout(_interval);
			}
			_interval = setTimeout(showToolTip, 250);
		}

		private static function showToolTip() : void {
			_toolTip.visible = true;
		}

		public function get text() : String {
			return this._text;
		}

		public function set text(txt : String) : void {
			this._text = txt != null ? txt : "";
			this._info.htmlText = this._text;
			this._info.x = 3;
			this._info.y = 3;
			this._sprite.graphics.clear();
			this._sprite.graphics.beginFill(16777147);
			this._sprite.graphics.drawRoundRect(0, 0, this._info.textWidth + 10, this._info.textHeight + 10, 10, 10);
			this.width  = this._sprite.width + 5;
			this.height = this._sprite.height + 5;
		}

	}
}
