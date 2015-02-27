package monkey.core.parser {

	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Surface3D;

	public class NavMeshParser extends EventDispatcher {
		
		public static const PARSER_COMPLETED : String = 'PARSER_COMPLETED';

		public function NavMeshParser() {
			
		}
		
		public function parse(bytes : ByteArray) : Surface3D {
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.position = 0;
			
			var verts : Vector.<Number> = new Vector.<Number>();
			var indices : Vector.<uint> = new Vector.<uint>();
			var idx : uint = 0;
			
			while (bytes.bytesAvailable > 0) {
				verts.push(bytes.readFloat(), bytes.readFloat(), bytes.readFloat());
				indices.push(idx++);
			}
			
			var surf : Surface3D = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, verts, 3);
			surf.indexVector = indices;
			
			return surf;
		}
		
	}
}
