package ide.plugins.groups.properties {
	
	import flash.events.Event;
	
	import ide.App;
	
	import monkey.core.animator.Label3D;
	import monkey.core.base.Object3D;
	
	import ui.core.container.Box;
	import ui.core.controls.ImageButton;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	/**
	 * 动画控制器 
	 * @author Neil
	 * 
	 */	
	public class AnimatorGroup extends PropertiesGroup {
		
		[Embed(source="image 64.png")]
		private static const IMG : Class;
		
		private var fps 	: Spinner;
		private var header  : Box;
		private var app 	: App;
		private var obj 	: Object3D;
		
		public function AnimatorGroup() {
			super("Animator");
			
			this.header = this.layout.addHorizontalGroup();
			this.fps = this.layout.addControl(new Spinner(60), "FPS:") as Spinner;
			this.layout.endGroup();
			
			this.fps.addEventListener(ControlEvent.CHANGE, changeFPS);
		}
		
		private function changeFPS(event:Event) : void {
			this.obj.animator.fps = this.fps.value;	
		}
		
		/**
		 * 创建动画标签 
		 * 
		 */		
		private function createAnimLabel() : void {
			this.layout.removeAllControls();
			this.layout.addControl(this.header);
			this.layout.maxHeight = 20;
			this.layout.minHeight = 20;
			for each (var label : Label3D in this.obj.animator.labels) {
				this.layout.addHorizontalGroup();
				this.layout.addControl(new Label(label.name));
				this.layout.addControl(new Spinner(label.from)).enabled = false;
				this.layout.addControl(new Spinner(label.to)).enabled = false;
				var btn : ImageButton = this.layout.addControl(new ImageButton(new IMG())) as ImageButton;
				this.layout.endGroup();
				this.layout.minHeight += 22;
				this.layout.maxHeight += 22;
				this.addPlayListerner(btn, label);
			}
		}
		
		private function addPlayListerner(btn:ImageButton, label:Label3D) : void {
			btn.addEventListener(ControlEvent.CLICK, function(e:Event):void{
				obj.animator.gotoAndPlay(label);
			});			
		}
		
		override public function update(app : App):Boolean {
			if (app.selection.main && app.selection.main.animator) {
				this.app = app;
				this.obj = app.selection.main;
				this.createAnimLabel();
				return true;
			}
			return false;
		}
				
	}
}
