package ide.utils {
	
	import com.adobe.images.PNGEncoder;
	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.entities.SkyBox;
	import monkey.core.entities.Water3D;
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
		 * 导出water, 只适用于IDE
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
