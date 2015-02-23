package ide.plugins.groups.particles {

	import L3D.core.entities.primitives.Particles3D;
	import L3D.core.shader.filters.particle.ActionBase;

	public class ActionUtils {

		public static function checkAction(particles : Particles3D, classs : Class) : ActionBase {
			for each (var action : ActionBase in particles.actions) {
				if (action is classs) {
					return action;
				}
			}
			return null;
		}

		public function ActionUtils() {
		}
	}
}
