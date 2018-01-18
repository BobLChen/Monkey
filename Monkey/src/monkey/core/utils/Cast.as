package monkey.core.utils {
	
	import flash.utils.ByteArray;

	public class Cast {
		
		public static function byteToString(bytes : ByteArray) : String {
			return bytes.readUTFBytes(bytes.length);
		}
		
	}
}
