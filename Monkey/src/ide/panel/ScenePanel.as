package ide.panel {

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import ide.App;
	import ide.events.FrameEvent;
	
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.FPSStats;
	
	import ui.core.container.Panel;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.ImageButton;
	import ui.core.controls.Label;
	import ui.core.controls.Layout;
	import ui.core.controls.Rule;
	import ui.core.controls.Separator;
	import ui.core.controls.Spacer;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class ScenePanel extends Panel {

		[Embed(source = "image 64.png")]
		private static var PlayIcon : Class;
		[Embed(source = "image 115.png")]
		private static var StopIcon : Class;
		[Embed(source = "image 61.png")]
		private static var HeadIcon : Class;
		[Embed(source = "image 104.png")]
		private static var TailIcon : Class;

		private var _sceneArea 	: Spacer;					// 场景区域
		private var _scene 		: Scene3D;					// scene
		private var _layout 	: Layout;
		private var _rule 		: Rule;
		private var _playButton : ImageButton;
		private var _headButton : ImageButton;
		private var _lastButton : ImageButton;
		private var _footsSpeed : Spinner;
		private var _fpsSpeed 	: Spinner;
		private var _sceneWidth : Spinner;
		private var _sceneHeight: Spinner;
		private var _antialias 	: Spinner;
		private var _clearColor : ColorPicker;
		private var _play 		: Boolean;
		private var _stats 		: FPSStats;
				
		public function ScenePanel(scene : Scene3D) {
			super("SCENE", 200, 200, true);
			
			this._sceneArea = new Spacer();
			this._scene 	= scene;
			
			this._layout = new Layout(false);
			this._layout.shrinkEnabled = true;
			this._layout.margins = 0;
			this._layout.space = 0;
			this._layout.minWidth = -1;
			this._layout.maxWidth = -1;
			this._layout.addHorizontalGroup(null, 1, 25).background = true;
			this._layout.space = 5;
			this._layout.margins = 6;
			this._layout.labelWidth = 0;
			this._layout.addSpace();
			 
			// 背景色
			this._clearColor = new ColorPicker();
			this._clearColor.maxHeight = 14;
			this._clearColor.addEventListener(ControlEvent.CHANGE, changeClearColor);
			this._layout.addControl(new Separator(Separator.VERTICAL));
			this._layout.addControl(new Label("Clear Color:", 70)).toolTip = "背景色";
			this._layout.addControl(this._clearColor);
			// 抗锯齿
			this._antialias = new Spinner(2, 0, 8, 1, 1);
			this._antialias.maxWidth = 15;
			this._antialias.addEventListener(ControlEvent.STOP, changeAntialiasEvent);
			this._layout.addControl(new Separator(Separator.VERTICAL));
			this._layout.addControl(new Label("Antialias:", 55)).toolTip = "抗锯齿等级";
			this._layout.addControl(this._antialias);
			// 场景宽度
			this._sceneWidth = new Spinner(800, 50, 2048);
			this._sceneWidth.maxWidth = 40;
			this._sceneWidth.addEventListener(ControlEvent.STOP, changeViewPort);
			this._layout.addControl(new Separator(Separator.VERTICAL));
			this._layout.addControl(new Label("Width:", 40)).toolTip = "3D场景宽度";
			this._layout.addControl(this._sceneWidth);
			// 场景高度			
			this._sceneHeight = new Spinner(600, 50, 2048);
			this._sceneHeight.maxWidth = 40;
			this._sceneHeight.addEventListener(ControlEvent.STOP, changeViewPort);
			this._layout.addControl(new Label("Height:", 40)).toolTip = "3D场景高度";
			this._layout.addControl(this._sceneHeight);
			this._layout.addControl(new Separator(Separator.VERTICAL));
			// 帧频			
			this._fpsSpeed = new Spinner(60, 1, 60, 1, 1);
			this._fpsSpeed.maxWidth = 30;
			this._fpsSpeed.addEventListener(ControlEvent.STOP, changeFpsEvent);
			this._layout.addControl(new Label("FPS:", 30)).toolTip = "帧频";
			this._layout.addControl(_fpsSpeed);
			this._layout.addControl(new Separator(Separator.VERTICAL));
			// 相机移动速度
			this._footsSpeed = new Spinner(5, 0.1, 20);
			this._footsSpeed.flexible = 0;
			this._footsSpeed.width = 20;
			this._footsSpeed.toolTip = "Camera Speed";
			this._layout.addControl(new Label("Camera Foot Speed:", 100)).toolTip = "相机移动速度";
			this._layout.addControl(this._footsSpeed);
			this._layout.endGroup();
			// scene
			this._layout.addControl(this._sceneArea);
			this._layout.addHorizontalGroup(null, 1, 26).background = true;
			this._layout.space = 8;
			this._layout.margins = 0;
			this._layout.labelWidth = 0;
			// 刻度尺
			this._rule = new Rule();
			this._rule.name = "rule";
			this._layout.addControl(this._rule);
			this._layout.addHorizontalGroup();
			this._layout.margins = 4;
			this._layout.addControl(new Separator(Separator.VERTICAL));
			// 	播放按钮
			this._headButton = new ImageButton(new HeadIcon());
			this._layout.addControl(this._headButton);
			this._headButton.addEventListener(MouseEvent.CLICK, ruleHead);
			this._playButton = new ImageButton(new StopIcon());
			this._playButton.name = "play";
			this._layout.addControl(this._playButton);
			this._lastButton = new ImageButton(new TailIcon());
			this._layout.addControl(this._lastButton);
			this._layout.endGroup();
			this._layout.endGroup();
			this._layout.addEventListener(ControlEvent.CHANGE, this.dispatchEvent);
			// fps
			this._stats = new FPSStats(0.5);
			this._stats.x = this._sceneArea.width - this._stats.width;
			this._sceneArea.view.addChild(this._stats);
			
			this.addControl(this._layout);
			
			if (!this._scene.context) {
				this._scene.addEventListener(Event.CONTEXT3D_CREATE, onSceneInitDone);				
			} else {
				this.onSceneInitDone(null);
			}
			
			this._playButton.addEventListener(ControlEvent.CLICK, playOrStop);
			this._headButton.addEventListener(ControlEvent.CLICK, gotoHead);
			this._rule.addEventListener(ControlEvent.CHANGE, changeFrame);
			
			this.margins  = 0;
			this.space 	  = 0;
			this.minWidth = -1;
			this.maxWidth = -1;
			this.stopMovie();
		}
		
		private function changeFrame(event:Event) : void {
			this._play = false;
			this.stopMovie();
			this.dispatchEvent(new FrameEvent(FrameEvent.CHANGE));
		}
		
		public function playMovie() : void {
			this._play = true;
			this._playButton.source = new StopIcon();
		}
		
		public function stopMovie() : void {
			this._play = false;
			this._playButton.source = new PlayIcon();
		}
		
		protected function gotoHead(event:Event) : void {
			this._rule.currentFrame = 0;			
			this.dispatchEvent(new FrameEvent(FrameEvent.CHANGE));
		}
		
		private function playOrStop(event:Event) : void {
			if (this._play) {
				stopMovie();
			} else {
				playMovie();
			}
		}
				
		private function onSceneInitDone(event:Event) : void {
			var point : Point = new Point(_sceneArea.x, _sceneArea.y);
			point = view.localToGlobal(point);
			this._scene.setViewPort(point.x, point.y, _sceneArea.width, _sceneArea.height);
			this._sceneWidth.value  = this._sceneArea.width;
			this._sceneHeight.value = this._sceneArea.height;
			this._clearColor.color  = this._scene.background;	
		}
				
		private function changeClearColor(event:Event) : void {
			this._scene.background = this._clearColor.color;			
		}
		
		private function changeAntialiasEvent(event:Event) : void {
			this._scene.antialias = this._antialias.value;			
		}
		
		private function changeViewPort(event:Event) : void {
			var point : Point = new Point(_sceneArea.x, _sceneArea.y);
			point = view.localToGlobal(point);
			this._scene.setViewPort(point.x, point.y, this._sceneWidth.value, this._sceneHeight.value);			
		}
		
		private function changeFpsEvent(event:Event) : void {
			App.core.stage.frameRate = this._fpsSpeed.value;			
		}
				
		public function get footsSpeed():Spinner {
			return _footsSpeed;
		}

		public function get rule():Rule {
			return _rule;
		}

		public function get play() : Boolean {
			return _play;
		}
		
		public function set play(value : Boolean) : void {
			_play = value;
		}
		
		private function ruleHead(event : Event) : void {
			this._rule.position = 0;
			this._rule.currentFrame = 0;
		}
		
		override public function set width(value : Number):void {
			super.width = value;
			this.update();
			this.draw();
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			this.update();
			this.draw();
		}
		
		private function resizeSceneView() : void {
			if (this._sceneArea == null) {
				return;
			}
			var point : Point = new Point(_sceneArea.x, _sceneArea.y);
			point = view.localToGlobal(point);
			this._scene.setViewPort(point.x, point.y, _sceneArea.width, _sceneArea.height);
			this._sceneWidth.value  = _sceneArea.width;
			this._sceneHeight.value = _sceneArea.height;		
			this._stats.x = this._sceneArea.width - this._stats.width;
		}
		
		override public function draw():void {
			super.draw();
			this.resizeSceneView();
		}
		
	}
}
