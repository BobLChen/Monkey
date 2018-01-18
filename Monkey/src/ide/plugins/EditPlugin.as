package ide.plugins {

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import ide.App;
	import ide.utils.ExportUtils;
	import ide.utils.FileUtils;
	
	import monkey.core.base.Object3D;
	import monkey.core.utils.AssetsType;
	import monkey.navmesh.NavigationMesh;
	
	import ui.core.interfaces.IPlugin;

	public class EditPlugin implements IPlugin {
		
		private var _app : App;
		
		public function EditPlugin() {
		
		}

		public function start() : void {
			
		}
		
		public function init(app : App) : void {
			this._app = app;
			
			this._app = app;
			this._app.addMenu("Edit/Convert To Navmesh",  convertToNavMesh);
			this._app.addMenu("Edit/AppendAnimation", appendAnimation);
			this._app.addMenu("Edit/Delete", deleteObject);
			this._app.addMenu("Edit/Paste", pasteObject);
			this._app.addMenu("Edit/Cut", cutObject);
			
			this._app.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(event:KeyboardEvent) : void {
			if (event.ctrlKey && event.keyCode == Keyboard.X) {
				this._app.selection.cut();	
			} else if (event.ctrlKey && event.keyCode == Keyboard.V) {
				this._app.selection.paste();
			} else if (event.ctrlKey && event.keyCode == Keyboard.D) {
				this._app.selection.deleted();
			}
		}
		
		/**
		 * 拼接动画 
		 * @param e
		 * 
		 */		
		private function appendAnimation(e : Event) : void {
			var obj : Object3D = App.core.selection.main;
			if (!obj || !obj.renderer || !obj.renderer.mesh) {
				return;
			}
			var file : File = new File();
			file.browseForOpen("Animation", [new FileFilter("anim", "*.anim")]);
			file.addEventListener(Event.SELECT, function():void{
				var bytes : ByteArray = new ByteArray();
				var fs : FileStream = new FileStream();
				fs.open(file, FileMode.READ);
				fs.readBytes(bytes, 0, fs.bytesAvailable);
				fs.close();
				App.core.selection.objects = [FilePluginUtils.openAnim(file.name, bytes)];
			});
		}
		
		private function cutObject(e : Event) : void {
			this._app.selection.cut();
		}
		
		private function pasteObject(e : Event) : void {
			this._app.selection.paste();			
		}
				
		private function deleteObject(e : Event) : void {
			this._app.selection.deleted();
		}
		
		/**
		 * 将obj转化为navmesh 
		 * @param e
		 * 
		 */		
		private function convertToNavMesh(e : Event) : void {
			var obj : Object3D = this._app.selection.main;
			if (obj && obj.renderer && obj.renderer.mesh) {
				var navMesh : NavigationMesh = new NavigationMesh();
				navMesh.build(obj.renderer.mesh);
				navMesh.name = obj.name + "_NavMesh";
				var file : FileUtils = new FileUtils();
				file.save(ExportUtils.exportNavmesh(navMesh), AssetsType.NAV);
			}
		}
		
	}
}
