package ide.plugins.groups.properties {

	import L3D.core.base.Geometry3D;
	import L3D.core.base.Pivot3D;
	import L3D.core.entities.Mesh3D;
	
	import ide.App;
	import ui.core.controls.Label;
	import ui.core.type.Align;

	public class MeshGroup extends PropertiesGroup {
		
		private var surfaces : Label;
		private var triangles : Label;
		private var vertices : Label;
		private var materials : Label;
		private var app : App;

		public function MeshGroup() {
			super("MESH");
			this.triangles = layout.addControl(new Label("-", 40, Align.LEFT, true), "Triangles:") as Label;
			this.vertices = layout.addControl(new Label("-", 40, Align.LEFT, true), "Vertices:") as Label;
			this.surfaces = layout.addControl(new Label("-", 40, Align.LEFT, true), "Surfaces:") as Label;
			this.materials = layout.addControl(new Label("-", 40, Align.LEFT, true), "Materials:") as Label;
		}
		
		override public function update(app : App) : Boolean {
			var geoCount : int = 0;
			var triCount : int;
			var vertCount : int;
			this.app = app;
			if (app.selection.getByClass(Mesh3D).length == 0) {
				return false;
			}
			for each (var pivot : Pivot3D in app.selection.objects) {
				if (pivot is Mesh3D) {
					var mesh : Mesh3D = (pivot as Mesh3D);
					for each (var geo : Geometry3D in mesh.geometries) {
						geoCount++;
						if (geo.numTriangles == -1) {
							vertCount += geo.vertexVector.length / geo.sizePerVertex;
							triCount += geo.indexVector.length / 3;
						} else {
							triCount += geo.numTriangles;
							if (geo.numTriangles == (geo.indexVector.length / 3)) {
								vertCount += geo.vertexVector.length / geo.sizePerVertex;
							} else {
								vertCount += geo.numTriangles * 3;
							}
						}
					} 
				} else {
					continue;
				}
			}
			this.surfaces.text = "" + geoCount.toString();
			this.materials.text = "" + 1;
			this.vertices.text = "" + vertCount;
			this.triangles.text = "" + triCount;
			return true;
		}

	}
}
