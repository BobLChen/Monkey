package ide.plugins.groups.properties {
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import L3D.core.animator.Label3D;
	import L3D.core.entities.Mesh3D;
	import L3D.core.render.SkeletonRender;
	
	import ide.App;
	import ui.core.controls.ImageButton;
	import ui.core.controls.InputText;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class AnimationGroup extends PropertiesGroup {
		
		
		[Embed(source = "image 64.png")]
		private static var PlayIcon : Class;
		[Embed(source = "image 115.png")]
		private static var StopIcon : Class;
		[Embed(source = "image 94.png")]
		private static var DeleteIcon : Class;
		
		private var _app : App;
		private var _mesh : Mesh3D;
		private var _dict : Dictionary = new Dictionary();
		private var _count : int = 0;
		private var _fps : Spinner;
		
		public function AnimationGroup() {
			super("Animation");
			this.layout.margins = 0;
			this.layout.space = 0;
		}
		
		/**
		 * 增加一个动作 
		 * @param label
		 * 
		 */		
		private function addAnimation(label : Label3D) : void {
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup();
			layout.labelWidth = 40;
			var name : InputText = layout.addControl(new InputText(label.name)) as InputText;
			layout.addControl(new Spinner(label.from, 0, 0, 2, 1), "Start:");
			layout.addControl(new Spinner(label.to, 0, 0, 2, 1), "End:");
			var playBtn : ImageButton = layout.addControl(new ImageButton(new PlayIcon())) as ImageButton;
			var delBtn : ImageButton = layout.addControl(new ImageButton(new DeleteIcon())) as ImageButton;
			layout.endGroup();
			
			this._dict[playBtn] = label;
			this._dict[name] = label;
			this._dict[delBtn] = label;
			this._count++;
			
			delBtn.addEventListener(ControlEvent.CLICK, remove);
			playBtn.addEventListener(ControlEvent.CLICK, play);
			name.addEventListener(ControlEvent.CHANGE, changeLabel);
		}
		
		protected function remove(event:Event) : void {
			var delbtn : ImageButton = event.target as ImageButton;
			var label : Label3D = this._dict[delbtn];
			_mesh.removeLabel(label);
			_app.selection.objects = [_mesh];
			_mesh.stop();
		}
		
		protected function changeLabel(event:Event) : void {
			var input : InputText = event.target as InputText;
			var label : Label3D = this._dict[input];
			_mesh.removeLabel(label);
			label.name = input.text;
			_mesh.addLabel(label);
		}
		
		protected function play(event:Event) : void {
			var btn : ImageButton = event.target as ImageButton;
			var label : Label3D = this._dict[btn];
			_mesh.gotoAndPlay(label);
		}
		
		override public function update(app:App):Boolean {
			
			if (app.selection.main is Mesh3D) {
				var mesh : Mesh3D = app.selection.main as Mesh3D;
				_app = app;
				_mesh = mesh;
				layout.removeAllControls();
				this._dict = new Dictionary();
				this._count = 1;
				this._fps = layout.addControl(new Spinner(), "FPS:") as Spinner;
				this._fps.addEventListener(ControlEvent.CHANGE, chaneFPS);
				this._fps.value = _mesh.fps;
				for each (var label : Label3D in mesh.labels) {
					addAnimation(label);
				}
				accordion.contentHeight = this._count * 20;
				return true; // false
			}
			return false; // false
		}
		
		protected function chaneFPS(event:Event) : void {
			if (_fps.value <= 0) {
				_fps.value = 1;
			}
			_mesh.fps = _fps.value;
		}
		
	}
}
