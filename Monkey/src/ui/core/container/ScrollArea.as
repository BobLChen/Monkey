package ui.core.container {

	import com.greensock.TweenLite;
	
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import ui.core.Style;
	import ui.core.controls.Control;
	import ui.core.controls.Slider;
	import ui.core.event.ControlEvent;

	/**
	 * scroll area
	 * @author neil
	 *
	 */
	public class ScrollArea extends Container {

		private var _xScroll : Slider;
		private var _yScroll : Slider;
		private var _rect : Rectangle;
		private var _contentWidth : Number = 0;
		private var _contentHeight : Number = 0;
		private var _totalWidth : Number;
		private var _totalHeight : Number;

		public function ScrollArea() {
			super();
			this._xScroll = new Slider(Slider.HORIZONTAL);
			this._yScroll = new Slider(Slider.VERTICAL);
			this._rect = new Rectangle();
			this._rect.setTo(0, 0, 100, 100);
			this.showBorders = true;
			this.background = true;
			this.minWidth = 30;
			this.minHeight = 30;
			this.view.addChild(this._xScroll.view);
			this.view.addChild(this._yScroll.view);
			this.view.addEventListener(MouseEvent.MOUSE_WHEEL, this.mouseWhellEvent);
			this._xScroll.visible = false;
			this._yScroll.visible = false;
			this._xScroll.addEventListener(ControlEvent.CHANGE, this.scrollEvent);
			this._yScroll.addEventListener(ControlEvent.CHANGE, this.scrollEvent);
		}

		private function mouseWhellEvent(e : MouseEvent) : void {
			e.stopImmediatePropagation();
			this._yScroll.max = (this._totalHeight - this.contentHeight);
			TweenLite.to(this._yScroll, 0.25, {position: (this._yScroll.position - (20 * e.delta)), onUpdate: this.updateRect, onComplete: this.draw});
		}
	
		override public function update() : void {
			
			this._xScroll.visible = false;
			this._yScroll.visible = false;
			this._contentWidth = width;
			this._contentHeight = height;
			this._totalWidth = 0;
			this._totalHeight = 0;

			for each (var control : Control in controls) {
				if (!control.visible) {
					
				} else if ((control is Container) || control.flexible != 0) {
					this._totalWidth = Math.max(this._totalWidth, control.x + control.minWidth);
					this._totalHeight = Math.max(this._totalHeight, control.y + control.minHeight);
				} else {
					this._totalWidth = Math.max(this._totalWidth, control.x + control.width);
					this._totalHeight = Math.max(this._totalHeight, control.y + control.height);
				}
			}
			
			var i : int = 0;
			while (i < 2) {
				if (this._totalHeight > this._contentHeight) {
					this._contentWidth = (width - 15);
					this._yScroll.visible = true;
				}

				if (this._totalWidth > this._contentWidth) {
					this._contentHeight = (height - 15);
					this._xScroll.visible = true;
				}
				i++;
			}
			
			var w : Number = (this._xScroll.visible && this._yScroll.visible) ? 15 : 0;
			this._yScroll.x = width - 15;
			this._yScroll.y = 0;
			this._yScroll.width = 15;
			this._yScroll.height = height - w;
			this._xScroll.x = 0;
			this._xScroll.y = height - 15;
			this._xScroll.width = width - w;
			this._xScroll.height = 15;

			if (this._xScroll.y < 15) {
				this._xScroll.y = 15;
			}
			this._yScroll.draw();
			this._xScroll.draw();

			for each (var con : Control in controls) {
				if (con != null) {
					con.width = this.contentWidth;
					con.height = this.contentHeight;
					if (con is Container) {
						Container(con).update();
					}
				}
			}

			if (this._totalWidth < this._contentWidth) {
				this._totalWidth = this._contentWidth;
			}
			this.updateRect();
		}

		private function scrollEvent(e : ControlEvent = null) : void {
			this.updateRect();
		}

		public function get scrollX() : Number {
			return this._rect.x;
		}

		public function set scrollX(value : Number) : void {
			this._xScroll.value = (value / (this._totalWidth - this._contentWidth));
			this.scrollEvent();
		}

		public function get scrollY() : Number {
			return this._rect.y;
		}

		public function set scrollY(value : Number) : void {
			this._yScroll.value = (value / (this._totalHeight - this._contentHeight));
			this.scrollEvent();
		}

		public function get contentWidth() : Number {
			return this._contentWidth;
		}

		public function get contentHeight() : Number {
			return this._contentHeight;
		}

		public function get totalWidth() : Number {
			return this._totalWidth;
		}

		public function get totalHeight() : Number {
			return this._totalHeight;
		}

		private function updateRect() : void {
			if (this._xScroll.visible) {
				this._rect.x = int((this._xScroll.value * (this._totalWidth - this._contentWidth)));
			} else {
				this._rect.x = 0;
			}

			if (this._yScroll.visible) {
				this._rect.y = int((this._yScroll.value * (this._totalHeight - this._contentHeight)));
			} else {
				this._rect.y = 0;
			}
			this._rect.width = this._contentWidth;
			this._rect.height = this._contentHeight;
			content.scrollRect = this._rect;
		}

		override public function draw() : void {
			super.draw();
			this.updateRect();
			for each (var control : Control in controls) {
				control.draw();
			}
			this._yScroll.max = (this._totalHeight - this.contentHeight);
			view.graphics.clear();
			if (background) {
				view.graphics.beginFill(backgroundColor, 1);
				view.graphics.drawRect(0, 0, this.contentWidth, this.contentHeight);
			}
			if ((this._xScroll.visible) && (this._yScroll.visible)) {
				view.graphics.lineStyle(1, Style.borderColor2, 1, true);
				view.graphics.beginFill(backgroundColor);
				view.graphics.drawRect((width - 15), (height - 15), 15, 15);
			}
		}

	}
}
