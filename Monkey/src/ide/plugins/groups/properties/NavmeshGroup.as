package ide.plugins.groups.properties {
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import L3D.collisions.MouseCollision;
	import L3D.core.entities.primitives.Capsule;
	import L3D.core.entities.primitives.Lines3D;
	import L3D.navmesh.NavigationCell;
	import L3D.navmesh.NavigationMesh;
	import L3D.system.Input3D;
	
	import ide.events.LogEvent;
	import ide.events.SceneEvent;
	
	import ide.App;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;

	public class NavmeshGroup extends PropertiesGroup {
		
		private var app : App;
		
		private var startMesh : Capsule = new Capsule("StartPos", 0.3, 1, 12, null);
		private var endMesh : Capsule = new Capsule("EndPos", 0.3, 1, 12, null);
		private var navMesh : NavigationMesh;
		private var startCell : NavigationCell;
		private var startPos : Vector3D = new Vector3D();
		private var endCell : NavigationCell;
		private var endPos : Vector3D = new Vector3D();
		private var pathLine : Lines3D = new Lines3D("Path");
		
		private var sx : Spinner;
		private var sy : Spinner;
		private var sz : Spinner;
		private var ex : Spinner;
		private var ey : Spinner;
		private var ez : Spinner;
		private var si : Spinner;
		private var ei : Spinner;
				
		private var mouse : MouseCollision;
		
		public function NavmeshGroup() {
			super("NavMesh");
			layout.labelWidth = 55;
			layout.addHorizontalGroup("Start:");
			layout.labelWidth = 15;
			this.sx = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "X:") as Spinner;
			this.sy = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Y:") as Spinner;
			this.sz = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Z:") as Spinner;
			this.sx.enabled = false;
			this.sy.enabled = false;
			this.sz.enabled = false;
			layout.endGroup();
			layout.addControl(new Separator());
			layout.labelWidth = 55;
			layout.addHorizontalGroup("End:");
			layout.labelWidth = 15;
			this.ex = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "X:") as Spinner;
			this.ey = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Y:") as Spinner;
			this.ez = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Z:") as Spinner;
			layout.endGroup();
			layout.addControl(new Separator());
			layout.labelWidth = 55;
			layout.addHorizontalGroup("Index:");
			layout.labelWidth = 45;
			this.si = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "StartIdx:") as Spinner;
			this.ei = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "EndIdx:") as Spinner;
			this.si.enabled = false;
			this.ei.enabled = false;
			layout.endGroup();
			
			this.ex.enabled = false;
			this.ey.enabled = false;
			this.ez.enabled = false;
			
			this.mouse = new MouseCollision();
		}
		
		override public function update(app : App) : Boolean {
			if (app.selection.main is NavigationMesh) {
				this.app = app;
				this.navMesh = app.selection.main as NavigationMesh;
				this.navMesh.addChild(startMesh);
				this.navMesh.addChild(endMesh);
				this.navMesh.addChild(pathLine);
				this.startMesh.mouseEnabled = false;
				this.endMesh.mouseEnabled = false;
				this.pathLine.mouseEnabled = false;
				this.mouse.addCollisionWith(this.navMesh);
				this.app.addEventListener(SceneEvent.UPDATE_EVENT, this.updateEvent, false, -1000);
				return true;
			}
			return false;
		}
		
		protected function updateEvent(event:Event) : void {
			if (Input3D.mouseHit) {
				if (app.scene.viewPort.contains(Input3D.mouseX, Input3D.mouseY)) {
					if (mouse.test(Input3D.mouseX, Input3D.mouseY)) {
						// 三角形的存储顺序为逆时针，而navmesh为顺时针
						var cell : NavigationCell = navMesh.findCell(mouse.data[0].tri.v2, mouse.data[0].tri.v1, mouse.data[0].tri.v0);
						// 绘制选中的三角形
						startCell = cell;
						startMesh.setPosition(mouse.data[0].point.x, mouse.data[0].point.y, mouse.data[0].point.z);
						startPos.copyFrom(mouse.data[0].point);
						
						sx.value = startPos.x;
						sy.value = startPos.y;
						sz.value = startPos.z;
						
						si.value = navMesh.cells.indexOf(startCell);
					}
				}
			}
			
			if (Input3D.rightMouseHit) {
				if (mouse.test(Input3D.mouseX, Input3D.mouseY)) {
					// 三角形的存储顺序为逆时针，而navmesh为顺时针
					var cell0 : NavigationCell = navMesh.findCell(mouse.data[0].tri.v2, mouse.data[0].tri.v1, mouse.data[0].tri.v0);
					// 绘制选中的三角形
					endCell = cell0;
					endMesh.setPosition(mouse.data[0].point.x, mouse.data[0].point.y, mouse.data[0].point.z);
					endPos.copyFrom(mouse.data[0].point);
					
					ex.value = endPos.x;
					ey.value = endPos.y;
					ez.value = endPos.z;
					
					ei.value = navMesh.cells.indexOf(endCell);
					
					if (startCell != null && endCell != null) {
						var t : int = getTimer();
						var path : Array = navMesh.findPath(startPos, startCell, endPos, endCell);
						var wayPoint : Array = navMesh.findWayPoint(path, startPos, endPos);
						var ct : int = getTimer();
						app.dispatchEvent(new LogEvent("寻路消耗时间：" + (ct - t) + "毫秒"));
						// 绘制路点
						pathLine.clear();
						pathLine.lineStyle(1, 0xff00ff);
						pathLine.moveTo(startPos.x, startPos.y, startPos.z);
						
						app.dispatchEvent(new LogEvent("路点(起点)：" + startPos.x + "," + startPos.y + "," + startPos.z));
						for each (var p : Vector3D in wayPoint) {
							pathLine.lineTo(p.x, p.y, p.z);
							app.dispatchEvent(new LogEvent("路点：" + p.x + "," + p.y + "," + p.z));
						}
						
						for each (var pc : NavigationCell in path) {
							app.dispatchEvent(new LogEvent("路径网格索引:" + navMesh.cells.indexOf(pc) + "|Arrival:" + pc.arrivalWall));
						}
					}
				}
			}
			
		}
		
	}
}
