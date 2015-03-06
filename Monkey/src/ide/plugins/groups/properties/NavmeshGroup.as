package ide.plugins.groups.properties {
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import ide.App;
	import ide.events.LogEvent;
	import ide.events.SceneEvent;
	
	import monkey.core.base.Object3D;
	import monkey.core.collisions.CollisionInfo;
	import monkey.core.collisions.MouseCollision;
	import monkey.core.entities.Lines3D;
	import monkey.core.entities.primitives.Capsule;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.utils.Color;
	import monkey.core.utils.Input3D;
	import monkey.navmesh.NavigationCell;
	import monkey.navmesh.NavigationMesh;
	
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	
	/**
	 * 导航网格插件 
	 * @author Neil
	 * 
	 */	
	public class NavmeshGroup extends PropertiesGroup {
		
		private var app : App;
		
		private var startRole 	: Object3D;
		private var endRole 	: Object3D;
		private var navMesh 	: NavigationMesh;
		private var startCell 	: NavigationCell;
		private var startPos 	: Vector3D = new Vector3D();
		private var endCell 	: NavigationCell;
		private var endPos 		: Vector3D = new Vector3D();
		private var pathLine 	: Lines3D  = new Lines3D();
		private var sx 			: Spinner;
		private var sy 			: Spinner;
		private var sz 			: Spinner;
		private var ex 			: Spinner;
		private var ey 			: Spinner;
		private var ez 			: Spinner;
		private var si 			: Spinner;
		private var ei 			: Spinner;
		private var info 		: CollisionInfo = new CollisionInfo();
		
		private var mouse : MouseCollision;
		
		public function NavmeshGroup() {
			super("NavMesh");
			
			this.startRole = new Object3D();
			this.startRole.name = "StartRole";
			this.startRole.addComponent(new MeshRenderer(new Capsule(0.3, 1, 12), new ColorMaterial(new Color(0xFF0000))));
			this.endRole   = new Object3D(); //  = new Capsule(0.3, 1, 12)
			this.endRole.name = "EndRole";
			this.endRole.addComponent(new MeshRenderer(new Capsule(0.3, 1, 12), new ColorMaterial(new Color(0x00FF00))));
			this.pathLine.name = "PathLine";
			
			this.layout.labelWidth = 55;
			this.layout.addHorizontalGroup("Start:");
			this.layout.labelWidth = 15;
			this.sx = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "X:") as Spinner;
			this.sy = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Y:") as Spinner;
			this.sz = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Z:") as Spinner;
			this.sx.enabled = false;
			this.sy.enabled = false;
			this.sz.enabled = false;
			this.layout.endGroup();
			
			this.layout.addControl(new Separator());
			this.layout.labelWidth = 55;
			this.layout.addHorizontalGroup("End:");
			this.layout.labelWidth = 15;
			this.ex = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "X:") as Spinner;
			this.ey = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Y:") as Spinner;
			this.ez = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "Z:") as Spinner;
			this.layout.endGroup();
			
			this.layout.addControl(new Separator());
			this.layout.labelWidth = 55;
			this.layout.addHorizontalGroup("Index:");
			this.layout.labelWidth = 45;
			this.si = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "StartIdx:") as Spinner;
			this.ei = layout.addControl(new Spinner(0, 0, 0, 2, 0.2), "EndIdx:") as Spinner;
			this.si.enabled = false;
			this.ei.enabled = false;
			this.layout.endGroup();
			
			this.ex.enabled = false;
			this.ey.enabled = false;
			this.ez.enabled = false;
			
			this.accordion.toolTip = "左键设置起点 右键设置终点";
			this.mouse = new MouseCollision();
		}
		
		override public function update(app : App) : Boolean {
			if (app.selection.main is NavigationMesh) {
				this.app = app;
				this.navMesh = app.selection.main as NavigationMesh;
				this.navMesh.addChild(startRole);
				this.navMesh.addChild(endRole);
				this.navMesh.addChild(pathLine);
				this.mouse.addCollisionWith(this.navMesh);
				this.app.addEventListener(SceneEvent.UPDATE_EVENT, this.updateEvent, false, -1000);
				return true;
			}
			return false;
		}
		
		protected function updateEvent(event:Event) : void {
			
			if (Input3D.mouseHit) {
				if (app.scene.viewPort.contains(Input3D.mouseX, Input3D.mouseY)) {
					// 起点
					if (mouse.test(Input3D.mouseX, Input3D.mouseY, info)) {
						// 三角形的存储顺序为逆时针，而navmesh为顺时针
						var cell : NavigationCell = navMesh.findCell(info.tri.v2, info.tri.v1, info.tri.v0);
						// 绘制选中的三角形
						startCell = cell;
						startRole.transform.setPosition(info.point.x, info.point.y, info.point.z);
						startPos.copyFrom(info.point);
						sx.value = startPos.x;
						sy.value = startPos.y;
						sz.value = startPos.z;
						si.value = navMesh.cells.indexOf(startCell);
					}
				}
			}
			
			if (Input3D.rightMouseHit) {
				// 终点
				if (mouse.test(Input3D.mouseX, Input3D.mouseY, info)) {
					// 三角形的存储顺序为逆时针，而navmesh为顺时针
					var cell0 : NavigationCell = navMesh.findCell(info.tri.v2, info.tri.v1, info.tri.v0);
					// 绘制选中的三角形
					endCell = cell0;
					endRole.transform.setPosition(info.point.x, info.point.y, info.point.z);
					endPos.copyFrom(info.point);
					
					ex.value = endPos.x;
					ey.value = endPos.y;
					ez.value = endPos.z;
					
					ei.value = navMesh.cells.indexOf(endCell);
					
					if (startCell != null && endCell != null) {
						var t : int = getTimer();
						var path 	 : Array = navMesh.findPath(startPos, startCell, endPos, endCell);
						var wayPoint : Array = navMesh.findWayPoint(path, startPos, endPos);
						app.dispatchEvent(new LogEvent("寻路消耗时间：" + (getTimer() - t) + "毫秒"));
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
