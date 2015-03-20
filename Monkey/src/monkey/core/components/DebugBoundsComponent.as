package monkey.core.components {
	
	import flash.geom.Vector3D;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.entities.DebugBounds;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Vector3DUtils;

	public class DebugBoundsComponent extends Component3D {
		
		private static var _aabb 	: DebugBounds;
		private static const space  : Number = 0.0000001;
		private static const center	: Vector3D = new Vector3D();
		private static const scale  : Vector3D = new Vector3D();
		
		public function DebugBoundsComponent() {
			super();
		}
		
		public static function get aabb():DebugBounds {
			if (!_aabb) {
				_aabb = new DebugBounds();
			}
			return _aabb;
		}
		
		override public function onDraw(scene:Scene3D):void {
			super.onDraw(scene);
			if (this.object3D.renderer && this.object3D.renderer.mesh) {
				var bounds : Bounds3D = this.object3D.renderer.mesh.bounds;
				this.object3D.transform.localToGlobal(bounds.center, center);
				this.object3D.transform.getScale(true, scale);
				Vector3DUtils.mul(scale, bounds.length, scale);
				aabb.transform.local.copyFrom(this.object3D.transform.world);
				aabb.transform.setPosition(center.x, center.y, center.z);
				aabb.transform.setScale(scale.x + space, scale.y + space, scale.z + space);
				aabb.draw(scene);
			}
		}
				
	}
}
