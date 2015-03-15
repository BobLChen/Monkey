package ide.help {

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import ide.App;
	import ide.events.SceneEvent;
	import ide.events.SelectionEvent;
	import ide.events.TransformEvent;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.collisions.CollisionInfo;
	import monkey.core.materials.Material3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Vector3DUtils;

	public class Selection {
		
		public static const FPS 	: String = "FirstPerson";
		public static const LOCAL 	: String = "local";
		public static const GLOBAL	: String = "global";
		
		public var sceneCamera		: Camera3D;
		public var pickInfo			: CollisionInfo;
		
		private var _material		: Material3D;				// 材质
		private var _objects 		: Array;					// 所有选中的3d对象
		private var _transformMode 	: String = GLOBAL;			// 
		private var _clipboardState : String;					// 剪贴板状态
		private var _clipboard 		: Array;					// 剪贴板
		private var _app 			: App;						// app
		private var _main 			: Object3D;					// 选中的pivot
		private var _bounds			: Vector3D;					// bounds
		
		public function Selection(app : App) {
			this._objects = [];
			this._app     = app;
			this._bounds  = new Vector3D();
			this.pickInfo = new CollisionInfo();
		}
		
		/**
		 * 包围盒 
		 * @return 
		 * 
		 */		
		public function get bounds():Vector3D {
			return _bounds;
		}
		
		/**
		 * 包围盒 
		 * @param value
		 * 
		 */		
		public function set bounds(value:Vector3D):void {
			_bounds = value;
		}

		/**
		 * 材质
		 * @return 
		 * 
		 */		
		public function get material():Material3D {
			return _material;
		}
		
		/**
		 * 材质
		 * @return 
		 * 
		 */	
		public function set material(value:Material3D):void {
			_material = value;
		}
		
		/**
		 * 选中的对象 
		 * @return 
		 * 
		 */		
		public function get main() : Object3D {
			return _main;
		}
		
		/**
		 * 选中的对象 
		 * @param value
		 * 
		 */		
		public function set main(value : Object3D) : void {
			_main = value;
			updateBoundings();				
		}
		
		private function updateBoundings() : void {
			if (!main) {
				return;
			}
			var bounds : Bounds3D = getBounds(main);
			var center : Vector3D = bounds.center;
			var scale  : Vector3D = main.transform.getScale();
			Vector3DUtils.mul(scale, bounds.length, scale);	
			this.bounds = scale;
		}
		
		public function getBounds(pivot : Object3D) : Bounds3D {
			var bounds : Bounds3D = new Bounds3D();
			if (!pivot.renderer || !pivot.renderer.mesh) {
				return bounds;
			}
			bounds.copyFrom(pivot.renderer.mesh.bounds);
			return bounds;
		}
		
		/**
		 * mode 
		 * @return 
		 * 
		 */		
		public function get transformMode() : String {
			return _transformMode;
		}
		
		/**
		 * mode 
		 * @param value
		 * 
		 */		
		public function set transformMode(value : String) : void {
			_transformMode = value;
		}
		
		/**
		 * 剪切
		 */		
		public function cut() : void {
			if (this._objects.length == 0) {
				return;
			}
			this._clipboardState = "cut";
			this._clipboard 	 = [];
			var pivot : Object3D = null;
			for each (pivot in this.objects) {
				this._clipboard.push(pivot);
				if (pivot.parent) {
					pivot.parent.removeChild(pivot);
				}
			}
			this.objects = [];
		}
				
		/**
		 * 复制
		 */		
		public function copy() : void {
			if (this._objects.length == 0) {
				return;
			}
			this._clipboardState = "copy";
			this._clipboard 	 = [];
			var pivot : Object3D = null;
			for each (pivot in this.objects) {
				this._clipboard.push(pivot.clone());
			}
		}
						
		/**
		 * 粘贴 
		 */		
		public function paste() : void {
			if (this._clipboardState == "cut") {
				var parent : Object3D = null;
				if (objects.length >= 1) {
					parent = this.objects[0];
				} else {
					parent = this._app.scene;
				}
				for each (var pivot : Object3D in this._clipboard) {
					parent.addChild(pivot);
				}
			}
			if (this._clipboard) {
				this.objects = this._clipboard;
			}
			this._clipboardState = "";
			this._clipboard = null;
		}
		
		public function get transform() : Matrix3D {
			var result : Matrix3D = new Matrix3D();
			if (this.main == null) {
				return result;
			}
			switch (this.transformMode) {
				case GLOBAL:  {
					result.copyFrom(this.main.transform.world);
					break;
				}
				case LOCAL:  {
					result.copyFrom(this.main.transform.local);
					break;
				}
			}
			return result;
		}
		
		public function set transform(value : Matrix3D) : void {
			if (this.main == null) {
				return;
			}
			switch (this.transformMode) {
				case GLOBAL:  {
					this.main.transform.world = value;
					break;
				}
				case LOCAL:  {
					this.main.transform.local.copyFrom(value);
					break;
				}
			}
			this.main.transform.updateTransforms(true);
			this._app.dispatchEvent(new TransformEvent(TransformEvent.CHANGE));
		}
		
		public function get objects() : Array {
			if (_objects == null || _objects.length == 0) {
				return [_app.scene];
			}
			return _objects;
		}
				
		public function push(value : Array) : void {
			for each (var pivot : Object3D in value) {
				if (this._objects.indexOf(pivot) == -1) {
					this._objects.push(pivot);
				}
			}
			if (value.length >= 1) {
				this.main = value[value.length - 1];
			}
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		public function remove(value : Array) : void {
			for each (var pivot : Object3D in value) {
				var idx : int = this._objects.indexOf(pivot);
				if (idx != -1) {
					this._objects.splice(idx, 1);
					if (this.main == pivot) {
						if (this._objects.length == 0) {
							this.main = null;
						} else {
							this.main = this._objects[this._objects.length - 1];
						}
					}
				}
			}
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		public function set objects(value : Array) : void {
			this._objects = [];
			for each (var pivot : Object3D in value) {
				if (this._objects.indexOf(pivot) == -1) {
					this._objects.push(pivot);
				}
			}
			if (value.length >= 1) {
				this.main = value[value.length - 1];
			} else {
				this.main = null;
			}
			this._app.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		/**
		 * 删除 
		 */		
		public function deleted() : void {
			if (this.main && this.main.parent) {
				this.main.parent.removeChild(this.main);
			}
			this.objects = [];
		}
		
	}
}
