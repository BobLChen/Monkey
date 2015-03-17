package monkey.core.utils {
	
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Bounds3D;
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.renderer.SkeletonRenderer;

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
		public static function readMesh(bytes : ByteArray) : Object3D {
			
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.uncompress();
			
			var obj3d: Object3D = new Object3D();
			var mesh : Mesh3D   = new Mesh3D([]);
			var anim : Boolean  = false;
			// 读取Mesh名称
			var size : int = bytes.readInt();
			obj3d.name = bytes.readUTFBytes(size);
			// 读取坐标
			var vec : Vector3D = new Vector3D();
			for (var j:int = 0; j < 3; j++) { 
				vec.x = bytes.readFloat();		 		
				vec.y = bytes.readFloat();	 
				vec.z = bytes.readFloat();	 
				vec.w = bytes.readFloat();	 
				obj3d.transform.local.copyRowFrom(j, vec);
			}
			// 读取SubMesh数量
			var subCount : int = bytes.readInt();
			for (var subIdx : int = 0; subIdx < subCount; subIdx++) {
				// 读取顶点长度
				var len : int = bytes.readInt();
				var vertBytes : ByteArray = new ByteArray();
				vertBytes.endian = Endian.LITTLE_ENDIAN;
				bytes.readBytes(vertBytes, 0, len * 12);
				// 顶点geometry
				var surface : Surface3D = new Surface3D();
				surface.indexVector = new Vector.<uint>();
				surface.setVertexBytes(Surface3D.POSITION, vertBytes, 3);
				// 构建索引
				for (var i:int = 0; i < len; i++) {
					surface.indexVector.push(i);
				}
				// uv0
				len = bytes.readInt();
				if (len > 0) {
					var uv0Bytes : ByteArray = new ByteArray();
					uv0Bytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(uv0Bytes, 0, len * 8);
					surface.setVertexBytes(Surface3D.UV0, uv0Bytes, 2);
				}
				// uv1
				len = bytes.readInt();
				if (len > 0) {
					var uv1Bytes : ByteArray = new ByteArray();
					uv1Bytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(uv1Bytes, 0, len * 8);
					surface.setVertexBytes(Surface3D.UV1, uv1Bytes, 2);
				}
				// normal
				len = bytes.readInt();
				if (len > 0) {
					var normalBytes : ByteArray = new ByteArray();  
					normalBytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(normalBytes, 0, len * 12);
					surface.setVertexBytes(Surface3D.NORMAL, normalBytes, 3);
				}
				// tangent
				len = bytes.readInt();
				if (len > 0) {
					var tanBytes : ByteArray = new ByteArray();
					tanBytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(tanBytes, 0, len * 12);
					surface.setVertexBytes(Surface3D.TANGENT, tanBytes, 3);
				}
				// 权重数据
				len = bytes.readInt();
				if (len > 0) {
					anim = true;
					var weightBytes : ByteArray = new ByteArray();
					weightBytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(weightBytes, 0, len * 16);
					surface.setVertexBytes(Surface3D.SKIN_WEIGHTS, weightBytes, 4);
				}
				// 骨骼索引
				len = bytes.readInt();
				if (len > 0) {
					anim = true;
					var indicesBytes : ByteArray = new ByteArray();
					indicesBytes.endian = Endian.LITTLE_ENDIAN;
					bytes.readBytes(indicesBytes, 0, len * 16);
					surface.setVertexBytes(Surface3D.SKIN_INDICES, indicesBytes, 4);
				}
				mesh.surfaces.push(surface);
			}
						
			var bounds : Bounds3D = new Bounds3D();
			bounds.min.x = bytes.readFloat();
			bounds.min.y = bytes.readFloat();
			bounds.min.z = bytes.readFloat();
			bounds.max.x = bytes.readFloat();
			bounds.max.y = bytes.readFloat();
			bounds.max.z = bytes.readFloat();
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
			mesh.bounds = bounds;
			
			if (anim) {
				obj3d.addComponent(new SkeletonRenderer(mesh, null));
			} else {
				obj3d.addComponent(new MeshRenderer(mesh, null));
			}
						
			return obj3d;
		}
		
	}
}
