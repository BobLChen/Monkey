package ide.plugins {

	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ide.App;
	
	import ui.core.interfaces.IPlugin;

	public class FilePlugin implements IPlugin {
		
		private var _app : App;
						
		public function FilePlugin() {
			
		}
		
		public function init(app : App) : void {
			this._app = app;
			this._app.addMenu("File/open file",  openFile);
			this._app.addMenu("File/open files", openFiles);
			
			FilePluginUtils.init(app);
		}
			
		private function openFile(e : Event) : void {
			FilePluginUtils.openFile();
		}
		
		private function openFiles(e : Event) : void {
			
		}
		
		private function importAnimation(e : MouseEvent) : void {
//			if (this._app.selection.main is Mesh3D) {
//				var mesh : Mesh3D = Mesh3D(this._app.selection.main);
//				if (mesh.geometries == null || mesh.geometries.length == 0)
//					return;
//				var file : FileUtils = new FileUtils();
//				file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//					var anim : DefaultRender = Mesh3DUtils.readAnim(file.binary);
//					var label : Label3D = Mesh3DUtils.appendAnimation(mesh, anim, file.name);	
//					_app.selection.objects = [mesh];
//					if (!mesh.userData.dict) {
//						mesh.userData.dict = new Dictionary();
//					}
//					mesh.userData.dict[label] = file.name;
//				});
//				file.openForBinary([new FileFilter("Animation","*.anim")]);
//			}
		}
		
		private function importNavmesh1(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var navmesh : NavigationMesh = ExportImportUtils.readNavmesh(file.binary);
//				_app.scene.addChild(navmesh);
//				setTimeout(function():void{
//					_app.selection.objects = [navmesh];
//				}, 10);	
//			});
//			file.openForBinary([new FileFilter("NavMesh","*.navmesh")]);
		}
		
		private function importNavmesh(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var mesh : Mesh3D = Mesh3DUtils.readMesh(file.binary);
//				mesh.name = "Navmesh";
//				var navmesh : NavigationMesh = new NavigationMesh(mesh);
//				_app.scene.addChild(navmesh);
//				setTimeout(function():void{
//					_app.selection.objects = [navmesh];
//				}, 10);	
//			});
//			file.openForBinary([new FileFilter("Mesh","*.mesh")]);
		}
		
		private function importSkybox(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var skybox : SkyBox = ExportImportUtils.importSkybox(file.binary);
//				skybox.name = file.name;
//				_app.scene.addChild(skybox);
//				setTimeout(function():void{
//					_app.selection.objects = [skybox];
//				}, 10);
//			});
//			file.openForBinary([new FileFilter("Skybox","*.sky")]);
		}
		
		private function importWater(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var water : Water = ExportImportUtils.importWater(file.binary);
//				water.name = file.name;
//				_app.scene.addChild(water);
//				setTimeout(function():void{
//					_app.selection.objects = [water];
//				}, 10);
//			});
//			file.openForBinary([new FileFilter("Water","*.water")]);
		}
		
		private function importParticles(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var particle : Pivot3D = ExportImportUtils.importParticles(file.binary);
//				_app.scene.addChild(particle);
//				setTimeout(function():void{
//					_app.selection.objects = [particle];
//				}, 10);	
//			});
//			file.openForBinary([new FileFilter("Particles","*.particle")]);
		}
		
		private function importMesh(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var mesh : Mesh3D = Mesh3DUtils.readMesh(file.binary);
//				mesh.name = file.name;
//				mesh.userData.meshID = file.name;
//				_app.scene.addChild(mesh);
//				setTimeout(function():void{
//					_app.selection.objects = [mesh];
//				}, 10);	
//			});
//			file.openForBinary([new FileFilter("Mesh","*.mesh")]);
		}
		
		private function importObJ(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var parser : OBJParser = new OBJParser();
//				parser.proceedParsing(ParserUtil.toString(file.binary));
//				parser.pivot..name = file.name;
//				_app.scene.addChild(parser.pivot);
//				setTimeout(function():void{
//					_app.selection.objects = [parser.pivot];
//				}, 10);	
//			});
//			file.openForBinary([new FileFilter("OBJ","*.obj;*.OBJ")]);
		}
		
		private function import3DS(e : MouseEvent) : void {
//			var file : FileUtils = new FileUtils();
//			file.addEventListener(FileUtils.BINARY, function(e:Event):void{
//				var parser : Max3DSParser = new Max3DSParser(file.binary, "");
//				parser.startParsing();
//				parser.pivot..name = file.name;
//				_app.scene.addChild(parser.pivot);
//				setTimeout(function():void{
//					_app.selection.objects = [parser.pivot];
//				}, 10);	
//			});
//			file.openForBinary([new FileFilter("3DS","*.3DS;*.3ds")]);
		}
		
		public function start() : void {
			
		}
	}
}
