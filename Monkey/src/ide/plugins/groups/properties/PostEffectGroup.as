package ide.plugins.groups.properties {
	import L3D.core.scene.Scene3D;
	
	import ide.App;

	public class PostEffectGroup extends PropertiesGroup {
		
		public function PostEffectGroup() {
			super("PostEffect");
		}
		
		override public function update(app:App):Boolean {
			if ((app.selection.objects.length == 1) && (app.selection.objects[0] is Scene3D)) {
				return true;
			}
			return false;
		}
		
	}
}
