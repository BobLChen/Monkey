package ide.utils {
	
	import com.adobe.images.PNGEncoder;
	
	import flash.utils.ByteArray;
	
	import monkey.core.entities.SkyBox;
	import monkey.core.entities.Water3D;
	import monkey.core.utils.Texture3DUtils;
	import monkey.core.utils.Zip;
	
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
	}
	
}
