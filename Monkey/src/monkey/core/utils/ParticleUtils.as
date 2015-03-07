package monkey.core.utils {
	
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.entities.particles.ParticleSystem;

	public class ParticleUtils {
		
		
		/**
		 * 粒子系统运行期关键帧数据生成器 
		 * @param maxLifetime	最大生命周期时间
		 * @param speedX		x轴速度关键帧
		 * @param speedY		y轴速度关键帧
		 * @param speedZ		z轴速度关键帧
		 * @param rotX			x轴旋转关键帧
		 * @param rotY			y轴旋转关键帧
		 * @param rotZ			z轴旋转关键帧
		 * @param size			尺寸关键帧
		 * @return 
		 * 
		 */		
		public static function GeneratelifetimeBytes(maxLifetime : Number, speedX : Linears, speedY : Linears, speedZ : Linears, rotX : Linears, rotY : Linears, rotZ : Linears, size : Linears) : ByteArray {
			const KEY_SIZE : int = ParticleSystem.MAX_KEY_NUM;
			var bytes  : ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			var matrix : Matrix3D = new Matrix3D();
			var datas  : Vector.<Number> = new Vector.<Number>(16 * 11, true);
			var retX   : Number = 0;
			var retY   : Number = 0;
			var retZ   : Number = 0;
			var step   : Number = 1 / (KEY_SIZE - 1);
			var t	   : Number = maxLifetime / (KEY_SIZE - 1);			
			for (var i : int = 0; i < KEY_SIZE; i++) {
				matrix.identity();
				Matrix3DUtils.setScale(matrix, size.getY(i * step), size.getY(i * step), size.getY(i * step));			// 缩放
				Matrix3DUtils.setRotation(matrix, rotX.getY(i * step), rotY.getY(i * step), rotZ.getY(i * step));		// 旋转
				// 转置矩阵，因为默认上传至GPU时会转置矩阵
				matrix.transpose();
				for (var j:int = 0; j < 16; j++) {
					datas[16 * i + j] = matrix.rawData[j];
				}
				// 根据变速直线公式计算出位移
				var x : Number = uniformly(speedX.getY(step * i), speedX.getY(step * i + step), t);
				var y : Number = uniformly(speedY.getY(step * i), speedY.getY(step * i + step), t);
				var z : Number = uniformly(speedZ.getY(step * i), speedZ.getY(step * i + step), t);
				// 存储位移到关键帧				
				datas[16 * i + 12] = retX;			// x轴位移
				datas[16 * i + 13] = retY;			// y轴位移
				datas[16 * i + 14] = retZ;			// z轴位移
				datas[16 * i + 15] = maxLifetime;	// 最大生命周期
				// 叠加位移
				retX += x;
				retY += y;
				retZ += z;
			}
			for (var k:int = 0; k < 176; k++) {
				bytes.writeFloat(datas[k]);
			}
			return bytes;
		}
		
		private static function uniformly(v0 : Number, vt : Number, t : Number) : Number {
			var a : Number = (vt - v0) / t;
			var s : Number = v0 * t + 0.5 * a * t * t;
			return s;
		}
		
	}
}
