package monkey.core.shader.filters {
	
	import flash.geom.Matrix3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.utils.Device3D;
	
	/**
	 * 线段
	 * @author Neil
	 * 
	 */	
	public class Line3DFilter extends Filter3D {
		
		private var invMvMt : Matrix3D;
		private var mvMt    : Matrix3D;
		private var color	: ShaderRegisterElement;
		
		public function Line3DFilter() {
			super("Line3DFilter");
			this.mvMt = new Matrix3D();
			this.invMvMt = new Matrix3D();
		}
		
		override public function update() : void {
			this.mvMt.copyFrom(Device3D.world);
			this.mvMt.append(Device3D.view);
			this.invMvMt.copyFrom(mvMt);
			this.invMvMt.invert();
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			this.color = regCache.getFreeV();
			var code : String = "";
			if (agal) {
				code += "mov " + regCache.oc + ", " + color + " \n";		
			}
			return code;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			var vc1 : ShaderRegisterElement = regCache.getVc(4, new VcRegisterLabel(mvMt));
			var vc0 : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(Vector.<Number>([1, 0, 0, 0])));
			var vc5 : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(Vector.<Number>([1, 1, 1, 1])));
			var vc7 : ShaderRegisterElement = regCache.getVc(4, new VcRegisterLabel(invMvMt));
						
			var vt0 : ShaderRegisterElement = regCache.getVt();
			var vt1 : ShaderRegisterElement = regCache.getVt();
			var vt2 : ShaderRegisterElement = regCache.getVt();
			var vt3 : ShaderRegisterElement = regCache.getVt();
			var vt4 : ShaderRegisterElement = regCache.getVt();
			var vt5 : ShaderRegisterElement = regCache.getVt();
			
			var code : String = '';
			
			if (agal) {
				code += 'm44 ' + vt0 + ', ' + regCache.getVa(Surface3D.POSITION) + ', ' + vc1 + '.xyzw \n';
				code += 'm44 ' + vt1 + ', ' + regCache.getVa(Surface3D.CUSTOM1) + ', ' + vc1 + '.xyzw \n';
				code += 'sub ' + vt2 + ', ' + vt1 + ', ' + vt0 + ' \n';
				code += 'slt ' + vt3 + ', ' + vt0 + '.zzzz, ' + vc5 + '.xxxx \n';
				code += 'sub ' + vt3 + '.y, ' + vc0 + '.xxxx, ' + vt3 + '.xxxx \n';
				code += 'sub ' + vt3 + '.z, ' + vt0 + '.xxzz, ' + vc5 + '.xxxx \n';
				code += 'sub ' + vt3 + '.w, ' + vt0 + '.xxxz, ' + vt1 + '.xxxz \n';
				code += 'div ' + vt4 + ', ' + vt3 + '.zzzz, ' + vt3 + '.www \n';
				code += 'mul ' + vt5 + ', ' + vt2 + ', ' + vt4 + '.xxxx \n';
				code += 'add ' + vt4 + ', ' + vt0 + ', ' + vt5 + ' \n';			
				code += 'mul ' + vt5 + ', ' + vt3 + '.xxxx, ' + vt4 + ' \n';
				code += 'mul ' + vt4 + ', ' + vt0 + ', ' + vt3 + '.yyyy \n';
				code += 'add ' + vt0 + ', ' + vt5 + ', ' + vt4 + ' \n';
				code += 'crs ' + vt3 + '.xyz, ' + vt2 + ', ' + vt1 + ' \n';			
				code += 'nrm ' + vt1 + '.xyz, ' + vt3 + ' \n';
				code += 'mul ' + vt2 + '.xyz, ' + vt1 + ', ' + regCache.getVa(Surface3D.CUSTOM2) + '.xxxx \n';
				code += 'mul ' + vt1 + '.x, ' + vt0 + '.zzzz, ' + regCache.getVa(Surface3D.CUSTOM2) + '.yyyy \n';
				code += 'mul ' + vt3 + '.xyz, ' + vt2 + ', ' + vt1 + '.xxxx \n';
				code += 'add ' + vt1 + '.xyz, ' + vt0 + ', ' + vt3 + ' \n';			
				code += 'mov ' + vt1 + '.w, ' + vc0 + '.xxxx \n';
				code += 'm44 ' + regCache.op + ', ' + vt1 + ', ' + vc7 + '.xyzw \n';
				code += 'mov ' + color + ', ' + regCache.getVa(Surface3D.CUSTOM3) + '\n';
			}
						
			regCache.removeVt(vt0);
			regCache.removeVt(vt1);
			regCache.removeVt(vt2);
			regCache.removeVt(vt3);
			regCache.removeVt(vt4);
			regCache.removeVt(vt5);
			
			return code;
		}
		
		
	}
}
