package monkey.core.animator {
	
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import monkey.core.base.Bone3D;
	import monkey.core.base.Ref;
	import monkey.core.interfaces.IComponent;

	public class SkeletonAnimator extends Animator {
		
		/** 是否为四元数骨骼 */
		public var quat 		: Boolean;
		/** 骨骼数目 */
		public var boneNum 		: Vector.<int>;
		/** 骨骼数据 */
		private var _skinData 	: Array;
		/** 挂节点 */
		private var mounts 		: Dictionary;
		private var _rootBone	: Bone3D;
		private var _ref 		: Ref;
		
		public function SkeletonAnimator() {
			super();
			this._ref 			= new Ref();
			this._skinData		= new Array();
			this._rootBone		= new Bone3D();
			this.boneNum		= new Vector.<int>();
			this.mounts			= new Dictionary();
			this.rootBone.name 	= "RootBone";
		}
		
		override public function clone():IComponent {
			var c : SkeletonAnimator = new SkeletonAnimator();
			c.copyFrom(this);
			c.mounts 	= mounts;
			c.boneNum 	= boneNum;
			c.quat 		= quat;
			c._rootBone = rootBone;
			c._skinData = this._skinData;
			c._ref 		= this._ref;
			this._ref.ref++;
			return c;
		}
		
		override public function dispose(force : Boolean = false):void {
			this._disposed = true;
			if (this._disposed) {
				return;
			}
			if (this._ref.ref > 0 && !force) {
				this._ref.ref--;
				this._disposed = true;
				return;
			}
			this._disposed = true;
			// 释放骨骼数据
			for each (var datas : Array in this._skinData) {
				for each (var bytes : ByteArray in datas) {
					bytes.clear();
				}
			}
		}
		
		override public function append(anim:Animator):void {
			var ske : SkeletonAnimator = anim as SkeletonAnimator;
			for (var si : int = 0; si < ske._skinData.length; si++) {
				for (var fi : int = 0; fi < ske._skinData[si].length; fi++) {
					this.addBoneBytes(si, this._totalFrames + fi, ske.getBoneBytes(si, fi));
				}
			}
			for (var name : String in ske.mountDatas) {
				var datas : Array = ske.mountDatas[name];
				for (var i:int = 0; i < datas.length; i++) {
					this.addMount(name, i, datas[i]);
				}
			}
			for (name in anim.labels) {
				var label : Label3D = anim.labels[name];
				this.labels[name] = new Label3D(name, label.from + totalFrames, label.to + totalFrames, label.speed);
			}
			this._totalFrames += anim.totalFrames;
		}
		
		/** 骨骼 */
		public function get rootBone():Bone3D {
			return _rootBone;
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
		 * 添加骨骼数据 
		 * @param i			surf索引
		 * @param frame		帧索引
		 * @param bytes		骨骼数据
		 * 
		 */		
		public function addBoneBytes(i : int, frame : int, bytes : ByteArray) : void {
			if (!_skinData[i]) {
				_skinData[i] = [];
			}
			_skinData[i][frame] = bytes;
		}
		
		/**
		 * 获取骨骼数据 
		 * @param i			surface索引
		 * @param frame		帧数
		 * @return 
		 * 
		 */		
		public function getBoneBytes(i : int, frame : int) : ByteArray {
			return _skinData[i][frame];
		}
		
	}
}
