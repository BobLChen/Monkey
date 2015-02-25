package ide.plugins.groups.properties {

	import ide.App;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.renderer.MeshRenderer;
	
	import ui.core.controls.Label;
	import ui.core.type.Align;
	
	/**
	 * mesh属性 
	 * @author Neil
	 * 
	 */	
	public class MeshGroup extends PropertiesGroup {
		
		private var surfaces 	: Label;		// surface数量
		private var triangles 	: Label;		// 三角形数量
		private var vertices 	: Label;		// 顶点数量
		private var app 		: App;
		
		public function MeshGroup() {
			super("MESH");
			this.accordion.contentHeight = 60;
			this.triangles = layout.addControl(new Label("-", 40, Align.LEFT, true), "Triangles:") as Label;
			this.vertices  = layout.addControl(new Label("-", 40, Align.LEFT, true), "Vertices:")  as Label;
			this.surfaces  = layout.addControl(new Label("-", 40, Align.LEFT, true), "Surfaces:")  as Label;
		}
		
		override public function update(app : App) : Boolean {
			if (!app.selection.main) {
				return false;
			}
			var geoCount  : int = 0;
			var triCount  : int;
			var vertCount : int;
			this.app = app;
			if (!app.selection.main.getComponent(MeshRenderer)) {
				return false;
			}
			for each (var pivot : Object3D in app.selection.objects) {
				var mesh : Mesh3D = (pivot.getComponent(MeshRenderer) as MeshRenderer).mesh;
				if (mesh) {
					for each (var geo : Surface3D in mesh.surfaces) {
						geoCount++;
						vertCount += geo.getVertexVector(Surface3D.POSITION).length / 3;
						triCount  += geo.indexVector.length / 3;
					} 
				}
			}
			this.surfaces.text  = "" + geoCount;
			this.vertices.text  = "" + vertCount;
			this.triangles.text = "" + triCount;
			return true;
		}
		
	}
}
