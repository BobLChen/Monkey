package ide.panel {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import L3D.core.base.Pivot3D;
	import L3D.core.camera.Camera3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.light.Light3D;
	import L3D.core.scene.Scene3D;
	
	import ui.core.Style;
	import ui.core.controls.Control;
	import ui.core.controls.Label;
	import ui.core.event.ControlEvent;

	public class PivotTreeItem extends Control {

		public static const CLOSE 				: String = "close";
		public static const LABEL_CLICK 		: String = "label_click";
		public static const LABEL_OVER 			: String = "label_over";
		public static const LABEL_DOUBLECLICK 	: String = "label_doubleclick";
		public static const LABEL_RIGHTCLICK 	: String = "label_rightclick";
		
		[Embed(source = "arrow.png")]
		private static const Arrow : Class;

		public var label 	: Label;
		public var icon 	: MovieClip;
		public var arrow 	: Sprite;
		public var pivot 	: Pivot3D;
		public var closed 	: Boolean = false;
		public var padding 	: Number;
		
		public function PivotTreeItem(pivot : Pivot3D, level : Number) {
			super(pivot.name, 0, 0, 30, 20);

			this.icon  = new McIcons();
			this.arrow = new Sprite();
			this.arrow.addChild(new Arrow());
			
			this.pivot = pivot;
			this.label = new Label(pivot.name);
			this.label.flexible = 0;
			this.label.view.doubleClickEnabled = true;
			this.level = level;
			this.flexible = 1;
			this.minHeight = 18;
			this.maxHeight = 18;
			this.arrow.transform.colorTransform = Style.colorTransform;
			
			if (pivot is Particles3D) {
				this.icon.gotoAndStop(7);
			} else if (pivot is Mesh3D) {
				this.icon.gotoAndStop(1);
			} else if (pivot is Light3D) {
				this.icon.gotoAndStop(11);
			} else if (pivot is Camera3D) {
				this.icon.gotoAndStop(4);
			} else if (pivot is Scene3D) {
				this.icon.gotoAndStop(6);
			} else {
				this.icon.gotoAndStop(2);
			}
			
			this.view.addChild(this.arrow);
			this.view.addChild(this.icon);
			this.view.addChild(this.label.view);
			this.view.cacheAsBitmap = true;
			
			this.view.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.view.addEventListener(MouseEvent.RIGHT_CLICK, labelRightClickEvent);
			this.label.view.addEventListener(MouseEvent.MOUSE_OVER, labelOverEvent);
			this.label.view.addEventListener(MouseEvent.DOUBLE_CLICK, labelDoubleClickEvent);
			this.arrow.addEventListener(MouseEvent.MOUSE_DOWN, arrowClickEvent);
		}

		private function mouseDown(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(ControlEvent.CLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function labelOverEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(LABEL_OVER, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function labelDoubleClickEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(LABEL_DOUBLECLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function labelRightClickEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(LABEL_RIGHTCLICK, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		private function arrowClickEvent(e : MouseEvent) : void {
			this.dispatchEvent(new ControlEvent(CLOSE, this, e.ctrlKey, e.altKey, e.shiftKey, e.ctrlKey));
		}

		public function set level(level : Number) : void {
			this.label.x = level + 35;
			this.label.text = this.pivot.name;
			this.arrow.y = 9;
			this.arrow.rotation = 90;
			this.arrow.x = level + 5;
			this.icon.x = level + 25;
			this.icon.y = 9;
			this.padding = level + 14;
		}
		
		public function reset() : void {
			this.label.x = 25;
			this.icon.x = 25;
			this.arrow.x = 5;
			this.arrow.visible = false;
			this.visible = true;
			this.width = this.label.x + this.label.width;
		}
		
		override public function draw() : void {
			super.draw();
			this.label.width = Style.defaultFont.textWidth(this.label.text) + 10;
			this.label.draw();
			this.maxWidth = this.label.x + this.label.width;
			this.minWidth = this.label.x + this.label.width;
		}

	}
}
