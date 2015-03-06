package ide.plugins.groups.particles.lifetime {
	
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.utils.Curves;
	import monkey.core.utils.Matrix3DUtils;

	public class LifetimeData {
		
		public var speedX : Curves;
		public var speedY : Curves;
		public var speedZ : Curves;
		public var rotX   : Curves;
		public var rotY   : Curves;
		public var rotZ   : Curves;
		public var size   : Curves;
		
		public function LifetimeData() {
			
		}
		
		public function generate() : ByteArray {
			var bytes  : ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			var matrix : Matrix3D = new Matrix3D();
			var datas  : Vector.<Number> = new Vector.<Number>(16 * 11, true);
			for (var i:int = 0; i < 11; i++) {
				var tx : Number = speedX.getY(i * 0.1);
				var ty : Number = speedY.getY(i * 0.1);
				var tz : Number = speedZ.getY(i * 0.1);
				var rx : Number = rotX.getY(i * 0.1);
				var ry : Number = rotY.getY(i * 0.1);
				var rz : Number = rotZ.getY(i * 0.1);
				var sx : Number = size.getY(i * 0.1);
								
				matrix.identity();
				Matrix3DUtils.setScale(matrix, sx, sx, sx);			// 缩放
				Matrix3DUtils.setRotation(matrix, rx, ry, rz);		// 旋转
				matrix.transpose();									// 转置
				for (var j:int = 0; j < 16; j++) {
					datas[16 * i + j] = matrix.rawData[j];
				}
				datas[16 * i + 12] = tx;							// x轴速度
				datas[16 * i + 13] = ty;							// y轴速度
				datas[16 * i + 14] = tz;							// z轴速度
			}
			for (var k:int = 0; k < 176; k++) {
				bytes.writeFloat(datas[k]);
			}
			return bytes;
		}
	}
}
