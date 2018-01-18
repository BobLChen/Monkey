package ide.utils {
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import L3D.core.base.Geometry3D;
	import L3D.core.base.Pivot3D;
	import L3D.core.entities.Mesh3D;
	
	import deng.fzip.FZip;
	
	/**
	 * 导出3d模型->obj模型。 
	 * @author neil
	 * 
	 */	
	public class OBJUtils {
		
		public function OBJUtils() {
		
		}
		
		/**
		 * 生成obj格式文件 
		 * @param pivot
		 * @return 
		 * 
		 */		
		public static function GenerateOBJ(pivot : Pivot3D) : ByteArray {
			
			var zip : FZip = new FZip();
			
			var meshs : Vector.<Mesh3D> = new Vector.<Mesh3D>();
			if (pivot is Mesh3D) {
				meshs.push(pivot as Mesh3D);
			}
			pivot.forEach(function(mesh:Mesh3D):void{
				meshs.push(mesh);
			}, Mesh3D);
			
			for each (var m : Mesh3D in meshs) {
				var idx : int = 0;
				for each (var geo : Geometry3D in m.geometries) {
					var obj : String = geoForObj(geo, m.name + idx + getTimer());
					zip.addFileFromString(m.name + idx + getTimer() + ".obj", obj);
					idx++;
				}
			}
						
			var bytes : ByteArray = new ByteArray();
			zip.serialize(bytes);
			return bytes;
		}
		
		private static function geoForObj(geo : Geometry3D, name : String) : String {
			
			var hasUV : Boolean = false;
			var hasNormal : Boolean = false;
			
			var uvGeometry : Geometry3D = null;
			var normalGeometry : Geometry3D = null;
			
			if (geo.offsets[Geometry3D.UV0] != -1 || geo.sources[Geometry3D.UV0] != null) {
				hasUV = true;
				if (geo.offsets[Geometry3D.UV0] != -1) {
					uvGeometry = geo;
				} else {
					uvGeometry = geo.sources[Geometry3D.UV0];
				}
			}
			
			if (geo.offsets[Geometry3D.NORMAL] != -1 || geo.sources[Geometry3D.NORMAL] != null) {
				hasNormal = true;
				if (geo.offsets[Geometry3D.NORMAL] != -1) {
					normalGeometry = geo;
				} else {
					normalGeometry = geo.sources[Geometry3D.NORMAL];
				}
			}
			
			var obj : String = "";
			// 写顶点数据
			var i : int = 0;
			var posOffset : int = geo.offsets[Geometry3D.POSITION];
			for (i = 0; i < geo.vertexVector.length; i += geo.sizePerVertex) {
				var v0 : Number = geo.vertexVector[i + posOffset + 0];
				var v1 : Number = geo.vertexVector[i + posOffset + 1];
				var v2 : Number = geo.vertexVector[i + posOffset + 2];
				obj += "v " + v0 + " " + v1 + " " + v2 + " \n";
			}
			// 写uv数据
			if (hasUV) {
				var uvOffset : int = uvGeometry.offsets[Geometry3D.UV0];
				for (i = 0; i < uvGeometry.vertexVector.length; i += uvGeometry.sizePerVertex) {
					var uv0 : Number = uvGeometry.vertexVector[i + uvOffset + 0];
					var uv1 : Number = uvGeometry.vertexVector[i + uvOffset + 1];
					obj += "vt " + uv0 + " " + (1 - uv1) + " \n";
				}
			}
			// 写法线数据
			if (hasNormal) {
				var normalOffset : int = normalGeometry.offsets[Geometry3D.NORMAL];
				for (i = 0; i < normalGeometry.vertexVector.length; i += normalGeometry.sizePerVertex) {
					var n0 : Number = normalGeometry.vertexVector[i + normalOffset + 0];
					var n1 : Number = normalGeometry.vertexVector[i + normalOffset + 1];
					var n2 : Number = normalGeometry.vertexVector[i + normalOffset + 2];
					obj += "vn " + n0 + " " + n1 + " " + n2 + " \n";
				}
			}
			// 写顶点数据
			obj += "g " + name + "\n";
			// f 1/2/3 1/2/3 1/2/3
			// 1:顶点索引 2:uv索引 3:法线索引
			for (i = 0; i < geo.indexVector.length; i += 3) {
				obj += "f ";
				// obj索引从1开始。
				var i0 : int = geo.indexVector[i] + 1;
				var i1 : int = geo.indexVector[i + 1] + 1;
				var i2 : int = geo.indexVector[i + 2] + 1;
				
				// f 1/2/3
				obj += "" + i0;
				if (hasUV) {
					obj += "/" + i0;
				} else {
					obj += "/";
				}
				if (hasNormal) {
					obj += "/" + i0;
				} else {
					obj += "/";
				}
				obj += " ";
				// 
				obj += "" + i1;
				if (hasUV) {
					obj += "/" + i1;
				} else {
					obj += "/";
				}
				if (hasNormal) {
					obj += "/" + i1;
				} else {
					obj += "/";
				}
				obj += " ";
				// 
				obj += "" + i2;
				if (hasUV) {
					obj += "/" + i2;
				} else {
					obj += "/";
				}
				if (hasNormal) {
					obj += "/" + i2;
				} else {
					obj += "/";
				}
				obj += "\n";
			}
			
			return obj;
		}
		
	}
}
