package monkey.core.animator {
	
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import monkey.core.base.Bone3D;
	import monkey.core.base.Ref;
	import monkey.core.interfaces.IComponent;

	public class SkeletonAnimator extends Animator {
		
		/** 骨骼 */
		public var rootBone		: Bone3D;
		/** 是否为四元数骨骼 */
		public var quat 		: Boolean;
		/** 骨骼数据 */
		public var skinData 	: Vector.<Array>;
		/** 骨骼数目 */
		public var skinBoneNum 	: Vector.<int>;
		/** 挂节点 */
		private var mounts 		: Dictionary;
		
		private var _ref 		: Ref;
		
		public function SkeletonAnimator() {
			super();
			this._ref 		= new Ref();
			this.rootBone	= new Bone3D();
			this.skinBoneNum= new Vector.<int>();
			this.skinData	= new Vector.<Array>();
			this.mounts		= new Dictionary();
			this.rootBone.name = "RootBone";
		}
		
		override public function clone():IComponent {
			var c : SkeletonAnimator = new SkeletonAnimator();
			c.copyFrom(this);
			c._ref = this._ref;
			this._ref.ref++;
			return c;
		}
		
		override public function dispose():void {
			this._disposed = true;
			if (this._disposed) {
				return;
			}
			if (this._ref.ref > 0) {
				this._ref.ref--;
				this._disposed = true;
				return;
			}
			this._disposed = true;
			// 释放骨骼数据
			for each (var datas : Array in skinData) {
				for each (var bytes : ByteArray in datas) {
					bytes.clear();
				}
			}
		}
				
		/**
		 * 浅复制
		 * @param animator
		 * 
		 */		
		override public function copyFrom(animator:Animator):void {
			super.copyFrom(animator);
			if (animator is SkeletonAnimator) {
				var ske : SkeletonAnimator = animator as SkeletonAnimator;
				this.quat 			= ske.quat;
				this.skinData 		= this.skinData;
				this.skinBoneNum 	= this.skinBoneNum;
				this.mounts			= this.mounts;
				
			}
		}
		
		/**
		 * 添加挂节点
		 * @param name 		骨骼名称
		 * @param frame		帧索引
		 * @param matrix	骨骼数据
		 *
		 */
		public function addMount(name : String, frame : int, matrix : Matrix3D) : void {
			if (!mounts[name]) {
				mounts[name] = new Array();
				var bone : Bone3D = new Bone3D();
				bone.name = name;
				this.rootBone.addChild(bone);
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
