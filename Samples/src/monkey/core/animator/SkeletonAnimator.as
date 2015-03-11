package monkey.core.animator {
	
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class SkeletonAnimator extends Animator {
		
		/** 是否为四元数骨骼 */
		public var quat 		: Boolean;
		/** 骨骼数据 */
		public var skinData 	: Vector.<Array>;
		/** 骨骼数目 */
		public var skinBoneNum 	: Vector.<int>;
		/** 挂节点 */
		private var mounts 		: Dictionary;
		
		public function SkeletonAnimator() {
			super();
			this.skinBoneNum= new Vector.<int>();
			this.skinData	= new Vector.<Array>();
			this.mounts		= new Dictionary();
		}
		
		/**
		 * 添加挂节点
		 * @param name 		骨骼名称
		 * @param frame		帧索引
		 * @param matrix		骨骼数据
		 *
		 */
		public function addMount(name : String, frame : int, matrix : Matrix3D) : void {
			if (!mounts[name]) {
				mounts[name] = new Array();
			}
			mounts[name][frame] = matrix;
		}
		
		/**
		 * 挂节点数据 
		 * @return 
		 * 
		 */		
		public function get mountDatas() : Dictionary {
			return mounts;
		}
		
		/**
		 * 获取挂节点数据 
		 * @param name		骨骼名称
		 * @param frame		帧数
		 * @return 
		 * 
		 */		
		public function getMountMatrix(name : String, frame : int) : Matrix3D {
			return mounts[name][frame];
		}
		
		/**
		 * 获取骨骼数据 
		 * @param i			surface索引
		 * @param frame		帧数
		 * @return 
		 * 
		 */		
		public function getBoneBytes(i : int, frame : int) : ByteArray {
			return skinData[i][frame];
		}
		
	}
}
