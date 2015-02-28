package monkey.core.shader.filters {
	
	import flash.utils.ByteArray;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;

	/**
	 * 3x4骨骼动画 
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
		
		public function set data(bytes : ByteArray) : void {
			this.boneLabel.bytes = bytes;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			// 骨骼索引
			var idxVa : ShaderRegisterElement = regCache.getVa(Surface3D.SKIN_INDICES);
			// 骨骼权重
			var weiVa : ShaderRegisterElement = regCache.getVa(Surface3D.SKIN_WEIGHTS);
			// 顶点数据
			var posVa : ShaderRegisterElement = regCache.getVa(Surface3D.POSITION);
			// 申请108个vc寄存器->36 * 3
			var bones : ShaderRegisterElement = regCache.getVc(108, boneLabel);
			// 临时变量
			var vt0   : ShaderRegisterElement = regCache.getVt();
			
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
				// 对op赋值为0
				code += 'mov ' + regCache.op + '.xyz, ' + regCache.vc0123 + '.xxx \n';
				// 遍历四个骨骼索引以及权重
				for (var i:int = 0; i < 4; i++) {
					// 乘以骨骼
					code += 'm34 ' + vt0 + '.xyz, ' + posVa + ', ' + 'vc[' + indices[i] + "+" + bones.index + '].xyzw \n';
					// 乘以权重
					code += 'mul ' + vt0 + '.xyz, ' + vt0 + '.xyz, ' + weights[i] + ' \n';
					// add
					code += 'add ' + regCache.op + '.xyz, ' + regCache.op + '.xyz, ' + vt0 + '.xyz \n';
				}
			}
			
			regCache.removeFt(vt0);
			return code;
		}
			
		
	}
}
