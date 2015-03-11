package monkey.core.utils {
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import monkey.core.camera.Camera3D;
	import monkey.core.light.DirectionalLight;
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
		public static var drawOBJNum			: int = 0;
		/** 相机 */
		public static var camera				: Camera3D;
		
		/** 最大矩阵骨骼数 */
		public static const MAX_MATRIX34_BONE   : int = 36;
		/** 最大四元数骨骼数 */
		public static const MAX_QUAT_BONE		: int = 56;
		
		/** 默认灯光 */
		public static const defaultDirectLight  : DirectionalLight = new DirectionalLight();
		/** 投影 */
		public static const proj				: Matrix3D = new Matrix3D();
		/** view */
		public static const view				: Matrix3D = new Matrix3D();
		/** mvp */
		public static const mvp					: Matrix3D = new Matrix3D();
		/** world */
		public static const world				: Matrix3D = new Matrix3D();
		/** 相机坐标 */
		public static const cameraPos			: Vector3D = new Vector3D();
		/** 相机方向 */
		public static const cameraDir			: Vector3D = new Vector3D();
		
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
					
		public function Device3D() {
			
		}
		
	}
}
