package ide.utils {
	
	import com.adobe.images.PNGEncoder;
	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.SkyBox;
	import monkey.core.entities.Water3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.utils.ParticleConfig;
	import monkey.core.utils.Texture3DUtils;
	import monkey.core.utils.Zip;
	import monkey.navmesh.NavigationCell;
	import monkey.navmesh.NavigationMesh;
	
	/**
	 * 导入导出工具
	 * @author Neil
	 * 
	 */	
	public class ExportImportUtils {
		
		/**
		 * 导出粒子
		 * @param container
		 * @return 
		 * 
		 */		
		public static function exportParticle(obj : Object3D, optimize : Boolean) : ByteArray {
			var config : Object = exportParticleConfig(obj, optimize);
			var map : Dictionary = new Dictionary();
			var zip : Zip = new Zip();
			zip.addString("config", JSON.stringify(config));
			obj.forEach(function(particle : ParticleSystem):void{
				zip.addFile(particle.userData.uuid,	 	getParticleData(particle));
				zip.addFile(particle.userData.imageKey, particle.userData.image);
			}, ParticleSystem);
			if (obj is ParticleSystem) {
				zip.addFile(obj.userData.uuid, 			getParticleData(obj as ParticleSystem));
				zip.addFile(obj.userData.imageKey, 		obj.userData.image);
			}
			var bytes : ByteArray = new ByteArray();
			zip.serialize(bytes);
			return bytes;
		}
		
		/**
		 * 导出粒子数据 
		 * @param particle
		 * @return 
		 * 
		 */		
		private static function getParticleData(particle : ParticleSystem) : ByteArray {
			var bytes : ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			// 写入surface长度
			var len   : int = particle.renderer.mesh.surfaces.length;
			bytes.writeInt(len);
			var types : Array = [Surface3D.POSITION, Surface3D.UV0, Surface3D.CUSTOM1, Surface3D.CUSTOM2, Surface3D.CUSTOM3, Surface3D.CUSTOM4];
			// 写入surface数据
			for (var i:int = 0; i < len; i++) {
				var surf : Surface3D = particle.renderer.mesh.surfaces[i];
				// 遍历粒子的surface数据类型
				for each (var type : int in types) {
					// 写入surf数据类型
					bytes.writeInt(type);
					var data : ByteArray = surf.getVertexBytes(type);
					// 写入buffer尺寸
					bytes.writeInt(surf.getSizeByFormat(surf.formats[type]));
					// 写入数据长度
					bytes.writeUnsignedInt(data.length);
					// 写入数据
					data.position = 0;
					bytes.writeBytes(data, 0, data.length);
				}
				// 写索引数据
				bytes.writeInt(surf.indexVector.length);
				for each (var idx : uint in surf.indexVector) {
					bytes.writeInt(idx);
				}
			}
			return bytes;
		}
		
		/**
		 * 导出粒子配置文件 
		 * @param obj			容器
		 * @param optimize		是否优化粒子系统，经过优化之后的粒子系统只能在IDE中预览，不能再编辑
		 * @return 				配置
		 * 
		 */		
		private static function exportParticleConfig(obj : Object3D, optimize : Boolean) : Object {
			var config : Object = {};
			config.name 	 = obj.name;
			config.transform = obj.transform.local.rawData;
			config.children  = [];
			if (obj is ParticleSystem) {
				config.particle = getParticleConfig(obj as ParticleSystem, optimize);
			}
			for each (var child : Object3D in obj.children) {
				config.children.push(exportParticleConfig(child, optimize));
			}
			return config;
		}
		
		/**
		 * 获取粒子的配置文件 
		 * @param particle
		 * @param optimize
		 * @return 
		 * 
		 */		
		private static function getParticleConfig(particle : ParticleSystem, optimize : Boolean) : Object {
			var config : ParticleConfig = new ParticleConfig();
			config.totalFrames 	= particle.animator.totalFrames;
			config.image		= particle.userData.imageKey;
			config.uuid			= particle.userData.uuid;
			config.world		= particle.world;
			config.colorLifetime= particle.colorLifetime;
			config.optimize		= optimize;
			config.loops		= particle.loops;
			config.billboard	= particle.billboard;
			config.bursts	 	= particle.bursts;
			config.duration		= particle.duration;
			config.frame		= particle.frame;
			config.keyFrames	= particle.keyFrames;
			config.rate			= particle.rate;
			config.totalLife  	= particle.totalLife;
			if (optimize) {
				return config;
			}
			config.shape		= particle.shape;
			config.startColor	= particle.startColor;
			config.startDelay	= particle.startDelay;
			config.startLifeTime= particle.startLifeTime;
			config.startOffset	= particle.startOffset;
			config.startRotation= particle.startRotation;
			config.startSize	= particle.startSize;
			config.startSpeed	= particle.startSpeed;
			return config;
		}
				
		/**
		 * 导出water
		 * @param water
		 * @return 
		 * 
		 */		
		public static function exportWater(water : Water3D) : ByteArray {
			
			var obj : Object = {};
			obj.width 		= water.width;
			obj.height		= water.height;
			obj.segment		= water.segment;
			obj.waterSpeed	= water.waterSpeed;
			obj.waterWave	= water.waterWave;
			obj.blendColor	= water.blendColor.color;
			obj.waterHeight	= water.waterHeight;
			obj.transform	= water.transform.world.rawData;
			
			var cfg : String = JSON.stringify(obj);
			var tex : ByteArray = null;
			var nrm : ByteArray = null;
			
			if (water.userData.texture) {
				tex = water.userData.texture;
			} else {
				tex = PNGEncoder.encode(Texture3DUtils.nullBitmapData);
			}
			if (water.userData.normal) {
				nrm = water.userData.normal;	
			} else {
				nrm = PNGEncoder.encode(Texture3DUtils.nullBitmapData);
			}
			
			var zip : Zip = new Zip();
			zip.addString("config", cfg);
			zip.addFile("texture", 	tex);
			zip.addFile("normal", 	nrm);
			var bytes : ByteArray = new ByteArray();
			zip.serialize(bytes);
			
			return bytes;
		}
		
		/**
		 * 导出天空盒 
		 * @param skybox
		 * @return 
		 * 
		 */		
		public static function exportSkybox(skybox: SkyBox) : ByteArray {
			var config : Object = {};
			config.size  = skybox.size;
			config.scaleRatio = skybox.scaleRatio;
			var bytes : ByteArray = null;
			if (skybox.userData.texture) {
				bytes = skybox.userData.texture;				
			} else {
				bytes = PNGEncoder.encode(Texture3DUtils.nullBitmapData);
			}
			var zip : Zip = new Zip();
			zip.addString("config", JSON.stringify(config));
			zip.addFile("texture", 	bytes);
			var ret : ByteArray = new ByteArray();
			zip.serialize(ret);
			return ret;
		}
		
		/**
		 * 导出navmesh 
		 * @param navmesh
		 * @return 
		 * 
		 */		
		public static function exportNavmesh(navmesh : NavigationMesh) : ByteArray {
			
			var byte : ByteArray = new ByteArray();
			byte.endian = Endian.LITTLE_ENDIAN;
			
			var len : int = navmesh.cells.length;
			// 写入单元个数
			byte.writeInt(len);
			var i : int = 0;
			var j : int = 0;
			var cell : NavigationCell = null;
			
			for (i = 0; i < len; i++) {
				cell = navmesh.cells[i];
				
				// 写顶点数据
				for (j = 0; j < 3; j++) {
					var vert : Vector3D = cell.vertives[j];
					byte.writeFloat(vert.x);
					byte.writeFloat(vert.y);
					byte.writeFloat(vert.z);
				}
			}
			
			for (i = 0; i < len; i++) {
				cell = navmesh.cells[i];
				
				// 写三角形索引
				for (j = 0; j < 3; j++) {
					var adj : NavigationCell = cell.link[j];
					byte.writeInt(navmesh.cells.indexOf(adj));
				}
			}
			
			byte.compress();
			return byte;
		}
	}
	
}
