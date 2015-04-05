package monkey.core.utils {
	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;

	/**
	 * 模型工具 
	 * @author Neil
	 * 
	 */	
	public class Mesh3DUtils {
		
		public function Mesh3DUtils() {
			throw new Error("无法实例化MeshUtils");	
		}
		
		/**
		 * 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public static function readMesh(bytes : ByteArray) : Mesh3D {
			bytes.endian = Endian.LITTLE_ENDIAN;
			// 读取压缩格式
			var type : int = bytes.readInt();
			// 读取压缩前长度
			var size : int = bytes.readInt();
			// 解压
			var data : ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			bytes.readBytes(data, 0, bytes.bytesAvailable);
			
			data.uncompress();
			
			var mesh : Mesh3D   = new Mesh3D([]);
			var anim : Boolean  = false;
			// 读取Mesh名称
			size = data.readInt();
			var name : String = data.readUTFBytes(size);
			// 读取坐标
			var vec : Vector3D = new Vector3D();
			for (var j:int = 0; j < 3; j++) { 
				vec.x = data.readFloat();		 		
				vec.y = data.readFloat();	 
				vec.z = data.readFloat();	 
				vec.w = data.readFloat();	 
//				obj3d.transform.local.copyRowFrom(j, vec);
			}
			// 读取SubMesh数量
			var subCount : int = data.readInt();
			for (var subIdx : int = 0; subIdx < subCount; subIdx++) {
				// 读取顶点长度
				var len : int = data.readInt();
				var vertBytes : ByteArray = new ByteArray();
				vertBytes.endian = Endian.LITTLE_ENDIAN;
				data.readBytes(vertBytes, 0, len * 12);
				// 顶点geometry
				var surface : Surface3D = new Surface3D();
				surface.indexVector = new Vector.<uint>();
				surface.setVertexBytes(Surface3D.POSITION, vertBytes, 3);
				// uv0
				len = data.readInt();
				if (len > 0) {
					var uv0Bytes : ByteArray = new ByteArray();
					uv0Bytes.endian = Endian.LITTLE_ENDIAN;
					data.readBytes(uv0Bytes, 0, len * 8);
					surface.setVertexBytes(Surface3D.UV0, uv0Bytes, 2);
				}
				// uv1
				len = data.readInt();
				if (len > 0) {
					var uv1Bytes : ByteArray = new ByteArray();
					uv1Bytes.endian = Endian.LITTLE_ENDIAN;
					data.readBytes(uv1Bytes, 0, len * 8);
					surface.setVertexBytes(Surface3D.UV1, uv1Bytes, 2);
				}
				// normal
				len = data.readInt();
				if (len > 0) {
					var normalBytes : ByteArray = new ByteArray();  
					normalBytes.endian = Endian.LITTLE_ENDIAN;
					data.readBytes(normalBytes, 0, len * 12);
					surface.setVertexBytes(Surface3D.NORMAL, normalBytes, 3);
				}
				// tangent
				len = data.readInt();
				if (len > 0) {
					var tanBytes : ByteArray = new ByteArray();
					tanBytes.endian = Endian.LITTLE_ENDIAN;
					data.readBytes(tanBytes, 0, len * 12);
					surface.setVertexBytes(Surface3D.TANGENT, tanBytes, 3);
				}
				// 权重数据
				len = data.readInt();
				if (len > 0) {
					anim = true;
					var weightBytes : ByteArray = new ByteArray();
					weightBytes.endian = Endian.LITTLE_ENDIAN;
					data.readBytes(weightBytes, 0, len * 16);
					surface.setVertexBytes(Surface3D.SKIN_WEIGHTS, weightBytes, 4);
				}
				// 骨骼索引
				len = data.readInt();
				if (len > 0) {
					anim = true;
					var indicesBytes : ByteArray = new ByteArray();
					indicesBytes.endian = Endian.LITTLE_ENDIAN;
					data.readBytes(indicesBytes, 0, len * 16);
					surface.setVertexBytes(Surface3D.SKIN_INDICES, indicesBytes, 4);
				}
				// 索引
				len = data.readInt();
				if (len > 0) {
					for (var i:int = 0; i < len; i++) {
						surface.indexVector.push(data.readInt());
					}
				} else {
					len = surface.getVertexBytes(Surface3D.POSITION).length / 12;
					for (i = 0; i < len; i++) {
						surface.indexVector.push(i);
					}
				}
				mesh.surfaces.push(surface);
			}
			
			var bounds : Bounds3D = new Bounds3D();
			bounds.min.x = data.readFloat();
			bounds.min.y = data.readFloat();
			bounds.min.z = data.readFloat();
			bounds.max.x = data.readFloat();
			bounds.max.y = data.readFloat();
			bounds.max.z = data.readFloat();
			
			bounds.length.x = bounds.max.x - bounds.min.x;
			bounds.length.y = bounds.max.y - bounds.min.y;
			bounds.length.z = bounds.max.z - bounds.min.z;
			bounds.center.x = bounds.length.x * 0.5 + bounds.min.x;
			bounds.center.y = bounds.length.y * 0.5 + bounds.min.y;
			bounds.center.z = bounds.length.z * 0.5 + bounds.min.z;
			bounds.radius = Vector3D.distance(bounds.center, bounds.max);
			
			for each (var surf : Surface3D in mesh.surfaces) {
				surf.bounds = bounds;
			}
			mesh.bounds   = bounds;
			mesh.skeleton = anim;
			
			data.clear();
			
			return mesh;
		}
		
	}
}
