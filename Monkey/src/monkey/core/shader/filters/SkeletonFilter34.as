package monkey.core.shader.filters {
	import flash.events.ShaderEvent;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;

	/**
	 * 3x4骨骼动画 
	 * @author Neil
	 * 
	 */	
	public class SkeletonFilter34 extends Filter3D {
		
		public function SkeletonFilter34() {
			super("SkeletonFilter34");
			this.priority = 1000;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			var idxVa : ShaderRegisterElement = regCache.getVa(Surface3D.SKIN_INDICES);
			var weiVa : ShaderRegisterElement = regCache.getVa(Surface3D.SKIN_WEIGHTS);
			var posVa : ShaderRegisterElement = regCache.getVa(Surface3D.POSITION);
			var vt0   : ShaderRegisterElement = regCache.getVt();
			var idx   : int = regCache.vcBone.index;
			var useNormal : Boolean = regCache.useNormal();
			
			var code : String = '';
			
			if (agal) {
				
				var vt1 : ShaderRegisterElement = null;
				var nrm : ShaderRegisterElement = null;
				if (useNormal) {
					vt1 = regCache.getVt();
					nrm = regCache.getVa(Surface3D.NORMAL);
					code += 'mov ' + vt1 + '.xyz, ' + regCache.vc0123 + '.xxx \n';
				}
				
				code += 'mov ' + regCache.op + '.xyz, ' + regCache.vc0123 + '.xxx \n';
				
				code += 'm34 ' + vt0 + '.xyz, ' + posVa + ', ' + 'vc[' + idxVa + '.x+' + idx + '].xyzw \n';
				code += 'mul ' + vt0 + '.xyz, ' + vt0 + '.xyz, ' + weiVa + '.xxx \n';
				code += 'add ' + regCache.op + '.xyz, ' + regCache.op + '.xyz, ' + vt0 + '.xyz \n';
				
				if (useNormal) {
					code += 'm33 ' + vt0 + '.xyz, ' + nrm + ', ' + 'vc[' + idxVa + '.x+' + idx + '].xyzw \n';
					code += 'add ' + vt1 + '.xyz, ' + vt1 + ', ' + vt0 + '.xyz \n';
				}
				
				code += 'm34 ' + vt0 + '.xyz, ' + posVa + ', ' + 'vc[' + idxVa + '.y+' + idx + '].xyzw \n';
				code += 'mul ' + vt0 + '.xyz, ' + vt0 + '.xyz, ' + weiVa + '.yyy \n';
				code += 'add ' + regCache.op + '.xyz, ' + regCache.op + '.xyz, '+ vt0 + '.xyz \n';
				
				if (useNormal) {
					code += 'm33 ' + vt0 + '.xyz, ' + nrm + ', ' + 'vc[' + idxVa + '.x+' + idx + '].xyzw \n';
					code += 'add ' + vt1 + '.xyz, ' + vt1 + ', ' + vt0 + '.xyz \n';
				}
				
				code += 'm34 ' + vt0 + '.xyz, ' + posVa + ', ' + 'vc[' + idxVa + '.z+' + idx + '].xyzw \n';
				code += 'mul ' + vt0 + '.xyz, ' + vt0 + '.xyz, ' + weiVa + '.zzz \n';
				code += 'add ' + regCache.op + '.xyz, ' + regCache.op + '.xyz, ' + vt0 + '.xyz \n';
				
				if (useNormal) {
					code += 'm33 ' + vt0 + '.xyz, ' + nrm + ', ' + 'vc[' + idxVa + '.x+' + idx + '].xyzw \n';
					code += 'add ' + vt1 + '.xyz, ' + vt1 + ', ' + vt0 + '.xyz \n';
				}
				
				code += 'm34 ' + vt0 + '.xyz, ' + posVa + ', ' + 'vc[' + idxVa + '.w+' + idx + '].xyzw \n';
				code += 'mul ' + vt0 + '.xyz, ' + vt0 + '.xyz, ' + weiVa + '.www \n';
				code += 'add ' + regCache.op + '.xyz, ' + regCache.op + '.xyz, ' + vt0 + '.xyz \n';
				
				if (useNormal) {
					code += 'm33 ' + vt0 + '.xyz, ' + nrm + ', ' + 'vc[' + idxVa + '.x+' + idx + '].xyzw \n';
					code += 'add ' + vt1 + '.xyz, ' + vt1 + ', ' + vt0 + '.xyz \n';
				}
				
				if (useNormal) {
					regCache.removeVt(vt1);
				}
			}
			
			regCache.removeFt(vt0);
			return code;
		}
			
		
	}
}
