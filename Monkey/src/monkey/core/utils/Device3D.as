package monkey.core.utils {
	
	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	
	import monkey.core.camera.Camera3D;
	import monkey.core.scene.Scene3D;

	/**
	 * 3d设备 
	 * @author Neil
	 * 
	 */	
	public class Device3D {
		
		/** 开启debug日志 */
		public static var debug 				: Boolean = true;
		/** gpu模式 */
		public static var profile 				: String = Context3DProfile.BASELINE;
		/** scene3d */
		public static var scene 				: Scene3D;
		/** drawcall次数 */		
		public static var drawCalls  			: int = 0;
		/** 三角形数量 */
		public static var triangles 			: int = 0;
		/** 3d对象数量 */
		public static var drawOBJNum					: int = 0;
		/** 相机 */
		public static var camera				: Camera3D;
		/** 投影 */
		public static const proj				: Matrix3D = new Matrix3D();
		/** view */
		public static const view				: Matrix3D = new Matrix3D();
		/** mvp */
		public static const mvp					: Matrix3D = new Matrix3D();
		/** world */
		public static const world				: Matrix3D = new Matrix3D();
		
		/** view projection */		
		public static var viewProjection 		: Matrix3D = new Matrix3D();
		/** 默认混合模式 */
		public static var defaultSourceFactor	: String = Context3DBlendFactor.ONE;
		/** 默认混合模式 */
		public static var defaultDestFactor 	: String = Context3DBlendFactor.ZERO;
		/** 默认裁减 */
		public static var defaultCullFace 		: String = Context3DTriangleFace.BACK;
		/** 默认深度测试 */
		public static var defaultDepthWrite		: Boolean = true;
		/** 默认深度测试条件 */
		public static var defaultCompare		: String = Context3DCompareMode.LESS_EQUAL;
		
		/** 最大贴图尺寸 */
		public static const MAX_TEXTURE_SIZE    : int = 2048;
			
		// 默认贴图
		private static var _nullBitmapData 		: BitmapData;
		
		/**
		 * 黑白格子bitmapdata 
		 * @return 
		 * 
		 */		
		public static function get nullBitmapData() : BitmapData {
			if (_nullBitmapData) {
				return _nullBitmapData;
			}
			_nullBitmapData = new BitmapData(64, 64, false, 0xFF0000);
			var h : int = 0;
			var v : int = 0;
			while (h < 8) {
				v = 0;
				while (v < 8) {
					_nullBitmapData.fillRect(new Rectangle(h * 8, v * 8, 8, 8), (((h % 2 + v % 2) % 2) == 0) ? 0xFFFFFF : 0xB0B0B0);
					v++;
				}
				h++;
			}
			return _nullBitmapData;
		}
		
		public function Device3D() {
			
		}
		
	}
}
