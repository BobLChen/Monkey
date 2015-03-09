package ui.core.controls {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import ui.core.Style;
	import ui.core.event.ControlEvent;

	public class CurvesEditor extends Control {
		
		public var lockX : Boolean;
		public var lockY : Boolean;
		
		private var _points	: Vector.<Point>;
		private var size 	: Rectangle;
		private var padding : int = 40;
		private var rows 	: int = 5;
		private var cols 	: int = 10;
		private var flags	: Vector.<CurveFlag>;
		
		private var yTexts	: Vector.<Spinner>;		// y轴文本框
		private var xTexts	: Vector.<Spinner>;		// x轴文本框
		private var xStep   : Number = 1;			// x轴格子宽度
		private var yStep   : Number = 1;			// y轴格子宽度
		private var valueY  : Number = 1;			
		private var valueX  : Number = 1;
		
		private var boardPanel	: Sprite;			// 底板
		private var linesPanel  : Sprite;			// 曲线
		private var lablesPanel : Sprite;			// 文本框
		private var flagPanel	: Sprite;			// 提示
		private var panel   	: Sprite;			// panel
		private var dragFlag	: CurveFlag = null;
		private var tips 		: ToolTip1;			// 
		
		public function CurvesEditor(width : int = 300, height : int = 200) {
			this.size = new Rectangle(padding, padding, width, height);
			this.initCurves();
			this.axisYValue = 1.0;
			this.axisXValue = 1.0;
			this.insertPoint(new Point(0.0, 0.0));
			this.insertPoint(new Point(1.0, 1.0));
		}
		
		public function get points():Vector.<Point> {
			return _points;
		}

		public function set points(value:Vector.<Point>):void {
			this.clear();
			for (var i:int = 0; i < value.length; i++) {
				this.insertPoint(value[i].clone());
			}
		}
		
		/**
		 * 设置Y轴值 
		 * @param value
		 * 
		 */		
		public function set axisYValue(value : Number) : void {
			for each (var point : Point in points) {
				point.y = point.y / valueY * value;
			}
			valueY = value;
			for (var i:int = 0; i < yTexts.length; i++) {
				yTexts[i].value= Number((valueY / rows * (rows - i)).toFixed(2));
			}
			this.drawCurves();
		}
		
		/**
		 * Y轴值 
		 * @return 
		 * 
		 */		
		public function get axisYValue() : Number {
			return valueY;
		}
		
		/**
		 * 设置X轴值 
		 * @param value
		 * 
		 */		
		public function set axisXValue(value : Number) : void {
			for each (var point : Point in points) {
				point.x = point.x / valueX * value;
			}
			valueX = value;
			for (var i:int = 0; i < xTexts.length; i++) {
				xTexts[i].value = Number((valueX / cols * i).toFixed(1));
			}
			this.drawCurves();
		}
		
		/**
		 * X轴值 
		 * @return 
		 * 
		 */		
		public function get axisXValue() : Number {
			return valueX;
		}
		
		/**
		 * 初始化曲线面板 
		 * 
		 */		
		private function initCurves() : void {
			// ui
			this.boardPanel = new Sprite();
			this.boardPanel.addEventListener(MouseEvent.CLICK, onAddKey);
			this.boardPanel.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.linesPanel = new Sprite();
			this.flagPanel = new Sprite();
			this.lablesPanel= new Sprite();
			this.lablesPanel.mouseChildren = true;
			this.lablesPanel.mouseEnabled  = true;
			this.panel = new Sprite();
			this.panel.addChild(linesPanel);
			this.panel.addChild(flagPanel);
			this.panel.x = padding;
			this.panel.y = padding;
			this.tips = new ToolTip1();
			this.tips.visible = false;
			this.view.addChild(boardPanel);
			this.view.addChild(panel);
			this.view.addChild(lablesPanel);
			this.view.addChild(tips);
			// 数据
			this._points= new Vector.<Point>();
			this.flags = new Vector.<CurveFlag>();
			this.xStep = size.width / cols;
			this.yStep = size.height / rows;
			// 绘制背景色
			this.boardPanel.graphics.beginFill(Style.backgroundColor, 1.0);
			this.boardPanel.graphics.drawRect(0, 0, size.width + padding * 2, size.height + padding * 2);
			this.boardPanel.graphics.endFill();
			// 绘制格子
			this.boardPanel.graphics.lineStyle(2, 0x252525);
			for (var i:int = 1; i <= rows; i++) {
				this.boardPanel.graphics.moveTo(size.left,  yStep * i + size.y);
				this.boardPanel.graphics.lineTo(size.right, yStep * i + size.y);
			}
			for (var j:int = 0; j < cols; j++) {
				this.boardPanel.graphics.moveTo(xStep * j + size.x, size.top);
				this.boardPanel.graphics.lineTo(xStep * j + size.x, size.bottom);
			}
			this.boardPanel.graphics.lineStyle(2, 0x222222);
			this.boardPanel.graphics.drawRect(size.x, size.y, size.width, size.height);
			// 摆放文本框
			this.yTexts = new Vector.<Spinner>();
			this.xTexts = new Vector.<Spinner>();
			// Y轴文本框
			for (i = 0; i < rows; i++) {
				var ytex : Spinner = new Spinner(0, 0, 0, 1, 0);
				ytex.x = 0;
				ytex.y = yStep * i + size.y - ytex.height / 2;
				ytex.enabled = false;
				this.lablesPanel.addChild(ytex.view);
				this.yTexts.push(ytex);
			}
			// x轴文本框
			for (i = 0; i <= cols; i++) {
				var xtex : Spinner = new Spinner(0, 0, 0, 1, 0);
				xtex.enabled = false;
				xtex.y = size.bottom;;
				xtex.x = size.x + xStep * i - xtex.width / 2;
				this.lablesPanel.addChild(xtex.view);
				this.xTexts.push(xtex);
			}
			this.yTexts[0].enabled = true;
			this.yTexts[0].addEventListener(ControlEvent.CHANGE, changeAxisYValue);
			this.linesPanel.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function changeAxisYValue(e : Event) : void {
			this.axisYValue = this.yTexts[0].value;
		}
		
		private var addKeyTick : int = 0;
		
		private function onAddKey(event:MouseEvent) : void {
			var current : int = getTimer();
			var delta : int = current - addKeyTick;
			addKeyTick = current;
			if (delta <= 250) {
				var ix : Number = panel.mouseX;
				var iy : Number = panel.mouseY;
				if (ix < 0 || ix > size.width || iy < 0 || iy > size.height) {
					return;
				}
				var lx : Number = panel.mouseX / size.width  * valueX;
				var ly : Number = (size.height - panel.mouseY) / size.height * valueY;
				var point : Point = new Point(lx, ly);
				this.insertPoint(point);
			}
		}
		
		/**
		 * 插入一个点 
		 * @param event
		 * 
		 */		
		private function onInsertPoint(event:MouseEvent) : void {
			var point : Point = new Point();
			var lx : Number = panel.mouseX / size.width * valueX;
			var ly : Number = (size.height - panel.mouseY) / size.height * valueY;
			point.x = lx;
			point.y = ly;
			this.insertPoint(point);
		}
		
		/**
		 * 插入一个点 
		 * @param p
		 * 
		 */		
		public function insertPoint(p : Point) : void {
			this.points.push(p);
			this.sortPoints();
			var flag : CurveFlag = new CurveFlag(p);
			flag.x = getX(p.x);
			flag.y = getY(p.y);
			flag.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			flag.addEventListener(MouseEvent.MOUSE_OUT,  onMouseOut);
			flag.addEventListener(MouseEvent.MOUSE_DOWN, onDragFLag);
			flag.addEventListener(MouseEvent.MOUSE_UP,   onMouseUp);
			flag.addEventListener(MouseEvent.CLICK, 	 onDeleteKey);
			this.flags.push(flag);
			this.flagPanel.addChild(flag);
			this.drawCurves();
		}
		
		private var deleteTick : int = 0;
		private function onDeleteKey(e : MouseEvent) : void {
			var current : int = getTimer();
			var delta : int = current - deleteTick;
			deleteTick = current;
			if (delta <= 250) {
				var flag : CurveFlag = e.target as CurveFlag;
				if (flag) {
					this.deletePoint(flag.value);
				}
			}
		}
		
		public function clear() : void {
			while (this.points.length > 0) {
				this.deletePoint(points[0]);
			}
		}
		
		public function deletePoint(p : Point) : void {
			// 删除flag
			for (var i:int = 0; i < flags.length; i++) {
				if (flags[i].value.equals(p)) {
					this.flagPanel.removeChild(flags[i]);
					flags.splice(i, 1);
					break;
				}
			}
			// 删除点
			var idx : int = points.indexOf(p);
			if (idx != -1) {
				points.splice(idx, 1);
			}
			this.drawCurves();
		}
		
		private function sortPoints() : void {
			this.points.sort(function(pa : Point, pb : Point):int{
				if (pa.x > pb.x) {
					return 1;
				} else if (pa.x == pb.x) {
					return 0;
				} else {
					return -1;
				}
			});
		}
		
		public function drawCurves() : void {
			if (this.points.length < 1) {
				return;
			}
			this.linesPanel.graphics.clear();
			this.linesPanel.graphics.lineStyle(1, 0xAA0000);
			// 绘制左侧
			this.linesPanel.graphics.moveTo(getX(0), getY(points[0].y));
			this.linesPanel.graphics.lineTo(getX(points[0].x), getY(points[0].y));
			// 绘制右侧
			this.linesPanel.graphics.moveTo(getX(valueX), getY(points[points.length-1].y)); 
			this.linesPanel.graphics.lineTo(getX(points[points.length-1].x), getY(points[points.length-1].y)); 
			// 绘制标识
			for (var j:int = 0; j < flags.length; j++) {
				this.drawFlag(this.linesPanel.graphics, flags[j]);
			}
			// 绘制曲线
			for (var i:int = 0; i < points.length; i++) {
				if (i + 1 >= points.length) {
					break;
				}
				this.drawCurveLines(points[i], points[i + 1]);
			}
		}
		
		/**
		 * 绘制两点之间的曲线 
		 * @param pa
		 * @param pb
		 * 
		 */		
		private function drawCurveLines(pa : Point, pb : Point) : void {
			var lx : Number = getX(pa.x);
			var ly : Number = getY(pa.y);
			var rx : Number = getX(pb.x);
			var ry : Number = getY(pb.y);
			var h  : Number = ly - ry;
			var tx : Number = 0;
			if (h < 0) {
				h *= -1;
				tx = Math.PI;
			} else {
				tx = 0;
			}
			var length : Number = rx - lx;
			this.linesPanel.graphics.moveTo(getX(pa.x), getY(pa.y));
			for (var i:Number = lx; i < rx; i++) {
				this.linesPanel.graphics.lineTo(i, ly - Math.sin((i - lx) / length * Math.PI / 2 + tx) * h);
			}
		}
		
		/**
		 * 获取Y轴坐标 
		 * @param value
		 * @return 
		 * 
		 */		
		private function getY(value : Number) : Number {
			value = value / valueY * size.height;
			return size.height - value;
		}
		
		/**
		 * 获取X轴坐标 
		 * @param value
		 * @return 
		 * 
		 */		
		private function getX(value : Number) : Number {
			return value / valueX * size.width;
		}
		
		/**
		 * 绘制一个标识 
		 * @param graphics
		 * 
		 */		
		private function drawFlag(graphics : Graphics, flag : CurveFlag) : void {
			flag.x = getX(flag.value.x);
			flag.y = getY(flag.value.y);
		}
		
		private function onMouseMove(event:MouseEvent) : void {
			if (!dragFlag) {
				return;
			}
			
			var ix : Number = panel.mouseX;
			var iy : Number = panel.mouseY;
			
			var up : Boolean = false;
			if (ix < 0 || ix > size.width || iy < 0 || iy > size.height) {
				up = true;
			}
			
			ix = Math.max(ix, 0);
			ix = Math.min(ix, size.width);
			iy = Math.max(iy, 0);
			iy = Math.min(iy, size.height);
			
			var lx : Number = ix / size.width  * valueX;
			var ly : Number = (size.height - iy) / size.height * valueY;
			
			if (!lockX) {
				dragFlag.x = ix;
				dragFlag.value.x = lx;
			}
			if (!lockY) {
				dragFlag.y = iy;
				dragFlag.value.y = ly;
			}
			
			if (up) {
				dragFlag = null;
			}
			this.sortPoints();
			this.drawCurves();
		}
		
		private function onMouseUp(event:MouseEvent) : void {
			dragFlag = event.target as CurveFlag;
			if (dragFlag) {
				this.sortPoints();
				this.drawCurves();
			}
			dragFlag = null;
		}
		
		private function onDragFLag(event:MouseEvent) : void {
			dragFlag = event.target as CurveFlag;
		}
		
		private function onMouseOut(event:MouseEvent) : void {
			this.tips.visible = false;
		}
		
		private function onMouseOver(event:MouseEvent) : void {
			var flag : CurveFlag = event.target as CurveFlag;
			if (!flag) {
				return;
			}
			var mouse : Point = this.view.globalToLocal(new Point(event.stageX, event.stageY));
			this.tips.visible = true;
			this.tips.x = mouse.x;
			this.tips.y = mouse.y;
			this.tips.text = "x=" + flag.value.x.toFixed(2) + " y=" + flag.value.y.toFixed(2);
		}
				
	}
}

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

class CurveFlag extends Sprite {
	
	public var value : Point = null;
	
	public function CurveFlag(value : Point, color : uint = 0xFF0000, thick : int = 5) : void {
		this.value = value;
		this.graphics.beginFill(color, 1);
		this.graphics.moveTo(0 - thick, 0);
		this.graphics.lineTo(0, 0 + thick);
		this.graphics.lineTo(0 + thick, 0);
		this.graphics.lineTo(0, 0 - thick);
		this.graphics.lineTo(0 - thick, 0);
		this.graphics.endFill();
	}
	
}

class ToolTip1 extends Sprite {
	private var _text  : String;
	private var _arrow : Boolean;
	private var label  : TextField;
	
	public function ToolTip1() {
		super();
		
		this._arrow = false;
		this.init();
		this.redraw();
	}
	
	public function get arrow():Boolean {
		return _arrow;
	}
	
	public function set arrow(value:Boolean):void {
		this._arrow = value;
		this.redraw();
	}
	
	public function get text():String {
		return _text;
	}
	
	public function set text(value:String):void {
		this._text = value;
		this.label.text = value;
		this.redraw();
	}
	
	private function init() : void {
		this.label = new TextField();
		this.label.autoSize = TextFieldAutoSize.LEFT;
		this.label.selectable = false;
		this.label.multiline = false;
		this.label.wordWrap = false;
		this.label.defaultTextFormat = new TextFormat("宋体", 12, 0x666666);
		this.label.text = "提示提示";
		this.label.x = 5;
		this.label.y = 2;
		this.addChild(label);
	}
	
	public function redraw() : void {
		
		var w : Number = 10 + label.width;
		var h : Number = 4 + label.height;
		
		this.graphics.clear();
		this.graphics.beginFill(0x000000, 0.4);
		this.graphics.drawRoundRect(3, 3, w, h, 5, 5);
		
		if (arrow) {
			this.graphics.moveTo(6, 3 + h);
			this.graphics.lineTo(12, 3 + h);
			this.graphics.lineTo(9, 8 + h);
			this.graphics.lineTo(6, 3 + h);
		}
		this.graphics.endFill();
		this.graphics.beginFill(0xffffff);
		this.graphics.drawRoundRect(0, 0, w, h, 5, 5);
		
		if (arrow) {
			this.graphics.moveTo(3, h);
			this.graphics.lineTo(9, h);
			this.graphics.lineTo(6, 5 + h);
			this.graphics.lineTo(3, h);
		}
		this.graphics.endFill();
	}
}
