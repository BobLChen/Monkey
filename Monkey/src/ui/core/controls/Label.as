package ui.core.controls {

	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;

	/**
	 * label
	 * @author neil
	 *
	 */
	public class Label extends Control {

		private var _fieldtxt 	: TextField;
		private var _align 		: uint;
		private var _format 	: TextFormat;
		private var _userToolTip: String;
		private var _linkMode 	: Boolean;
		private var _autoSize 	: Boolean;
		
		/**
		 *  
		 * @param txt			文本
		 * @param width			宽度
		 * @param align			Align
		 * @param selectable	是否可选中
		 * 
		 */		
		public function Label(txt : String = "", width : Number = -1, align : uint = 1, selectable : Boolean = false) {
			super(txt, 0, 0, width, 20);
			this._fieldtxt = new TextField();
			this.view.addChild(this._fieldtxt);
			
			var leading : String = "left";
			if (align == Align.RIGHT) {
				leading = "right";
			} else if (align == Align.HCENTER) {
				leading = "center";
			}
			
			this._format = new TextFormat(Style.defaultFormat.font, Style.defaultFormat.size, Style.defaultFormat.color, Style.defaultFormat.bold, Style.defaultFormat.italic, Style.defaultFormat.underline,
				Style.defaultFormat.url, Style.defaultFormat.target, leading);
			this._align = align;
			this._fieldtxt.defaultTextFormat = this._format;
			this._fieldtxt.selectable = selectable;
			this._fieldtxt.mouseEnabled = selectable;
			this._fieldtxt.tabEnabled = false;
			this._fieldtxt.multiline = false;
			this._fieldtxt.type = TextFieldType.DYNAMIC;
			
			this.text = txt;
			
			this.view.cacheAsBitmap = true;
			this.view.addEventListener(MouseEvent.CLICK, this.clickEvent);
			this.flexible  = 1;
			this.minWidth  = width;
			this.maxWidth  = width;
			this.maxHeight = 20;
			this.minHeight = 17;
			
			this.draw();
		}
				
		private function clickEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		public function get text() : String {
			return this._fieldtxt.text;
		}
		
		public function set text(value : String) : void {
			this._fieldtxt.text = value;
			this.draw();
		}
		
		public function set autoSize(value : Boolean) : void {
			this._autoSize = value;
		}
		
		public function set textSize(value : int) : void {
			this._format.size = value;
			this._fieldtxt.defaultTextFormat = _format;
			this.draw();
		}
		
		public function get textColor() : int {
			return (int(this._format.color));
		}

		public function set textColor(color : int) : void {
			this._format.color = color;
			this._fieldtxt.defaultTextFormat = this._format;
			this._fieldtxt.setTextFormat(this._format);
			this.draw();
		}

		public function get italic() : Boolean {
			return (Boolean(this._format.italic));
		}

		public function set italic(value : Boolean) : void {
			this._format.italic = value;
			this._fieldtxt.defaultTextFormat = this._format;
			this._fieldtxt.setTextFormat(this._format);
			this.draw();
		}
		
		override public function set toolTip(value : String) : void {
			this._userToolTip = value;
			super.toolTip = value;
		}

		public function get linkMode() : Boolean {
			return this._linkMode;
		}

		public function set linkMode(value : Boolean) : void {
			this._linkMode = value;
			this.view.buttonMode = value;
			this.view.useHandCursor = value;
			this.draw();
		}
		
		override public function draw() : void {
			this.view.graphics.clear();
			if (_autoSize) {
				this.minWidth 	= this._fieldtxt.textWidth;
				this.maxWidth 	= this._fieldtxt.textWidth;
				this.width 		= this._fieldtxt.textWidth;
				this.minHeight 	= this._fieldtxt.textHeight;
				this.maxHeight 	= this._fieldtxt.textHeight;
				this.height 	= this._fieldtxt.textHeight;
			}
			this._fieldtxt.width  = width;
			this._fieldtxt.height = height;
			if (this._linkMode) {
				this.view.graphics.beginFill(0, 0);
				this.view.graphics.drawRect(0, 0, width, height);
				this.view.graphics.lineStyle(1, this._fieldtxt.textColor, 1, true);
				if (this._align == Align.LEFT) {
					this.view.graphics.moveTo(0, (this._fieldtxt.textHeight + 1));
					this.view.graphics.lineTo(width, (this._fieldtxt.textHeight + 1));
				} else if (this._align == Align.RIGHT) {
					this.view.graphics.moveTo(((width - this._fieldtxt.textWidth) - 5), (this._fieldtxt.textHeight + 1));
					this.view.graphics.lineTo(width, (this._fieldtxt.textHeight + 1));
				}
			}
			if (this._userToolTip) {
				super.toolTip = this._userToolTip;
			} else if (this._fieldtxt.width < this._fieldtxt.textWidth) {
				super.toolTip = this._fieldtxt.text;
			} else {
				super.toolTip = null;
			}
		}

	}
}
