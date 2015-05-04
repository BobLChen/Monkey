package ide.plugins.groups.properties {

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import ide.App;
	import ide.events.TransformEvent;
	
	import monkey.core.scene.Scene3D;
	
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	
	/**
	 * transform 
	 * @author Neil
	 * 
	 */	
	public class TransformGroup extends PropertiesGroup {
		
		private var posX : Spinner;
		private var posY : Spinner;
		private var posZ : Spinner;
		private var rotX : Spinner;
		private var rotY : Spinner;
		private var rotZ : Spinner;
		private var scaX : Spinner;
		private var scaY : Spinner;
		private var scaZ : Spinner;
		private var _app : App;
		
		public function TransformGroup() {
			super("TRANSFORM");
			layout.labelWidth = 55;
			layout.addHorizontalGroup("Position:");
			layout.labelWidth = 15;
			this.posX = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "X:") as Spinner;
			this.posY = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Y:") as Spinner;
			this.posZ = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Z:") as Spinner;
			layout.endGroup();
			
			layout.addControl(new Separator());
			layout.labelWidth = 55;
			layout.addHorizontalGroup("Rotation:");
			layout.labelWidth = 15;
			this.rotX = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "X:") as Spinner;
			this.rotY = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Y:") as Spinner;
			this.rotZ = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Z:") as Spinner;
			layout.endGroup();
			
			layout.addControl(new Separator());
			layout.labelWidth = 55;
			layout.addHorizontalGroup("Scale:");
			layout.labelWidth = 15;
			this.scaX = layout.addControl(new Spinner(0, 0, 0, 2, 0.01), "X:") as Spinner;
			this.scaY = layout.addControl(new Spinner(0, 0, 0, 2, 0.01), "Y:") as Spinner;
			this.scaZ = layout.addControl(new Spinner(0, 0, 0, 2, 0.01), "Z:") as Spinner;
			layout.endGroup();
			layout.addEventListener(ControlEvent.CHANGE, this.changingControlEvent);
		}
		
		private function changingControlEvent(e : ControlEvent) : void {
			switch (e.target) {
				case this.posX:
				case this.posY:
				case this.posZ:
				case this.rotX:
				case this.rotY:
				case this.rotZ:
				case this.scaX:
				case this.scaY:
				case this.scaZ:
					var mt : Matrix3D = new Matrix3D();
					var vecs : Vector.<Vector3D> = new Vector.<Vector3D>();
					vecs[0] = new Vector3D(this.posX.value, this.posY.value, this.posZ.value);
					vecs[1] = new Vector3D(this.rotX.value, this.rotY.value, this.rotZ.value);
					vecs[2] = new Vector3D(this.scaX.value, this.scaY.value, this.scaZ.value);
					vecs[1].scaleBy((Math.PI / 180));
					mt.recompose(vecs);
					this._app.selection.transform = mt;
					break;
			}
		}
		
		private function changeTransformEvent(e : TransformEvent = null) : void {
			var mt : Matrix3D = this._app.selection.transform;
			var vecs : Vector.<Vector3D> = mt.decompose();
			this.posX.value = vecs[0].x;
			this.posY.value = vecs[0].y;
			this.posZ.value = vecs[0].z;
			this.rotX.value = (vecs[1].x / Math.PI) * 180;
			this.rotY.value = (vecs[1].y / Math.PI) * 180;
			this.rotZ.value = (vecs[1].z / Math.PI) * 180;
			this.scaX.value = vecs[2].x;
			this.scaY.value = vecs[2].y;
			this.scaZ.value = vecs[2].z;
		}
		
		override public function update(app : App) : Boolean {
			this._app = app;
			this._app.addEventListener(TransformEvent.CHANGE, changeTransformEvent);
			if (!this._app.selection.main || this._app.selection.main is Scene3D) {
				return false;
			}
			this.changeTransformEvent();
			return true;
		}
	}
}
