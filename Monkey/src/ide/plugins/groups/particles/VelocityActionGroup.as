package ide.plugins.groups.particles {
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.ActionBase;
	import L3D.core.shader.filters.particle.action.velocity.VelocityLocalAction;
	import L3D.utils.deg2rad;
	
	import ide.App;
	import ui.core.controls.CheckBox;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class VelocityActionGroup extends ParticlesProperties {
		
		private var temp : Vector3D = new Vector3D();
		private var _minX : Spinner;
		private var _minY : Spinner;
		private var _minZ : Spinner;
		private var _maxX : Spinner;
		private var _maxY : Spinner;
		private var _maxZ : Spinner;
		private var _ranX : Spinner;
		private var _cube : CheckBox;
		private var _cone : CheckBox;
		
		private var _velocityAction : VelocityLocalAction;
		
		public function VelocityActionGroup() {
			super("VelocityAction");
			
			enableCheck = true;
			
			accordion.contentHeight = 100;
			layout.margins = 2;
			layout.space = 0;
			
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("Min:");
			_minX = layout.addControl(new Spinner()) as Spinner;
			_minY = layout.addControl(new Spinner()) as Spinner;
			_minZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("Max:");
			_maxX = layout.addControl(new Spinner()) as Spinner;
			_maxY = layout.addControl(new Spinner()) as Spinner;
			_maxZ = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup("Random:");
			_ranX = layout.addControl(new Spinner()) as Spinner;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			_cube = layout.addControl(new CheckBox(), "CubeShape:") as CheckBox;
			layout.endGroup();
			layout.addControl(new Separator(Separator.HORIZONTAL));
			layout.addHorizontalGroup();
			_cone = layout.addControl(new CheckBox(), "ConeShape:") as CheckBox;
			layout.endGroup();
						
			_minX.addEventListener(ControlEvent.STOP, changeVelocity);
			_minY.addEventListener(ControlEvent.STOP, changeVelocity);
			_minZ.addEventListener(ControlEvent.STOP, changeVelocity);
			_maxX.addEventListener(ControlEvent.STOP, changeVelocity);
			_maxY.addEventListener(ControlEvent.STOP, changeVelocity);
			_maxZ.addEventListener(ControlEvent.STOP, changeVelocity);
			_ranX.addEventListener(ControlEvent.STOP, changeVelocity);
			
			_cube.addEventListener(ControlEvent.CHANGE, change2CubeShape);
			_cone.addEventListener(ControlEvent.CHANGE, change2ConeShape);
		}
		
		protected function change2ConeShape(event:Event) : void {
			if (_cone.value) {
				_velocityAction.initFunc = initConeParam;
			} else {
				_velocityAction.initFunc = null;
			}
			_particles.build();
		}
		
		private function change2CubeShape(event:Event) : void {
			if (_cube.value) {
				_velocityAction.initFunc = initCubeParam;
			} else {
				_velocityAction.initFunc = null;
			}
			_particles.build();
		}
		
		override protected function changeCheck(event:Event):void {
			var action : ActionBase = ActionUtils.checkAction(_particles, VelocityLocalAction);
			if (_check.value) {
				if (action == null) {
					_particles.addAction(new VelocityLocalAction());
				}
			} else {
				if (action != null) {
					_particles.removeAction(action);
				}
			}
		}
		
		protected function changeVelocity(event:Event) : void {
			_velocityAction.minVelocity = new Vector3D(_minX.value, _minY.value, _minZ.value);
			_velocityAction.maxVelocity = new Vector3D(_maxX.value, _maxY.value, _maxZ.value);
			_velocityAction.randVelocity = _ranX.value;
			_particles.build();
		}
		
		public function get velocityAction():VelocityLocalAction {
			return _velocityAction;
		}

		public function set velocityAction(value:VelocityLocalAction):void {
			
			if (value == null) {
				this._check.value = false;
				this.accordion.open = false;
				_minX.enabled = false;
				_minY.enabled = false;
				_minZ.enabled = false;
				_maxX.enabled = false;
				_maxY.enabled = false;
				_maxZ.enabled = false;
				_ranX.enabled = false;
			} else {
				this._check.value = true;
				_velocityAction = value;
				_minX.enabled = true;
				_minY.enabled = true;
				_minZ.enabled = true;
				_maxX.enabled = true;
				_maxY.enabled = true;
				_maxZ.enabled = true;
				_ranX.enabled = true;
				_minX.value = _velocityAction.minVelocity.x;
				_minY.value = _velocityAction.minVelocity.y;
				_minZ.value = _velocityAction.minVelocity.z;
				_maxX.value = _velocityAction.maxVelocity.x;
				_maxY.value = _velocityAction.maxVelocity.y;
				_maxZ.value = _velocityAction.maxVelocity.z;
				_ranX.value = _velocityAction.randVelocity;
			}
		}

		override public function update(particles:Particles3D, app:App):void {
			super.update(particles, app);
			velocityAction = ActionUtils.checkAction(particles, VelocityLocalAction) as VelocityLocalAction;
		}
		
		/**
		 * 盒子形状 
		 * @param idx
		 * @param nums
		 * @param hemisphere
		 * 
		 */		
		private function initCubeParam(vel : VelocityLocalAction, idx : int, nums : int, hemisphere : Boolean) : void {
			temp.x = 0;
			temp.y = 1 * Math.random() - 0.5;
			temp.z = 0;
			temp.normalize();
			if (hemisphere) {
				if (temp.y < 0) {
					temp.y *= -1;
				}
			}
			var ratio : Number = idx / nums;
			temp.x = temp.x * (vel.minVelocity.x * (1 - ratio) + vel.maxVelocity.x * ratio);
			temp.y = temp.y * (vel.minVelocity.y * (1 - ratio) + vel.maxVelocity.y * ratio);
			temp.z = temp.z * (vel.minVelocity.z * (1 - ratio) + vel.maxVelocity.z * ratio);
			vel.params[0] = temp.x;
			vel.params[1] = temp.y;
			vel.params[2] = temp.z;
			temp.x = Math.random() - 0.5;
			temp.y = Math.random() - 0.5;
			temp.z = Math.random() - 0.5;
			temp.normalize();
			temp.scaleBy(_velocityAction.randVelocity * 0.5);
			vel.params[0] += temp.x;
			vel.params[1] += temp.y;
			vel.params[2] += temp.z;
		}
		
		/**
		 * 初始化Cone形状的粒子 
		 * @param vel
		 * @param idx
		 * @param nums
		 * @param hemisphere
		 * 
		 */		
		private function initConeParam(vel : VelocityLocalAction, idx : int, nums : int, hemisphere : Boolean) : void {
			var ang  : Number = 100;
			var dist : Number = Math.sin(deg2rad(ang)) * Math.random();
			var rand : Number = Math.random() * Math.PI * 2;
			temp.x = Math.sin(rand) * dist * (vel.randVelocity > 0 ? Math.random() : 1);
			temp.z = Math.cos(rand) * dist * (vel.randVelocity > 0 ? Math.random() : 1);
			temp.y = dist;
			temp.normalize();
			var ratio : Number = idx / nums;
			temp.x = temp.x * (vel.minVelocity.x * (1 - ratio) + vel.maxVelocity.x * ratio);
			temp.y = temp.y * (vel.minVelocity.y * (1 - ratio) + vel.maxVelocity.y * ratio);
			temp.z = temp.z * (vel.minVelocity.z * (1 - ratio) + vel.maxVelocity.z * ratio);
			vel.params[0] = temp.x;
			vel.params[1] = temp.y;
			vel.params[2] = temp.z;
			temp.x = Math.random() - 0.5;
			temp.y = Math.random() - 0.5;
			temp.z = Math.random() - 0.5;
			temp.normalize();
			temp.scaleBy(vel.randVelocity * 0.5);
			vel.params[0] += temp.x;
			vel.params[1] += temp.y;
			vel.params[2] += temp.z;
		}
		
	}
}
