package ide.plugins {

	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import ide.App;
	import ide.utils.FbxSceneLoader;
	
	import ui.core.controls.Window;
	import ui.core.interfaces.IPlugin;

	public class FilePlugin implements IPlugin {
		
		private var _app : App;
						
		public function FilePlugin() {
			
		}
		
		public function init(app : App) : void {
			this._app = app;
			this._app.addMenu("File/Open File",  openFile);
			this._app.addMenu("File/Open Files", openFiles);
			this._app.addMenu("File/Open Fbx",	   openFbx);
			this._app.addMenu("File/Open Scene", openScene);
			
			FilePluginUtils.init(app);
		}
		
		private function openScene(e : Event) : void {
			var file : File = new File();
			file.browseForOpen("Scene", [new FileFilter("Scene", "*.scene")]);
			file.addEventListener(Event.SELECT, function(e:Event):void{
				var loader : FbxSceneLoader = new FbxSceneLoader(file.url);
				loader.load();
				App.core.selection.objects = [loader];
				App.core.scene.addChild(loader);
			});			
		}
		
		private function openFbx(e : Event) : void {
			var file : File = new File();
			file.browseForOpen("Fbx", [new FileFilter("Fbx", "*.fbx")]);
			file.addEventListener(Event.SELECT, onSelectedFbx);
		}
		
		private function onSelectedFbx(event:Event) : void {
			var file : File = event.target as File;
			var window : FbxPlugin   = new FbxPlugin(file.nativePath);
			Window.popWindow.window  = window;
			Window.popWindow.visible = true;
			Window.popWindow.draw();
		}
		
		private function openFile(e : Event) : void {
			FilePluginUtils.openFile();
		}
		
		private function openFiles(e : Event) : void {
			FilePluginUtils.openFiles();
		}
				
		public function start() : void {
			
		}
	}
}
