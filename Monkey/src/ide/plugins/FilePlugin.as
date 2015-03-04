package ide.plugins {

	import flash.events.Event;
	
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
			FilePluginUtils.openFiles();
		}
				
		public function start() : void {
			
		}
	}
}
