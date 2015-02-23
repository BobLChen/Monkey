package ide.plugins.groups.particles {
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.Mesh3D;
	import L3D.core.entities.primitives.Particles3D;
	
	import ide.panel.PivotTree;
	
	import ide.App;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Control;
	import ui.core.controls.InputText;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.controls.Window;
	import ui.core.event.ControlEvent;

	public class ParticlesBaseGroup extends ParticlesProperties {
		
		private var _minDuration : Spinner;
		private var _maxDuration : Spinner;
		private var _randomDuration : Spinner;
		private var _minDelay : Spinner;
		private var _maxDelay : Spinner;
		private var _randomDelay : Spinner;
		private var _nums : Spinner;
		private var _minSizeX : Spinner;
		private var _minSizeY : Spinner;
		private var _minSizeZ : Spinner;
		private var _maxSizeX : Spinner;
		private var _maxSizeY : Spinner;
		private var _maxSizeZ : Spinner;
		private var _randomSizeX : Spinner;
		private var _randomSizeY : Spinner;
		private var _randomSizeZ : Spinner;
		private var _minRotX : Spinner;
		private var _minRotY : Spinner;
		private var _minRotZ : Spinner;
		private var _maxRotX : Spinner;
		private var _maxRotY : Spinner;
		private var _maxRotZ : Spinner;
		private var _randomRotX : Spinner;
		private var _randomRotY : Spinner;
		private var _randomRotZ : Spinner;
		private var _loops : Spinner;
		private var _mesh : InputText;		
		private var _hemisphere : CheckBox;
		private var _world : CheckBox;
		private var _worldRotation : CheckBox;
		private var _useDelay : CheckBox;
		private var _invert : CheckBox;
		private var _autoRot : CheckBox;
		
		private var _pivotTree : PivotTree;
		
		public function ParticlesBaseGroup() {
			super("Properties");
			layout.margins = 2;
			layout.space = 0;
			accordion.contentHeight = 300;
			_mesh = layout.addControl(new InputText("Mesh")) as InputText;
			_mesh.textField.selectable = false;
			layout.addControl(new Separator(Separator.HORIZONTAL));
			_useDelay = layout.addControl(new CheckBox(), "UseDelay:") as CheckBox;
			_hemisphere = layout.addControl(new CheckBox(), "hemisphere:") as CheckBox;
			_invert = layout.addControl(new CheckBox(), "Invert:") as CheckBox;
			_world = layout.addControl(new CheckBox(), "WorldPosition:") as CheckBox;
			_worldRotation = layout.addControl(new CheckBox(), "WorldRotation:") as CheckBox;
			_autoRot = layout.addControl(new CheckBox(), "AutoRot:") as CheckBox;
			_nums = layout.addControl(new Spinner(200, 1, 999999, 2, 1), "Number:") as Spinner;
			_loops = layout.addControl(new Spinner(0, 0, 9999, 2, 1), "Loops:") as Spinner;
			_minDuration = layout.addControl(new Spinner(), "MinDuration:") as Spinner;
			_maxDuration = layout.addControl(new Spinner(), "MaxDuration:") as Spinner;
			_randomDuration = layout.addControl(new Spinner(), "RandomDuration:") as Spinner;
			_minDelay = layout.addControl(new Spinner(), "MinDelay:") as Spinner;
			_maxDelay = layout.addControl(new Spinner(), "MaxDelay:") as Spinner;
			_randomDelay = layout.addControl(new Spinner(), "RandomDelay:") as Spinner;
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("MinSize:");
			_minSizeX = layout.addControl(new Spinner()) as Spinner;
			_minSizeY = layout.addControl(new Spinner()) as Spinner;
			_minSizeZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addHorizontalGroup("MaxSize:");
			_maxSizeX = layout.addControl(new Spinner()) as Spinner;
			_maxSizeY = layout.addControl(new Spinner()) as Spinner;
			_maxSizeZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addHorizontalGroup("RandomSize:");
			_randomSizeX = layout.addControl(new Spinner()) as Spinner;
			_randomSizeY = layout.addControl(new Spinner()) as Spinner;
			_randomSizeZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("MinRotate:");
			_minRotX = layout.addControl(new Spinner()) as Spinner;
			_minRotY = layout.addControl(new Spinner()) as Spinner;
			_minRotZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addHorizontalGroup("MaxRotate:");
			_maxRotX = layout.addControl(new Spinner()) as Spinner;
			_maxRotY = layout.addControl(new Spinner()) as Spinner;
			_maxRotZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addHorizontalGroup("RandomRotate:");
			_randomRotX	= layout.addControl(new Spinner()) as Spinner;
			_randomRotY = layout.addControl(new Spinner()) as Spinner;
			_randomRotZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			
			_minDuration.addEventListener(ControlEvent.STOP, changeDuration);
			_maxDuration.addEventListener(ControlEvent.STOP, changeDuration);
			_randomDuration.addEventListener(ControlEvent.STOP, changeDuration);
			_minDelay.addEventListener(ControlEvent.STOP, changeDelay);
			_maxDelay.addEventListener(ControlEvent.STOP, changeDelay);
			_randomDelay.addEventListener(ControlEvent.STOP, changeDelay);
			_nums.addEventListener(ControlEvent.STOP, changeNums);
			_minSizeX.addEventListener(ControlEvent.STOP, changeSize);
			_minSizeY.addEventListener(ControlEvent.STOP, changeSize);
			_minSizeZ.addEventListener(ControlEvent.STOP, changeSize);
			_maxSizeX.addEventListener(ControlEvent.STOP, changeSize);
			_maxSizeY.addEventListener(ControlEvent.STOP, changeSize);
			_maxSizeZ.addEventListener(ControlEvent.STOP, changeSize);
			_randomSizeX.addEventListener(ControlEvent.STOP, changeSize);
			_randomSizeY.addEventListener(ControlEvent.STOP, changeSize);
			_randomSizeZ.addEventListener(ControlEvent.STOP, changeSize);
			_minRotX.addEventListener(ControlEvent.STOP, changeRot);
			_minRotY.addEventListener(ControlEvent.STOP, changeRot);
			_minRotZ.addEventListener(ControlEvent.STOP, changeRot);
			_maxRotX.addEventListener(ControlEvent.STOP, changeRot);
			_maxRotY.addEventListener(ControlEvent.STOP, changeRot);
			_maxRotZ.addEventListener(ControlEvent.STOP, changeRot);
			_randomRotX.addEventListener(ControlEvent.STOP, changeRot);
			_randomRotY.addEventListener(ControlEvent.STOP, changeRot);
			_randomRotZ.addEventListener(ControlEvent.STOP, changeRot);
			_loops.addEventListener(ControlEvent.STOP, changeLoops);
			_mesh.addEventListener(ControlEvent.CLICK, changeMesh);
			_hemisphere.addEventListener(ControlEvent.CHANGE, changeHemisphere);
			_world.addEventListener(ControlEvent.CHANGE, changeWorldPosition);
			_worldRotation.addEventListener(ControlEvent.CHANGE, changeWorldRotation);
			_useDelay.addEventListener(ControlEvent.CHANGE, useDelay);
			_invert.addEventListener(ControlEvent.CHANGE, changeInvert);
			_autoRot.addEventListener(ControlEvent.CHANGE, changeAutoRot);
			
			_pivotTree = new PivotTree();
			_pivotTree.width = 250;
			_pivotTree.height = 500;
			_pivotTree.minHeight = 500;
			
			_pivotTree.addEventListener(ControlEvent.CLICK, chooseMesh);
		}
		
		protected function changeAutoRot(event:Event) : void {
			_particles.autoRot = _autoRot.value;			
		}
		
		protected function changeInvert(event:Event) : void {
			_particles.invert = _invert.value;			
		}
		
		protected function useDelay(event:Event) : void {
			_particles.useDelay = _useDelay.value;			
		}
		
		protected function changeWorldRotation(event:Event) : void {
			_particles.worldRotation = _worldRotation.value;			
		}
		
		protected function changeWorldPosition(event:Event) : void {
			_particles.worldPosition = _world.value;			
		}
		
		protected function chooseMesh(event:Event) : void {
			if (_pivotTree.selected.length >= 1 && _pivotTree.selected[0] is Mesh3D) {
				var mesh : Mesh3D = _pivotTree.selected[0] as Mesh3D;
				_particles.shape = mesh.geometries[0];
				Window.popWindow.visible = false;
			}
		}
		
		protected function changeHemisphere(event:Event) : void {
			_particles.hemisphere = _hemisphere.value;			
		}
		
		protected function changeMesh(event:Event) : void {
			Window.popWindow.window = _pivotTree;
			Window.popWindow.visible = true;
			this._pivotTree.pivot = this._app.scene;
			Window.popWindow.draw();
		}
		
		protected function changeLoops(event:Event) : void {
			_particles.loops = _loops.value;
		}
		
		protected function changeRot(event:Event) : void {
			_particles.minRotate = new Vector3D(_minRotX.value, _minRotY.value, _minRotZ.value);
			_particles.maxRotate = new Vector3D(_maxRotX.value, _maxRotY.value, _maxRotZ.value);
			_particles.randomRotate = new Vector3D(_randomRotX.value, _randomRotY.value, _randomRotZ.value);
		}
		
		protected function changeSize(event:Event) : void {
			_particles.minSize = new Vector3D(_minSizeX.value, _minSizeY.value, _minSizeZ.value);
			_particles.maxSize = new Vector3D(_maxSizeX.value, _maxSizeY.value, _maxSizeZ.value);
			_particles.randomSize = new Vector3D(_randomSizeX.value, _randomSizeY.value, _randomSizeZ.value);
		}
		
		protected function changeNums(event:Event) : void {
			_particles.nums = _nums.value;
		}
		
		protected function changeDelay(event:Event) : void {
			_particles.minDelay = _minDelay.value;
			_particles.maxDelay = _maxDelay.value;
			_particles.randomDelay = _randomDelay.value;
		}
		
		protected function changeDuration(event:Event) : void {
			_particles.minDuration = _minDuration.value;
			_particles.maxDuration = _maxDuration.value;
			_particles.randomDuration = _randomDuration.value;
		}
		
		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			
			_minDuration.value = _particles.minDuration;
			_maxDuration.value = _particles.maxDuration;
			_randomDuration.value = _particles.randomDuration;
			_minDelay.value = _particles.minDelay;
			_maxDelay.value = _particles.maxDelay;
			_randomDelay.value = _particles.randomDelay;
			_nums.value = _particles.nums;
			_minSizeX.value = _particles.minSize.x;
			_minSizeY.value = _particles.minSize.y;
			_minSizeZ.value = _particles.minSize.z;
			_maxSizeX.value = _particles.maxSize.x;
			_maxSizeY.value = _particles.maxSize.y;
			_maxSizeZ.value = _particles.maxSize.z;
			_randomSizeX.value = _particles.randomSize.x;
			_randomSizeY.value = _particles.randomSize.y;
			_randomSizeZ.value = _particles.randomSize.z;
			_minRotX.value = _particles.minRotate.x;
			_minRotY.value = _particles.minRotate.y;
			_minRotZ.value = _particles.minRotate.z;
			_maxRotX.value = _particles.maxRotate.x;
			_maxRotY.value = _particles.maxRotate.y;
			_maxRotZ.value = _particles.maxRotate.z;
			_randomRotX.value = _particles.randomRotate.x;
			_randomRotY.value = _particles.randomRotate.y;
			_randomRotZ.value = _particles.randomRotate.z;
			_loops.value = _particles.loops;
			_useDelay.value = _particles.useDelay;
			_worldRotation.value = _particles.worldRotation;
			_world.value = _particles.worldPosition;
			_hemisphere.value = _particles.hemisphere;
			_autoRot.value = _particles.autoRot;
			
		}
		
		
	}
}
