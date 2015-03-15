package ide.utils {

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import monkey.core.base.Object3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.materials.DiffuseMaterial;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.Mesh3DUtils;

	public class FbxSceneLoader extends Object3D {
		
		private var _url 	: String;
		private var config 	: Object;
		private var file	: File;
		
		public function FbxSceneLoader(url : String) {
			super();
			this.file = new File(url);
			this.name = file.name;
		}
		
		public function load() : void {
			var fs : FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var str : String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			this.config = JSON.parse(str);
			for each (var mesh : Object in config.meshes) {
				this.loadMesh(mesh);
			}
			for each (var camera : Object in config.cameras) {
				this.loadCamera(camera);
			}
		}
		
		private function loadCamera(cfg : Object) : void {
						
		}
		
		private function loadMesh(cfg : Object) : void {
			// 读取模型文件
			var meshBytes : ByteArray = new ByteArray();
			var fs : FileStream = new FileStream();
			fs.open(new File(this.file.parent.url + "/" + cfg.name), FileMode.READ);
			fs.readBytes(meshBytes, 0, fs.bytesAvailable);
			fs.close();
			var mesh : Object3D = Mesh3DUtils.readMesh(meshBytes);
			mesh.transform.local.copyRawDataFrom(Vector.<Number>(cfg.transform));
			mesh.transform.updateTransforms(true);
			mesh.renderer.material = new ColorMaterial(Color.WHITE);
			this.addChild(mesh);
			// 读取贴图
			var texFile : File = new File(this.file.parent.url + "/" + cfg.textures.DiffuseColor);
			if (texFile.exists) {
				fs = new FileStream();
				fs.open(texFile, FileMode.READ);
				var bmpBytes : ByteArray = new ByteArray();
				fs.readBytes(bmpBytes, 0, fs.bytesAvailable);
				fs.close();
				var loader : Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
					mesh.renderer.material = new DiffuseMaterial(new Bitmap2DTexture((loader.content as Bitmap).bitmapData));
				});
				loader.loadBytes(bmpBytes);
			}
		}
		
	}
}
