package ui.core.controls {
		
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import ui.core.container.Accordion;
	import ui.core.container.Box;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;
	
	/**
	 * 
	 * @author neil
	 * 
	 */	
	public class ComboBox extends Accordion {
		
		private var items : Array;
		private var datas : Array;
		
		private var _boxList : Box;
		private var _list : Array;
		private var _dict : Dictionary;
		private var _label : Label;
		private var _selectedIdx : int;
		private var _selectedItem : ComboxItem;
				
		public function ComboBox(items : Array = null, datas : Array = null) {
			super();
			this._dict = new Dictionary();
			this._list = new Array();
			this._boxList = new Box();							
			this._boxList.orientation = Box.VERTICAL;
			this._boxList.space = 0;
			this._boxList.width = this.width;
			this._boxList.height = this.width;
			this.addControl(this._boxList);
			if (items == null)
				items = [];
			if (datas == null)
				datas = [];
			for (var i:int = 0; i < items.length; i++) {
				addItem(items[i], datas[i]);
			}
			this._label = new Label();
			this._label.width = _header.width;
			this._label.height = HEADER_HEIGHT;
			this._header.addChild(_label.view);
			if (items != null) {
				this._label.text = items[0];
				this.selectedItem = items[0];
			}
			this.open = false;
		}
		
		override public function set open(value:Boolean):void {
			this._open = value;
			if (value) {
				this._box.visible = true;
				TweenLite.to(this._arrow, 0.25, {rotation: 90});
				maxHeight = (HEADER_HEIGHT + Math.max(this._box.minHeight, 0));
				minHeight = (HEADER_HEIGHT + Math.max(this._box.minHeight, 0));
			} else {
				this._box.visible = false;
			}
		}
		
		
		/**
		 *  
		 * 增加item
		 * @param item
		 * @param value
		 * 
		 */		
		public function addItem(item : String, value : Object) : void {
			var button : InputText = new InputText(item);
			button.minWidth = -1;
			button.maxWidth = -1;
			button.textField.selectable = false;
			button.width = width;
			button.addEventListener(MouseEvent.CLICK, onSelected);
			_list.push(new ComboxItem(button, value));
			_dict[button.text] = _list[_list.length - 1];
			_boxList.addControl(button);
			_boxList.normalize();
			_boxList.update();
			_boxList.draw();
		}
		
		protected function onSelected(event:Event) : void {
			var btn : InputText = (event.target as InputText);
			var item : ComboxItem = _dict[btn.text];
			this._selectedItem = item;
			this._selectedIdx = _list.indexOf(item);
			this.open = false;
			this._label.text = btn.text;
			this.dispatchEvent(new ControlEvent(ControlEvent.CHANGE, this));
		}
		
		public function get selectedItem() : String {
			return this._selectedItem.item.text;
		}
		
		public function set selectedItem(item : String) : void {
			var comItem : ComboxItem = _dict[item];
			if (comItem == null)
				return;
			this._selectedItem = comItem;
			this._selectedIdx = _list.indexOf(this._selectedItem);
			this._label.text = item;
		}
				
		public function get selectedValue() : Object {
			return this._selectedItem.value;
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			this.draw();
		}
		
		override public function draw() : void {
			super.draw();
			this._box.width = width;
			this._box.height = (height - HEADER_HEIGHT);
			this._box.update();
			this._box.draw();
			if (this._boxList != null) {
				this._boxList.width = width;
				this._boxList.height = height - HEADER_HEIGHT;
				this._boxList.update();
				this._boxList.draw();
			}
			this._header.graphics.clear();
			this._header.graphics.beginFill(0xB0B0B0);
			this._header.graphics.drawRect(0, 0, width, HEADER_HEIGHT);
			this._arrow.x = width - 10;
			this._arrow.y = ((HEADER_HEIGHT * 0.25) + 0);
			font.draw(this._header.graphics, 15, -1, (width - 10), HEADER_HEIGHT, this.text, (Align.LEFT + Align.VCENTER));
			this.view.addChildAt(this._header, 0);
			if (this._label != null) {
				this._label.width = this.width;
			}
		}
		
	}
}
import ui.core.controls.InputText;


class ComboxItem {
	
	public var item : InputText;
	public var value : Object;
	
	public function ComboxItem(item : InputText, value : Object) : void {
		this.item = item;
		this.value = value;
	}
	
}
