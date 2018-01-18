package ui.core.controls {

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import ui.core.type.Align;

	/**
	 *
	 * @author neil
	 *
	 */
	public class BitmapFont {

		private static var textField : TextField = new TextField();

		private var _bmp 	: BitmapData;			// bitmapdata
		private var _matrix : Matrix;				// matrix
		private var _rect 	: Vector.<Rectangle>;	// rect
		
		/**
		 * 文本格式 
		 * @param format	format
		 * @param filters	滤镜
		 * 
		 */		
		public function BitmapFont(format : TextFormat = null, filters : Array = null) {
			this._matrix = new Matrix();
			this.createFont(format, filters);
		}
		
		/**
		 * 创建font 
		 * @param format
		 * @param filters
		 */		
		private function createFont(format : TextFormat, filters : Array) : void {
			
			textField.text 			= "|";
			textField.autoSize 		= "left";
			textField.antiAliasType = AntiAliasType.ADVANCED;
			
			this._rect = new Vector.<Rectangle>();
			
			if (format != null) {
				textField.defaultTextFormat = format;
			}
			this._bmp = new BitmapData(0x0200, 0x0200, true, 0);
			var tmpMatrix : Matrix = new Matrix();
			// 初始化96个默认字符
			var i : int = 32;

			while (i < 128) {
				textField.text = String.fromCharCode(i);

				if ((tmpMatrix.tx + textField.width) >= this._bmp.width) { // 换行
					tmpMatrix.tx = 0;
					tmpMatrix.ty = tmpMatrix.ty + textField.height;
				}
				this._bmp.draw(textField, tmpMatrix, null, null, null, true);
				this._rect[this._rect.length] = new Rectangle(tmpMatrix.tx, tmpMatrix.ty, textField.width + 4, textField.height);
				tmpMatrix.tx = tmpMatrix.tx + textField.width + 5;
				i++;
			}
			var _tmpBmd : BitmapData = new BitmapData(this._bmp.width, tmpMatrix.ty + textField.height + 4, true, 0);
			_tmpBmd.draw(this._bmp, new Matrix(1, 0, 0, 1, -2));
			this._bmp.dispose();
			this._bmp = _tmpBmd;

			if (filters) {
				for each (var filter : BitmapFilter in filters) {
					this._bmp.applyFilter(this._bmp, this._bmp.rect, new Point(), filter);
				}
			}
		}

		/**
		 * 获取字符的宽度
		 * @param value
		 * @return
		 *
		 */
		public function textWidth(value : String) : Number {
			var rect : Rectangle;

			if (value == null || value.length == 0) {
				return 0;
			}
			var len : int = value.length;
			var res : Number = 0;
			var i : Number = 0;

			while (i < len) {
				var code : int = value.charCodeAt(i) - 32;

				// 无该字符
				if (code > this._rect.length || code < 0) {
					code = 0;
				}
				rect = this._rect[code];
				res = res + rect.width - 8;
				i++;
			}
			return (res);
		}

		/**
		 * 获取字符高度
		 * @return
		 *
		 */
		public function textHeight() : Number {
			return this._rect[0].height;
		}
		
		/**
		 * 绘制文本
		 * @param graphics		画布
		 * @param x				x坐标
		 * @param y				y坐标
		 * @param maxWidth		最大宽度
		 * @param maxHeight		最大高度
		 * @param txt			文本
		 * @param align			对齐方式
		 * 
		 */		
		public function draw(graphics : Graphics, x : Number, y : Number, maxWidth : Number, maxHeight : Number, txt : String, align : uint = 0) : void {
			var txtWidth  : Number = this.textWidth(txt);
			var txtHeight : Number = this._rect[0].height;
			
			if (this.textWidth("...") >= maxWidth) {
				return;
			}
			
			if (txtWidth > maxWidth) {
				while (this.textWidth(txt + "...") > maxWidth) {
					txt = txt.substr(0, -1);
				}
				txt = txt + "...";
				txtWidth = this.textWidth(txt);
			}

			if (align & Align.HCENTER) {
				x = x + Math.ceil((maxWidth * 0.5) - (txtWidth * 0.5));
			} else if (align & Align.LEFT) {
				x = x + 0;
			} else if (align & Align.RIGHT) {
				x = x + maxWidth - txtWidth;
			}

			if (align & Align.VCENTER) {
				y = y + Math.ceil((maxHeight * 0.5) - (txtHeight * 0.5));
			} else if (align & Align.TOP) {
				y = y + 0;
			} else if (align & Align.BOTTOM) {
				y = y + maxHeight - txtHeight;
			}
			
			graphics.lineStyle();
			var len : int = txt != null ? txt.length : 0;
			var i   : Number = 0;
			while (i < len) {
				var code : int = txt.charCodeAt(i) - 32;
				// 无该字符集
				if (code > this._rect.length) {
					code = 0;
				}
				var rect : Rectangle = this._rect[code];
				this._matrix.tx = -rect.x + x;
				this._matrix.ty = -rect.y + y;
				graphics.beginBitmapFill(this._bmp, this._matrix, false);
				graphics.drawRect(x, y, rect.width, rect.height);
				x = x + rect.width - 8;
				i++;
			}
		}

	}
}
