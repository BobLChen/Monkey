package monkey.core.utils {
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;

	public class Zip {
		
		private var _dict : Dictionary;
				
		public function Zip() {
			this._dict = new Dictionary();
		}
		
		public function loadBytes(bytes : ByteArray) : void {
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.uncompress();
			while (bytes.bytesAvailable > 0) {
				// read name size
				var size : uint = bytes.readInt();		
				// read name
				var name : String = bytes.readUTFBytes(size);
				// read data size
				size = bytes.readUnsignedInt(); 
				// read data
				var data : ByteArray = new ByteArray();
				data.endian = Endian.LITTLE_ENDIAN;
				bytes.readBytes(data, 0, size);
				this._dict[name] = data;
			}
		}
		
		public function getFileByName(name : String) : ByteArray {
			return _dict[name];
		}
		
		public function addFile(name : String, data : ByteArray) : void {
			if (_dict[name])
				return;
			this._dict[name] = data;
		}
		
		public function addString(name : String, data : String) : void {
			if (_dict[name])
				return;
			var byte : ByteArray = new ByteArray();
			byte.endian = Endian.LITTLE_ENDIAN;
			byte.writeUTFBytes(data);
			this._dict[name] = byte;
		}
		
		public function serialize(output : ByteArray) : void {
			output.endian = Endian.LITTLE_ENDIAN;
			for (var name : String in _dict) {
				var data : ByteArray = _dict[name];
				var nameBytes : ByteArray = new ByteArray();
				nameBytes.writeUTFBytes(name);
				// write name size
				output.writeInt(nameBytes.length);
				// write name
				output.writeUTFBytes(name);
				// write data size
				output.writeUnsignedInt(data.length);
				// write data
				output.writeBytes(data, 0, data.length);
			}
			output.compress();
		}
		
	}
}
