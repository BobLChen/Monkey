package ide.plugins {
	
	import com.adobe.images.PNGEncoder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import ide.App;
	import ide.events.LogEvent;
	import ide.events.SceneEvent;
	import ide.plugins.groups.particles.lifetime.LifetimeData;
	
	import monkey.core.animator.Animator;
	import monkey.core.animator.Label3D;
	import monkey.core.animator.SkeletonAnimator;
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.materials.SkeDifMatMaterial;
	import monkey.core.materials.SkeDifQuatMaterial;
	import monkey.core.parser.Max3DSParser;
	import monkey.core.parser.NavMeshParser;
	import monkey.core.parser.OBJParser;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.renderer.SkeletonRenderer;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.AnimUtil;
	import monkey.core.utils.AssetsType;
	import monkey.core.utils.Color;
	import monkey.core.utils.Linears;
	import monkey.core.utils.Mesh3DUtils;
	import monkey.core.utils.Texture3DUtils;
	import monkey.loader.ParticleLoader;
	import monkey.loader.SkyboxLoader;
	import monkey.loader.WaterLoader;
	import monkey.navmesh.NavigationCell;
	import monkey.navmesh.NavigationMesh;

	public class FilePluginUtils extends EventDispatcher {
		
		public static const TYPES : Array = [
			AssetsType.JPEG,
			AssetsType.JPG,
			AssetsType.PNG,
			AssetsType.MESH,
			AssetsType.ANIM,
			AssetsType.OBJ,
			AssetsType.MAX3DS,
			AssetsType.NAV,
			AssetsType.WATER,
			AssetsType.SKYBOX,
			AssetsType.PARTICLE
		];
		
		private static var _filters : Array;
		private static var _app		: App;
		private static var _utils	: Dictionary;
		
		public function FilePluginUtils() {
				
		}
		
		public static function openFile() : void {
			var file : File = new File();
			file.addEventListener(Event.SELECT, onSelectedFile);
			file.browseForOpen("open", filters);
		}
		
		public static function openFiles() : void {
			var file : File = new File();
			file.addEventListener(Event.SELECT, onSelectedFiles);
			file.browseForDirectory("open");
		}
		
		private static function onSelectedFiles(event:Event) : void {
			var files : File = event.target as File;
			for each (var file : File in files.getDirectoryListing()) {
				if (file.exists && !file.isDirectory) {
					readFile(file);
				}
			}
		}
		
		private static function readFile(file : File) : void {
			var type : String = getType(file.name);
			if (TYPES.indexOf(type) == -1) {
				return;
			}
			var stream : FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			stream.position = 0;
			var bytes : ByteArray = new ByteArray();
			stream.readBytes(bytes, 0, stream.bytesAvailable);
			onImport(bytes, file.name, type);
			App.core.dispatchEvent(new LogEvent("file:" + file.nativePath));
		}
		
		private static function onSelectedFile(event:Event) : void {
			var file : File = event.target as File;
			readFile(file);
		}		
						
		private static function onImport(data : ByteArray, name : String, type : String) : void {
			if (!_utils[type] || !data) {
				return;
			}
			var func : Function = _utils[type];
			var obj  : Object3D = func(name, data);
			if (obj) {
				obj.name = name;
				_app.scene.addChild(obj);
				_app.selection.objects = [obj];
			}
		}
		
		private static function getType(name : String) : String {
			var tokens : Array = name.split(".");
			var type : String = tokens.pop();
			return type.toLowerCase();
		}
		
		private static function get filters() : Array {
			if (!_filters) {
				var extension : String = "";
				for each (var type : String in TYPES) {
					extension += "*." + type + ";";
				}
				_filters = [new FileFilter("File", extension)];
			}
			return _filters;
		}
		
		public static function init(app:App) : void {
			_app = app;
			_utils = new Dictionary();
			_utils[AssetsType.MESH] 	= openMesh;
			_utils[AssetsType.OBJ]  	= openOBJ;
			_utils[AssetsType.MAX3DS] 	= open3DS;
			_utils[AssetsType.WATER]	= openWater;
			_utils[AssetsType.SKYBOX]	= openSkybox;
			_utils[AssetsType.NAV]		= openNavmesh;
			_utils[AssetsType.PARTICLE] = openParticle;
			_utils[AssetsType.ANIM]		= openAnim;
		}
		
		public static function openAnim(name : String, bytes : ByteArray) : Object3D {
			var obj : Object3D = App.core.selection.main;
			if (!obj || !obj.renderer || !obj.renderer.mesh) {
				return null;
			}
			var anim : Animator = AnimUtil.readAnim(bytes);
			anim.addLabel(new Label3D(name, 0, anim.totalFrames));
			// 拼接动画
			if (obj.animator) {
				obj.animator.append(anim);
			} else {
				obj.addComponent(anim);
			}
			obj.animator.stop();
			// 骨骼动画，但是为非骨骼动画渲染器
			if (anim is SkeletonAnimator && !(obj.renderer is SkeletonRenderer)) {
				var mesh : Mesh3D = obj.renderer.mesh;
				obj.removeComponent(obj.renderer);
				obj.addComponent(new SkeletonRenderer(mesh, null));
				var skea : SkeletonAnimator = anim as SkeletonAnimator;
				if (skea.quat) {
					obj.renderer.material = new SkeDifQuatMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData));
				} else {
					obj.renderer.material = new SkeDifMatMaterial(new Bitmap2DTexture(Texture3DUtils.nullBitmapData));
				}
			}
			return obj;
		}
		
		/**
		 * 导入mesh 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openMesh(name : String, bytes : ByteArray) : Object3D {
			var obj : Object3D = new Object3D();
			obj.addComponent(new MeshRenderer(Mesh3DUtils.readMesh(bytes), new ColorMaterial(new Color(0x888888))));
			return obj;
		}
		
		/**
		 * 导入obj 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openOBJ(name : String, bytes : ByteArray) : Object3D {
			bytes.position = 0;
			var txt : String = bytes.readUTFBytes(bytes.length);
			var parser : OBJParser = new OBJParser();
			parser.proceedParsing(txt);
			return parser.pivot;
		}
		
		/**
		 * 导入3ds 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function open3DS(name : String, bytes : ByteArray) : Object3D {
			bytes.position = 0;
			var parser : Max3DSParser = new Max3DSParser(bytes, "");
			parser.startParsing();
			return parser.pivot;
		}
		
		/**
		 * 导入navmesh 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openNavmesh(name : String, bytes : ByteArray) : Object3D {
			bytes.position = 0;
			var navmesh : NavigationMesh = NavMeshParser.parse(bytes);
			// 根据导入的navmesh构建模型数据
			var surf : Surface3D = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
			surf.indexVector = new Vector.<uint>();
			for each (var cell : NavigationCell in navmesh.cells) {
				surf.getVertexVector(Surface3D.POSITION).push(
					cell.vertives[0].x, cell.vertives[0].y, cell.vertives[0].z,
					cell.vertives[1].x, cell.vertives[1].y, cell.vertives[1].z,
					cell.vertives[2].x, cell.vertives[2].y, cell.vertives[2].z
				);
			}
			var len : int = surf.getVertexVector(Surface3D.POSITION).length / 3;
			for (var i:int = 0; i < len; i++) {
				surf.indexVector.push(i);
			}
			navmesh.addComponent(new MeshRenderer(new Mesh3D([surf]), new ColorMaterial(Color.WHITE)));
			return navmesh;
		}
				
		/**
		 * 导入water 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openWater(name : String, bytes : ByteArray) : Object3D {
			var loader : WaterLoader = new WaterLoader("");
			loader.loadBytes(bytes);
			loader.addEventListener(Event.COMPLETE, function(e : Event):void{
				App.core.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
			});
			return loader;
		}
		
		/**
		 * 导入天空盒 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openSkybox(name : String, bytes : ByteArray) : Object3D {
			var loader : SkyboxLoader = new SkyboxLoader("");
			loader.loadBytes(bytes);
			loader.addEventListener(Event.COMPLETE, function(e : Event):void{
				App.core.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
			});
			return loader;
		}
		
		/**
		 * 导入粒子系统 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function openParticle(name : String, bytes : ByteArray) : Object3D {
			var loader : ParticleLoader = new ParticleLoader("");
			loader.loadBytes(bytes);
			loader.addEventListener(Event.COMPLETE, function(e : Event):void{
				loader.forEach(function(particle : ParticleSystem):void{
					if (particle.userData.optimize) {
						return;
					}
					particle.userData.imageData = PNGEncoder.encode(particle.texture.bitmapData);
					var value : Object = particle.userData.lifetimeData;
					var data  : LifetimeData = new LifetimeData();
					data.speedX   = convert2Linears(value.speedX);
					data.speedY   = convert2Linears(value.speedY);
					data.speedZ   = convert2Linears(value.speedZ);
					data.axisX    = convert2Linears(value.axisX);
					data.axisY    = convert2Linears(value.axisY);
					data.axisZ    = convert2Linears(value.axisZ);
					data.angle    = convert2Linears(value.angle);
					data.size     = convert2Linears(value.size);
					data.lifetime = value.lifetime;
					particle.userData.lifetime = data;
					
				}, ParticleSystem);
				loader.parent = null;
				App.core.scene.addChild(loader.particles);
				App.core.selection.objects = [loader.particles];
				App.core.dispatchEvent(new SceneEvent(SceneEvent.CHANGE));
			});
			return loader;
		}
		
		private static function convert2Linears(data : Object) : Linears {
			var ret : Linears = new Linears();
			for (var i:int = 0; i < data.value.length; i += 2) {
				ret.datas.push(new Point(data.value[i], data.value[i + 1]));				
			}
			ret.yValue = data.yValue;
			return ret;
		}
		
	}
}
