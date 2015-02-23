package ui.core.controls {

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import ide.App;
	
	import ui.core.Menu;
	import ui.core.Style;
	import ui.core.container.Box;
	import ui.core.container.Container;
	import ui.core.container.Panel;
	import ui.core.event.PanelEvent;
	
	/**
	 * 
	 * @author neil
	 * 
	 */	
	public class TabControl extends Control {
		
		public static const HEADER_HEIGHT : Number = 18;
		[Embed(source = "menuicon.png")]
		private static const MenuIcon : Class;
		private static const menuIcon : BitmapData = new MenuIcon().bitmapData;
				
		private var _panels 			: Vector.<Panel>;			// panels
		private var _panelTabs 			: Vector.<Sprite>;			// tabs
		private var _currentPanel 		: Panel;					// 当前的panel
		private var _rightClickedPanel 	: Panel;					// clicked panel
		private var _header 			: Sprite;					// header
		private var _panel 				: Sprite;					// panel
		private var _background 		: Sprite;					// 背景色
		private var _line 				: Sprite;					// line
		private var _menuBtn 			: ImageButton;				
		private var _menus				: Menu;
		private var _lastTab 			: Tab;
		private var _lastX 				: Number = 0;
		private var _lastY 				: Number = 0;
		
		public function TabControl() {
			this._background 		= new Sprite();
			this._background.name 	= "Background";
			this._header 			= new Sprite();
			this._header.name 		= "Header";
			this._panel 			= new Sprite();
			this._panel.name 		= "Panel";
			this._panels 			= new Vector.<Panel>();
			this._panelTabs 		= new Vector.<Sprite>();
			this._line 				= new Sprite();
			this._line.mouseEnabled = false;
			this._menuBtn 			= new ImageButton(menuIcon);
			this._menuBtn.y = 2;
			this._menuBtn.addEventListener(MouseEvent.CLICK, onClickedMenu);
			this._menus = new Menu();
			this._menuBtn.view.contextMenu = this._menus.menu;
						
			this.flexible = 1;
			this.view.addChild(this._background);
			this.view.addChild(this._header);
			this.view.addChild(this._panel);
			this.view.addChild(this._line);
			this.view.addChild(this._menuBtn.view);
		}
		
		private function onClickedMenu(event:Event) : void {
			if (this._currentPanel) {
				this._menuBtn.view.contextMenu.display(App.core.stage, App.core.stage.mouseX, App.core.stage.mouseY);
			}
		}
		
		public function addMenu(str : String, callback : Function) : void {
			this._menus.addMenuItem(str, callback);
		}
				
		public function addPanel(panel : Panel) : void {
			this.addPanelAt(panel, this._panels.length);
		}

		public function addPanelAt(panel : Panel, idx : int) : void {
			panel.tabControl = this;
			var tab : Tab = new Tab(this, panel);
			tab.addEventListener(MouseEvent.MOUSE_DOWN, this.tabMouseDown, false, 0, true);
			this._panelTabs.splice(idx, 0, tab);
			this._panels.splice(idx, 0, panel);
		}
	
		public function removePanel(panel : Panel) : void {
			var idx : int = this._panels.indexOf(panel);
			if (idx == -1) {
				return;
			}
			this._header.removeChild(this._panelTabs[idx]);
			this._panels.splice(idx, 1);
			this._panelTabs.splice(idx, 1);
			if (this._panels.length > 0) {
				if (this.openPanels.length > 0) {
					this.setCurrentPanel();
				} else {
					this.close();
				}
			} else {
				var container : Container = this.parent;
				container.removeControl(this);
				container.update();
				container.draw();
			}
			this.draw();
		}

		public function open() : void {
			visible = true;
			this.setCurrentPanel(this.currentPanel);
			this.draw();
		}
		
		public function close() : void {
			
		}
		
		private function cleanUp(box : Box = null) : void {
			if (box == null && parent == null) {
				return;
			}
			if (box == null) {
				var parentBox : Box = parent as Box;
				while (parentBox != null) {
					if (parentBox.parent != null) {
						parentBox = parentBox.parent as Box;
					} else {
						break;
					}
				}
			}
			if (parentBox != null) {
				box = parentBox;
			}
			if (box.parent != null && box.controls.length == 1) {
				var idx : int = box.parent.controls.indexOf(box);
				box.parent.addControlAt(box.controls[0], idx);
				box.parent.removeControl(box);
				if ((box.parent is Box)) {
					Box(box.parent).normalize();
				}
				box.normalize();
			}
			if (box.controls.length == 1 && box.controls[0] is Box) {
				var tbox : Box = box.controls[0] as Box;
				while (tbox.controls.length) {
					var tcon : Control = tbox.controls[0];
					box.addControl(tcon);
				}
				Box(box).orientation = tbox.orientation;
				box.removeControl(tbox);
				box.normalize();
			}
			for each (var con : Control in box.controls) {
				if ((con is Box)) {
					this.cleanUp((con as Box));
				}
			}
			box.update();
			box.draw();
		}

		private function tabMouseDown(e : MouseEvent) : void {
			this._lastX = e.stageX;
			this._lastY = e.stageY;
			this._lastTab = (e.currentTarget as Tab);
			this.setCurrentPanel(this._lastTab.panel);
		}

		private function activate() : void {
			this._panel.graphics.beginFill(0xFFFF, 0);
			this._panel.graphics.drawRect(0, 0, width, height);
		}

		private function deactivate() : void {
			this._panel.graphics.clear();
		}

		public function setCurrentPanel(panel : Panel = null) : void {
			if (this._currentPanel != null) {
				this._currentPanel.dispatchEvent(new PanelEvent(PanelEvent.DEACTIVATE));
			}
			if (panel == null) {
				panel = this.openPanels[0];
			}
			for each (var otherPanel : Panel in this.panels) {
				otherPanel.visible = false;
			}
			if (this._currentPanel != null && this._panel.contains(this._currentPanel.view)) {
				this._panel.removeChild(this._currentPanel.view);
			}
			this._currentPanel = panel;
			this._currentPanel.visible = true;
			this._panel.addChild(this._currentPanel.view);
			this.draw();
			if (this._currentPanel) {
				this._currentPanel.dispatchEvent(new PanelEvent(PanelEvent.ACTIVATE));
			}
		}
				
		override public function draw() : void {
			var maxW : Number;
			if (this._currentPanel != null) {
				this._currentPanel.x = 0;
				this._currentPanel.y = HEADER_HEIGHT;
				this._currentPanel.width = width;
				this._currentPanel.height = height - HEADER_HEIGHT;
				this._currentPanel.update();
				if (this._currentPanel.width > 0 && this._currentPanel.height > 0) {
					this._currentPanel.draw();
				}
			}
			var mt : Matrix = new Matrix();
			mt.createGradientBox(width, HEADER_HEIGHT, 90);
			this._background.graphics.clear();
			this._background.graphics.beginFill(0x303030);
			this._background.graphics.drawRect(0, 0, width, HEADER_HEIGHT);
			maxW = width - 22;
			var rw : Number = 0;
			var w  : Number = 0;
			var lx : Number = 0;
			this._menuBtn.x = width - 18;
			var curTab : Tab;
			for each (var tab0 : Tab in this._panelTabs) {
				tab0.selected = false;
				tab0.x = lx;
				if (tab0.panel.closed == false) {
					lx = lx + tab0.width;
					tab0.width = tab0.width
				}
				if (tab0.panel == this._currentPanel) {
					tab0.selected = true;
					curTab = tab0;
				}
				if (tab0.panel.closed == false) {
					tab0.visible = true;
					this._header.addChild(tab0);
				} else {
					tab0.visible = false;
				}
			}
			if (curTab != null) {
				this._header.addChild(curTab);
			}
			if (lx > maxW) {
				do {
					lx = 0;
					for each (tab0 in this._panelTabs) {
						if (tab0.panel.closed == false) {
							tab0.x = lx;
							if (tab0 == curTab) {
								lx = lx + tab0.width;
							} else {
								rw = (maxW - curTab.width) / (this._panelTabs.length - 1) + w;
								if (rw > tab0.width) {
									rw = tab0.width;
								}
								lx = lx + rw;
								tab0.width = rw;
							}
						}
					}
					w = w + ((maxW - lx) / this._panelTabs.length);
				} while (lx < maxW);
				this._header.scrollRect = new Rectangle(0, 0, (maxW + 1), 18);
			} else {
				this._header.scrollRect = null;
			}
			
			if (curTab != null) {
				this._line.graphics.clear();
				this._line.graphics.lineStyle(1, Style.borderColor, 1, true);
				this._line.graphics.moveTo(0, HEADER_HEIGHT);
				this._line.graphics.lineTo(curTab.x, HEADER_HEIGHT);
				if (this._header.scrollRect) {
					this._line.graphics.moveTo(maxW, 0);
					this._line.graphics.lineTo(maxW, HEADER_HEIGHT);
				}
				if ((this._header.scrollRect != null) && ((this._header.scrollRect.width < curTab.width))) {
					this._line.graphics.moveTo(maxW, HEADER_HEIGHT);
					this._line.graphics.lineTo(width, HEADER_HEIGHT);
				} else {
					this._line.graphics.moveTo((curTab.x + curTab.width), HEADER_HEIGHT);
					this._line.graphics.lineTo(width, HEADER_HEIGHT);
				}
				this._line.graphics.drawRect(0, 0, width, height);
			}
		}

		private function get openPanels() : Vector.<Panel> {
			var result : Vector.<Panel> = new Vector.<Panel>();
			for each (var panel : Panel in this._panels) {
				if (panel.closed == false) {
					result.push(panel);
				}
			}
			return result;
		}

		public function get panels() : Vector.<Panel> {
			return this._panels;
		}

		public function get currentPanel() : Panel {
			return this._currentPanel;
		}

	}
}


import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.text.TextFormat;

import ui.core.Style;
import ui.core.container.Panel;
import ui.core.controls.BitmapFont;
import ui.core.controls.TabControl;
import ui.core.type.Align;

class Tab extends Sprite {

	private static var font : BitmapFont = new BitmapFont(new TextFormat("Arial", 10, 0xB0B0B0, true), [new DropShadowFilter(4, 45, 0, 0.3, 4, 4, 1, 4)]);

	private var _selected : Boolean;
	private var _background : Sprite;
	private var _foreground : Sprite;
	private var _lines : Shape;
	private var _width : Number = 0;
	public var tabControl : TabControl;
	public var panel : Panel;

	public function Tab(tabcontrol : TabControl, panel : Panel) {
		this._background = new Sprite();
		this._foreground = new Sprite();
		this._lines = new Shape();
		this.tabControl = tabcontrol;
		this.panel = panel;
		this.addChild(this._background);
		this.addChild(this._foreground);
		this.addChild(this._lines);
		this.tabEnabled = false;
		this.tabChildren = false;
		this._foreground.mouseEnabled = false;
		this._foreground.tabEnabled = false;
		this.draw();
	}
	
	override public function get width() : Number {
		return font.textWidth(this.panel.text) + 16;
	}

	override public function set width(value : Number) : void {
		this._width = value;
	}

	public function get selected() : Boolean {
		return this._selected;
	}

	public function set selected(e : Boolean) : void {
		this._selected = e;
		this.draw();
	}

	public function draw() : void {
		this._background.visible = !this._selected;
		this._background.width = this.width;
		this._foreground.graphics.clear();
		if (this._selected) {
			this._foreground.graphics.beginFill(Style.backgroundColor);
			this._foreground.graphics.drawRect(0, 0, this.width, height);
		}
		this.scrollRect = new Rectangle(0, 0, this.width + 1, TabControl.HEADER_HEIGHT);
		this._lines.graphics.clear();
		this._lines.graphics.lineStyle(1, Style.borderColor, 1, true);
		this._lines.graphics.moveTo(0, 18);
		this._lines.graphics.lineTo(0, 0);
		this._lines.graphics.lineTo((this.width - 0), 0);
		this._lines.graphics.lineTo((this.width - 0), 18);
		font.draw(this._foreground.graphics, 8, 0, this._width - 16, height, this.panel.text, Align.LEFT);
	}

}
