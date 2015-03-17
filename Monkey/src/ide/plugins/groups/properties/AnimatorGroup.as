package ide.plugins.groups.properties {
	
	import ui.core.controls.Spinner;

	/**
	 * 动画控制器 
	 * @author Neil
	 * 
	 */	
	public class AnimatorGroup extends PropertiesGroup {
		
		private var fps : Spinner;
		
		public function AnimatorGroup() {
			super("Animator");
		}
		
	}
}
