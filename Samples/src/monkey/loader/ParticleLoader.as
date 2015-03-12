package monkey.loader {

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Cast;
	import monkey.core.utils.ParticleUtils;
	import monkey.core.utils.Zip;

	/**
	 * 粒子加载器
	 * @author Neil
	 *
	 */
	public class ParticleLoader extends Object3D implements IQueLoader {

		/** 粒子容器 */
		public var particles : Object3D;
		
		private var cfg 	 	: Object;						// 粒子系统配置
		private var zip 	 	: Zip;							// zip
		private var texMap 	 	: Dictionary; 	 				// 图片loader字典
		private var sufMap 	 	: Dictionary; 	 				// 粒子数据字典
		private var list	 	: Vector.<ParticleSystem>;		// 所有粒子列表
		private var count 	 	: int;						 	// 图片数量
		private var loader   	: URLLoader;					// loader
		private var _loaded	 	: Boolean;						// 是否载入完成
		private var _url 	 	: String = "";					// url
		private var _bytesTotal : uint = 1;
		private var _bytesLoaded: uint = 1;
		
		public function ParticleLoader(url : String = "") {
			super();
			this._url   = url;
			this._loaded= false;
			this.texMap = new Dictionary();
			this.sufMap = new Dictionary();
			this.list   = new Vector.<ParticleSystem>();
		}
		
		/**
		 * 扫描所有的粒子 
		 * 
		 */		
		private function scanParticleSystem() : void {
			this.particles.forEach(function(pivot : ParticleSystem) : void {
				list.push(pivot);
			}, ParticleSystem);
			if (this.particles is ParticleSystem) {
				list.push(this.particles as ParticleSystem);
			}
		}
		
		public function loadBytes(bytes : ByteArray) : void {
			this.zip = new Zip();
			this.zip.loadBytes(bytes);
			this.cfg = JSON.parse(Cast.byteToString(this.zip.getFileByName("config")));
			this.particles = ParticleUtils.readParticles(this.cfg);
			this.scanParticleSystem();
			this.loadImages();
		}
				
		/**
		 * 装载图片 
		 */		
		private function loadImages() : void {
			for each (var pivot : ParticleSystem in this.list) {
				// 图片
				if (!this.texMap[pivot.userData.imageName]) {
					var loader : Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
					loader.loadBytes(zip.getFileByName(pivot.userData.imageName));
					this.texMap[pivot.userData.imageName] = loader;
					this.count++;
				}
				// 粒子数据
				if (!this.sufMap[pivot.userData.uuid]) {
					this.sufMap[pivot.userData.uuid] = ParticleUtils.readSurfaces(zip.getFileByName(pivot.userData.uuid));
				}
			}
		}
		
		/**
		 * 图片装载完成
		 * @param event
		 *
		 */
		private function onImageLoadComplete(event : Event) : void {
			this.count--;
			if (this.count <= 0) {
				this.parseComplete();
			}
		}
		
		/**
		 * 解析完成 
		 */		
		private function parseComplete() : void {
			// 创建texture
			for (var key : String in texMap) {
				var loader : Loader = texMap[key];
				texMap[key] = new Bitmap2DTexture((loader.content as Bitmap).bitmapData);
				loader.unloadAndStop(true);
			}
			// 设置粒子的贴图以及数据
			for each (var pivot : ParticleSystem in this.list) {
				pivot.texture = texMap[pivot.userData.imageName].clone();
				for each (var surf : Surface3D in sufMap[pivot.userData.uuid]) {
					pivot.renderer.mesh.surfaces.push(surf.clone());
				}
				pivot.manualBuild();
				pivot.animator.play();
			}
			this._loaded = true;
			this.freeAssets();
			this.addChild(particles);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * 释放内存
		 */		
		private function freeAssets() : void {
			for each (var tex : Bitmap2DTexture in texMap) {
				tex.dispose();
			}
			for each (var surfaces : Vector.<Surface3D> in sufMap) {
				for each (var surf : Surface3D in surfaces) {
					surf.dispose();
				}
			}
			this.zip.dispose();
			this.zip    = null;
			this.texMap = null;
			this.sufMap = null;
			this.list   = null;
			if (this.loader) {
				this.loader.close();
				(this.loader.data as ByteArray).clear();
				this.loader = null;
			}
		}
		
		public function load() : void {
			this.loader = new URLLoader();
			this.loader.dataFormat = URLLoaderDataFormat.BINARY;
			this.loader.addEventListener(IOErrorEvent.IO_ERROR,  onIoError);
			this.loader.addEventListener(Event.COMPLETE, 		 loadComplete);
			this.loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			this.loader.load(new URLRequest(this._url));
		}
		
		private function onProgress(event:ProgressEvent) : void {
			this._bytesLoaded = event.bytesLoaded;
			this._bytesTotal  = event.bytesTotal;
			this.dispatchEvent(event);
		}
		
		private function loadComplete(event:Event) : void {
			this.loadBytes(this.loader.data as ByteArray);
		}
		
		private function onIoError(event:IOErrorEvent) : void {
			this.dispatchEvent(event);
		}
				
		public function close() : void {
			if (this.loader) {
				this.loader.close();
				this.loader = null;
			}
		}
		
		public function get bytesTotal() : uint {
			return this._bytesTotal;
		}

		public function get bytesLoaded() : uint {
			return this._bytesLoaded;
		}

		public function get loaded() : Boolean {
			return this._loaded;
		}

	}
}
