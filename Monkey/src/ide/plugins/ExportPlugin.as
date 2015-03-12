package ide.plugins {

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import ide.App;
	import ide.utils.ExportUtils;
	import ide.utils.FileUtils;
	
	import monkey.core.entities.SkyBox;
	import monkey.core.entities.Water3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.AssetsType;
	import monkey.navmesh.NavigationMesh;
	
	import ui.core.interfaces.IPlugin;

	public class ExportPlugin implements IPlugin {

		private var _app : App;

		public function ExportPlugin() {
			
		}
		
		public function init(app : App) : void {
			this._app = app;
			this._app.addMenu("Export/Water",  		exportWater);
			this._app.addMenu("Export/SkyBox", 		exportSkybox);
			this._app.addMenu("Export/NavMesh",	 	exportNavmesh);
			this._app.addMenu("Export/Particle",	exportParticles);
		}
				
		private function exportNavmesh(e : Event) : void {
			if (this._app.selection.main is NavigationMesh) {
				var file : FileUtils = new FileUtils();
				file.save(ExportUtils.exportNavmesh(this._app.selection.main as NavigationMesh), AssetsType.NAV);
			}
		}
		
		private function exportSkybox(e : Event) : void {
			if (this._app.selection.main is SkyBox) {
				var file : FileUtils = new FileUtils();
				file.save(ExportUtils.exportSkybox(this._app.selection.main as SkyBox), AssetsType.SKYBOX);
			}
		}
		
		private function exportWater(e : Event) : void {
			if (this._app.selection.main is Water3D) {
				var file : FileUtils = new FileUtils();
				file.save(ExportUtils.exportWater(this._app.selection.main as Water3D), AssetsType.WATER);
			}
		}
		
		private function exportParticles(e : Event) : void {
			if (this._app.selection.main) {
				var file : File = new File();
				file.browseForSave("Save As");
				file.addEventListener(Event.SELECT, function(e : Event):void{
					var optimize : ByteArray = ExportUtils.exportParticle(_app.selection.main, true);
					var original : ByteArray = ExportUtils.exportParticle(_app.selection.main, false);
					var f  : File = new File(file.url + "_optimize" + "." + AssetsType.PARTICLE);
					var fs : FileStream = new FileStream();
					fs.open(f, FileMode.WRITE);
					fs.writeBytes(optimize, 0, optimize.length);
					fs.close();
					
					f  = new File(file.url + "." + AssetsType.PARTICLE);
					fs = new FileStream();
					fs.open(f, FileMode.WRITE);
					fs.writeBytes(original, 0, original.length);
					fs.close();
				});
			}
		}
		
		public function start() : void {

		}
	}
}
