package monkey.core.shader.filters {
	
	import flash.utils.ByteArray;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.utils.Device3D;

	/**
	 * 3x4矩阵骨骼动画 
	 * @author Neil
	 * 
	 */	
	public class SkeletonFilter34 extends Filter3D {
		
		private var boneLabel : VcRegisterLabel;
		
		public function SkeletonFilter34() {
			super("SkeletonFilter34");
			this.priority = 1000;
			this.boneLabel = new VcRegisterLabel(null);
		}
		
		/**
		 * 骨骼数据 
		 * @param bytes
		 * 
		 */		
		public function set boneData(bytes : ByteArray) : void {
			this.boneLabel.bytes = bytes;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			// 骨骼索引
			var idxVa : ShaderRegisterElement = regCache.getVa(Surface3D.SKIN_INDICES);
			// 骨骼权重
			var weiVa : ShaderRegisterElement = regCache.getVa(Surface3D.SKIN_WEIGHTS);
			// 申请108个vc寄存器->36 * 3
			var bones : ShaderRegisterElement = regCache.getVc(Device3D.MAX_MATRIX34_BONE * 3, boneLabel);
			// 临时变量
			var vt0   : ShaderRegisterElement = regCache.getVt();
			var vt1   : ShaderRegisterElement = regCache.getVt();
			
			var indices : Array = [
				idxVa + ".x",
				idxVa + ".y",
				idxVa + ".z",
				idxVa + ".w"
			];
			
			var weights : Array = [
				weiVa + ".x",
				weiVa + ".y",
				weiVa + ".z",
				weiVa + ".w"
			];
			
			var code : String = '';
			
			if (agal) {
				var useNormal : Boolean = regCache.useNormal();
				// 对op赋值为0
				code += 'mov ' + regCache.op + '.xyz, ' + regCache.vc0123 + '.xxx \n';
				if (useNormal) {
					code += 'mov ' + vt1 + ', ' + regCache.op + ' \n';
				}
				// 遍历四个骨骼索引以及权重
				for (var i:int = 0; i < 4; i++) {
					// 乘以骨骼
					code += 'm34 ' + vt0 + '.xyz, ' +  regCache.getVa(Surface3D.POSITION) + ', ' + 'vc[' + indices[i] + "+" + bones.index + '].xyzw \n';
					// 乘以权重
					code += 'mul ' + vt0 + '.xyz, ' + vt0 + '.xyz, ' + weights[i] + ' \n';
					// add
					code += 'add ' + regCache.op + '.xyz, ' + regCache.op + '.xyz, ' + vt0 + '.xyz \n';
					// 法线
					if (useNormal) {
						// 乘以骨骼
						code += 'm33 ' + vt0 + '.xyz, ' +  regCache.getVa(Surface3D.NORMAL) + ', ' + 'vc[' + indices[i] + "+" + bones.index + '].xyzw \n';
						// 乘以权重
						code += 'mul ' + vt0 + '.xyz, ' + vt0 + '.xyz, ' + weights[i] + ' \n';
						// add
						code += 'add ' + vt1 + '.xyz, ' + vt1 + '.xyz, ' + vt0 + '.xyz \n';
					}
				}
				if (useNormal) {
					code += 'nrm ' + vt1 + '.xyz, ' + vt1 + '.xyz \n';
					code += 'm33 ' + regCache.getV(Surface3D.NORMAL) + '.xyz, ' + vt1 + '.xyz, ' + regCache.vcWorld + ' \n';
				}
			}
			
			regCache.removeVt(vt1);
			regCache.removeFt(vt0);
			return code;
		}
			
		
	}
}
