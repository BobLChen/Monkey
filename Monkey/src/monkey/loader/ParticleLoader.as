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
		
		private var _url 	 : String = "";
		private var cfg 	 : Object;
		private var zip 	 : Zip;
		private var texMap 	 : Dictionary; 	 				// 图片loader字典
		private var sufMap 	 : Dictionary; 	 				// 粒子数据字典
		private var list	 : Vector.<ParticleSystem>;
		private var count 	 : int;						 	// 图片数量
		private var loader   : URLLoader;					// laoder
		private var _loaded	 : Boolean;
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
		private function scanParticles() : void {
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
			this.scanParticles();
			
			for each (var pivot : ParticleSystem in this.list) {
				// 图片
				if (!this.texMap[pivot.userData.image]) {
					var loader : Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoadComplete);
					loader.loadBytes(zip.getFileByName(pivot.userData.image));
					this.texMap[pivot.userData.image] = loader;
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
		
		private function parseComplete() : void {
			// 设置粒子的贴图以及数据
			for each (var pivot : ParticleSystem in this.list) {
				var loader : Loader = texMap[pivot.userData.image] as Loader;
				pivot.image = (loader.content as Bitmap).bitmapData;
				for each (var surf : Surface3D in sufMap[pivot.userData.uuid]) {
					pivot.renderer.mesh.surfaces.push(surf.clone());
				}
				pivot.manualBuild();
				pivot.animator.play();
			}
			// 销毁数据
			this.zip.dispose();
			for each (loader in texMap) {
				loader.unloadAndStop(true);
			}
			for each (var surfaces : Vector.<Surface3D> in sufMap) {
				for each (surf in surfaces) {
					surf.dispose();
				}
			}
			this.zip    = null;
			this.texMap = null;
			this.sufMap = null;
			this.list   = null;
			// 解析完成			
			this.addChild(particles);
			
			if (this.loader) {
				this.loader.close();
				(this.loader.data as ByteArray).clear();
				this.loader = null;
			}
			this._loaded = true;
			this.dispatchEvent(new Event(Event.COMPLETE));
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
