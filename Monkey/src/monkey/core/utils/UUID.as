package monkey.core.utils {

	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;

	public class UUID {

		private static const ALPHA_CHAR_CODES : Array = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70];

		private static const buff : ByteArray = new ByteArray();
		private static const chars : Array = new Array(36);

		public static function generate() : String {
			var r : uint = uint(getTimer());
			buff.length = 0;
			buff.writeUnsignedInt(System.totalMemory ^ r);
			buff.writeInt(getTimer() ^ r);
			buff.writeDouble(Math.random() * r);
			buff.position = 0;
			var index : uint = 0;
			for (var i : uint = 0; i < 16; i++) {
				if (i == 4 || i == 6 || i == 8 || i == 10) {
					chars[index++] = 45; // Hyphen char code
				}
				var b : int = buff.readByte();
				chars[index++] = ALPHA_CHAR_CODES[(b & 0xF0) >>> 4];
				chars[index++] = ALPHA_CHAR_CODES[(b & 0x0F)];
			}
			return String.fromCharCode.apply(null, chars);
		}

	}
}
