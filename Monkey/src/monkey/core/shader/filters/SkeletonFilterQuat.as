package monkey.core.shader.filters {
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.utils.Device3D;
	
	/**
	 * 四元数骨骼 
	 * @author Neil
	 * 
	 */	
	public class SkeletonFilterQuat extends Filter3D {
		
		private var boneLabel : VcRegisterLabel;
		
		public function SkeletonFilterQuat() {
			super("SkeletonFilterQuat");
			this.priority = 1000;
			this.boneLabel = new VcRegisterLabel(null);
		}
		
		override public function getVertexCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			
			// 56 * 2
			var bones : ShaderRegisterElement = regCache.getVc(Device3D.MAX_QUAT_BONE * 2, boneLabel);
			var vc123 : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(Vector.<Number>([1, 0, 0, bones.index])));
			var useNormal : Boolean = regCache.useNormal();
			
			var indexVa : Vector.<String> = Vector.<String>([
				regCache.getVa(Surface3D.SKIN_INDICES) + '.x', 
				regCache.getVa(Surface3D.SKIN_INDICES) + '.y', 
				regCache.getVa(Surface3D.SKIN_INDICES) + '.z', 
				regCache.getVa(Surface3D.SKIN_INDICES) + '.w'
			]);
			var weightVa : Vector.<String> = Vector.<String>([
				regCache.getVa(Surface3D.SKIN_WEIGHTS) + '.x', 
				regCache.getVa(Surface3D.SKIN_WEIGHTS) + '.y', 
				regCache.getVa(Surface3D.SKIN_WEIGHTS) + '.z', 
				regCache.getVa(Surface3D.SKIN_WEIGHTS) + '.w'
			]);
			
			var vt0 : ShaderRegisterElement = regCache.getVt();
			var vt1 : ShaderRegisterElement = regCache.getVt();
			var vt3 : ShaderRegisterElement = regCache.getVt();
			var vt4 : ShaderRegisterElement = regCache.getVt();
			var vt5 : ShaderRegisterElement = regCache.getVt();
			
			var nrm : ShaderRegisterElement = null;
			var res : ShaderRegisterElement = null;
			
			if (useNormal) {
				nrm = regCache.getVt();
				res = regCache.getVt();
			}
			
			var vertexCode : String = '';
			
			for (var i : int = 0; i < 4; i++) {
				// 申请vt0
				// 取出位移信息vt0
				// 获取vc骨骼位置偏移量
				vertexCode += 'add ' + vt1 + '.x, ' + indexVa[i] + ', ' + vc123 + '.w \n';
				// 取出四元数 vt1 = 四元数
				vertexCode += 'mov ' + vt1 + ', vc[' + vt1 + '.x' + '+1] \n';
				// 将四元数转化为matrix3x3
				// [ 1-2yy-2zz , 2xy-2wz , 2xz+2wy ]
				// [ 2xy+2wz , 1-2xx-2zz , 2yz-2wx ]
				// [ 2xz-2wy , 2yz+2wx , 1-2xx-2yy ]
				// 计算2x 2y 2z
				// vt2 = 2x, 2y, 2z, w
				vertexCode += 'add ' + vt0 + '.xyz, ' + vt1 + '.xyz, ' + vt1 + '.xyz \n';
				// 计算vt3 = 2xw 2yw 2zw
				vertexCode += 'mul ' + vt3 + '.xyz, ' + vt0 + '.xyz, ' + vt1 + '.w \n';
				// 计算vt4 = 2xx 2yx 2zx
				vertexCode += 'mul ' + vt4 + '.xyz, ' + vt0 + '.xyz, ' + vt1 + '.x \n';
				// 计算vt5 = 2yy 2zy 2zz
				vertexCode += 'mul ' + vt5 + '.xyz, ' + vt0 + '.yyz, ' + vt1 + '.yzz \n';
				vertexCode += 'add ' + vt0 + '.x, ' + indexVa[i] + ', ' + vc123 + '.w \n';
				vertexCode += 'mov ' + vt0 + ', vc[' + vt0 + '.x' + '] \n';
				
				// vt1 -> 计算[1-2yy-2zz , 2xy-2wz , 2xz+2wy]
				// vt1.x = 2yy+2zz
				vertexCode += 'add ' + vt1 + '.x, ' + vt5 + '.x, ' + vt5 + '.z \n';
				// vt1.x = 1 - 2yy - 2zz
				vertexCode += 'sub ' + vt1 + '.x, ' + vc123 + '.x, ' + vt1 + '.x \n';
				// vt1.y = 2xy - 2wz
				vertexCode += 'sub ' + vt1 + '.y, ' + vt4 + '.y, ' + vt3 + '.z \n';
				// vt1.z = 2xz + 2wy
				vertexCode += 'add ' + vt1 + '.z, ' + vt4 + '.z, ' + vt3 + '.y \n';
				// 顶点
				vertexCode += 'mov ' + vt1 + '.w, ' + vt0 + '.x \n';
				vertexCode += 'dp4 ' + vt0 + '.x, ' + regCache.getVa(Surface3D.POSITION) + ', ' + vt1 + ' \n';
				// 法线
				if (useNormal) {
					vertexCode += 'dp3 ' + res + '.x, ' + regCache.getVa(Surface3D.NORMAL) + ', ' + vt1 + ' \n';
				}
				
				vertexCode += 'add ' + vt1 + '.x, ' + vt4 + '.y, ' + vt3 + '.z \n';
				// vt1.y = 2xx + 2zz
				vertexCode += 'add ' + vt1 + '.y, ' + vt4 + '.x, ' + vt5 + '.z \n';
				// vt1.y = 1-2xx-2zz
				vertexCode += 'sub ' + vt1 + '.y, ' + vc123 + '.x, ' + vt1 + '.y \n';
				// vt1.z = 2yz-2wx
				vertexCode += 'sub ' + vt1 + '.z, ' + vt5 + '.y, ' + vt3 + '.x \n';
				// 计算顶点
				vertexCode += 'mov ' + vt1 + '.w, ' + vt0 + '.y \n';
				vertexCode += 'dp4 ' + vt0 + '.y, ' + regCache.getVa(Surface3D.POSITION) + ', ' + vt1 + ' \n';
				// 法线
				if (useNormal) {
					vertexCode += 'dp3 ' + res + '.y, ' + regCache.getVa(Surface3D.NORMAL) + ', ' + vt1 + ' \n';
				}
				
				vertexCode += 'sub ' + vt1 + '.x, ' + vt4 + '.z, ' + vt3 + '.y \n';
				// vt1.y = 2yz + 2wx
				vertexCode += 'add ' + vt1 + '.y, ' + vt5 + '.y, ' + vt3 + '.x \n';
				// vt1.z = 2xx + 2yy
				vertexCode += 'add ' + vt1 + '.z, ' + vt4 + '.x, ' + vt5 + '.x \n';
				// vt1.z = 1 - 2xx - 2yy
				vertexCode += 'sub ' + vt1 + '.z, ' + vc123 + '.x, ' + vt1 + '.z \n';
				// 计算顶点
				vertexCode += 'mov ' + vt1 + '.w, ' + vt0 + '.z \n';
				vertexCode += 'dp4 ' + vt0 + '.z, ' + regCache.getVa(Surface3D.POSITION) + ', ' + vt1 + ' \n';
				// 法线
				if (useNormal) {
					vertexCode += 'dp3 ' + res + '.z, ' + regCache.getVa(Surface3D.NORMAL) + ', ' + vt1 + ' \n';
				}
				
				vertexCode += 'mov ' + vt0 + '.w, ' + regCache.getVa(Surface3D.POSITION) + '.w \n';
				vertexCode += 'mul ' + vt0 + ', ' + vt0 + ', ' + weightVa[i] + ' \n';
				
				if (useNormal) {
					vertexCode += 'mul ' + res + '.xyz, ' + res + '.xyz, ' + weightVa[i] + ' \n';
				}
				
				if (i == 0) {
					vertexCode += 'mov ' + regCache.op + ', ' + vt0 + ' \n';
					if (useNormal) {
						vertexCode += 'mov ' + nrm + '.xyz, ' + res + '.xyz \n';
					}
				} else {
					vertexCode += 'add ' + regCache.op + ', ' + regCache.op + ', ' + vt0 + ' \n';
					if (useNormal) {
						vertexCode += 'add ' + nrm + '.xyz, ' + nrm + '.xyz, ' + res + '.xyz \n';
					}
				}
			}
			
			if (useNormal) {
				vertexCode += 'm33 ' + nrm + '.xyz, ' + nrm + '.xyz, ' + regCache.vcWorld + ' \n';
				vertexCode += 'nrm ' + regCache.getV(Surface3D.NORMAL) + '.xyz, ' + nrm + '.xyz \n';
			}
			
			regCache.removeVt(vt0);
			regCache.removeVt(vt1);
			regCache.removeVt(vt3);
			regCache.removeVt(vt4);
			regCache.removeVt(vt5);
			
			if (useNormal) {
				regCache.removeFt(nrm);
				regCache.removeFt(res);
			}
			
			
			return vertexCode;
		}
		
	}
}
