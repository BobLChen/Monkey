package ide.plugins.groups.properties {
	
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import ide.App;
	import ide.events.LogEvent;
	
	import monkey.core.base.Object3D;
	import monkey.core.collisions.CollisionInfo;
	import monkey.core.collisions.MouseCollision;
	import monkey.core.entities.Lines3D;
	import monkey.core.entities.primitives.Capsule;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.Input3D;
	import monkey.core.utils.Vector3DUtils;
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
		private var pathMesh	: PathMesh = new PathMesh();
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
			this.pathLine.renderer.material.depthCompare = Context3DCompareMode.ALWAYS;
			
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
				this.mouse.addCollisionWith(this.navMesh);
				this.app.scene.addEventListener(Scene3D.PRE_RENDER_EVENT, 	updateEvent);
				this.app.scene.addEventListener(Scene3D.POST_RENDER_EVENT, 	onPostRender);
				return true;
			} else {
				app.scene.removeEventListener(Scene3D.PRE_RENDER_EVENT, 	updateEvent);
				app.scene.removeEventListener(Scene3D.POST_RENDER_EVENT,	onPostRender);
			}
			return false;
		}
		
		protected function onPostRender(event:Event) : void {
//			this.pathMesh.draw(app.scene);
			this.startRole.draw(app.scene);
			this.endRole.draw(app.scene);
			this.pathLine.draw(app.scene);
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
						
						pathMesh.clear();
						pathLine.clear();
						pathLine.lineStyle(2, 0x00FF00);
						for each(var node : NavigationCell in path) {
							pathMesh.addPloy(node.vertives[0], node.vertives[1], node.vertives[2]);
														
							var v0 : Vector3D = node.vertives[node.arrivalWall];
							var v1 : Vector3D = node.vertives[(node.arrivalWall + 1) % 3];
							pathLine.moveTo(v0.x, v0.y, v0.z);
							pathLine.lineTo(v1.x, v1.y, v1.z);
						}
						// 绘制路点
						pathLine.lineStyle(2, 0xFF0000);
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
import flash.geom.Vector3D;

import monkey.core.base.Object3D;
import monkey.core.base.Surface3D;
import monkey.core.entities.Mesh3D;
import monkey.core.materials.ColorMaterial;
import monkey.core.renderer.MeshRenderer;
import monkey.core.utils.Color;

class PathMesh extends Object3D {
	
	private var mesh : Mesh3D;
	private var mat  : ColorMaterial;
	private var surf : Surface3D;
	
	public function PathMesh() : void {
		super();	
		this.name = "path_mesh";
		this.surf = new Surface3D();
		this.mesh = new Mesh3D([surf]);
		this.surf.setVertexVector(Surface3D.POSITION, Vector.<Number>([
			0, 	0, 	0,
			0,	0,	0,
			0,	0,	0
		]), 3);
		this.surf.indexVector = new Vector.<uint>();
		this.surf.indexVector.push(0, 1, 2);
		this.mat  = new ColorMaterial(Color.GREEN);
		this.addComponent(new MeshRenderer(mesh, mat));
		this.setLayer(999999);
	}
	
	public function clear() : void {
		this.mesh.download(true);
		this.surf.setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);		
		this.surf.indexVector = new Vector.<uint>();
	}
	
	public function addPloy(v0 : Vector3D, v1 : Vector3D, v2 : Vector3D) : void {
		this.surf.getVertexVector(Surface3D.POSITION).push(
			v0.x, v0.y, v0.z,
			v1.x, v1.y, v1.z,
			v2.x, v2.y, v2.z
		);
		var idx : int = this.surf.indexVector.length;
		this.surf.indexVector.push(idx, idx + 1, idx + 2);
		this.surf.updateBoundings();
		this.mesh.bounds = null;
	}
	
}