package ide.utils {
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import monkey.core.animator.Animator;
	import monkey.core.animator.SkeletonAnimator;
	import monkey.core.base.Object3D;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.materials.DiffuseMaterial;
	import monkey.core.materials.SkeDifMatMaterial;
	import monkey.core.materials.SkeDifQuatMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.renderer.SkeletonRenderer;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.Color;
	import monkey.core.utils.Mesh3DUtils;
	import monkey.core.utils.Texture3DUtils;
	
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
			// obj
			var obj : Object3D = new Object3D();
			obj.name = cfg.name;
			obj.transform.local.copyRawDataFrom(Vector.<Number>(cfg.transform));
			obj.transform.updateTransforms(true);
			// 含有动画
			if (cfg.anim) {
				var animBytes : ByteArray = new ByteArray();
				fs = new FileStream();
				fs.open(new File(this.file.parent.url + "/" + cfg.anim.name), FileMode.READ);
				fs.readBytes(animBytes, 0, fs.bytesAvailable);
				fs.close();
				var anim : Animator = AnimUtil.readAnim(animBytes);
				if ((anim as SkeletonAnimator).quat) {
					obj.addComponent(new SkeletonRenderer(Mesh3DUtils.readMesh(meshBytes), new SkeDifQuatMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData))));
				} else {
					obj.addComponent(new SkeletonRenderer(Mesh3DUtils.readMesh(meshBytes), new SkeDifMatMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData))));					
				}
				obj.addComponent(anim);
			} else {
				obj.addComponent(new MeshRenderer(Mesh3DUtils.readMesh(meshBytes), new ColorMaterial(Color.WHITE)));
			}
			
			this.addChild(obj);
			// 读取贴图
			if (cfg.textures.DiffuseColor.length >= 1) {
				var loader : Loader = loadBitmapdata(new File(this.file.parent.url + "/" + cfg.textures.DiffuseColor[0]));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
					var texture : Bitmap2DTexture = new Bitmap2DTexture((loader.content as Bitmap).bitmapData);
					if (obj.renderer.material is ColorMaterial) {
						obj.renderer.material = new DiffuseMaterial(texture);
					} else if (obj.renderer.material is SkeDifQuatMaterial) {
						(obj.renderer.material as SkeDifQuatMaterial).texture = texture;
					} else if (obj.renderer.material is SkeDifMatMaterial) {
						(obj.renderer.material as SkeDifMatMaterial).texture = texture;
					}
				});
			}
		}
				
		private function loadBitmapdata(file : File) : Loader {
			var loader : Loader = new Loader();
			if (file.exists) {
				var fs : FileStream = new FileStream();
				fs.open(file, FileMode.READ);
				var bytes : ByteArray = new ByteArray();
				fs.readBytes(bytes, 0, fs.bytesAvailable);
				fs.close();
				loader.loadBytes(bytes);	
			}
			return loader;
		}
		
	}
}
