package monkey.core.shader.filters {

	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;

	/**
	 *　　　　　　　　┏┓　　　┏┓+ +
	 *　　　　　　　┏┛┻━━━┛┻┓ + +
	 *　　　　　　　┃　　　　　　　┃ 　
	 *　　　　　　　┃　　　━　　　┃ ++ + + +
	 *　　　　　　 ████━████ ┃+
	 *　　　　　　　┃　　　　　　　┃ +
	 *　　　　　　　┃　　　┻　　　┃
	 *　　　　　　　┃　　　　　　　┃ + +
	 *　　　　　　　┗━┓　　　┏━┛
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + + + +
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + 　　　　　　
	 *　　　　　　　　　┃　　　┃
	 *　　　　　　　　　┃　　　┃　　+　　　　　　　　　
	 *　　　　　　　　　┃　 　　┗━━━┓ + +
	 *　　　　　　　　　┃ 　　　　　　　┣┓
	 *　　　　　　　　　┃ 　　　　　　　┏┛
	 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
	 *　　　　　　　　　　┃┫┫　┃┫┫
	 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
	 * 查询图filter
	 * @author Neil
	 * @date   Jul 3, 2015
	 */
	public class LutFilter extends Filter3D {
		
		private var bias 	: Vector.<Number>;
		private var rttTex	: FsRegisterLabel;
		private var lutTex	: FsRegisterLabel;
		
		public function LutFilter(rtt : Texture3D, lut : Texture3D) {
			super(name);
			this.bias 	= Vector.<Number>([252 / 255, 64, 8, 0]);
			this.rttTex = new FsRegisterLabel(rtt);
			this.lutTex = new FsRegisterLabel(lut);
		}

		public function get rtt() : Texture3D {
			return this.rttTex.texture;
		}
		
		public function set rtt(value : Texture3D) : void {
			this.rttTex.texture = value;
		}
		
		public function get lut() : Texture3D {
			return this.lutTex.texture;
		}
		
		public function set lut(value : Texture3D) : void {
			this.lutTex.texture = value;
		}
		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			var fsRtt : ShaderRegisterElement = regCache.getFs(this.rttTex);
			var fsLut : ShaderRegisterElement = regCache.getFs(this.lutTex);
			var fc0	  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(this.bias));
			var ft0	  : ShaderRegisterElement = regCache.getFt();
			var ft1   : ShaderRegisterElement = regCache.getFt();
			
			var code  : String = "";
			
			if (agal) {
				// 原图采样
				code += "tex " + ft0 + ", " + regCache.getV(Surface3D.UV0) + ", " + fsRtt + " <2d, linear, miplinear, repeat> \n";
				code += "mul " + ft0 + ".xyz, " + ft0 + ".xyz, " + fc0 + ".xxx \n";
				// 计算格子索引
				code += "mul " + ft1 + ".z, " + ft0 + ".z, " + fc0 + ".y \n";
				// 取整
				code += "frc " + ft1 + ".w, " + ft1 + ".z \n";
				code += "sub " + ft1 + ".z, " + ft1 + ".z, " + ft1 + ".w \n";
				// 计算行列
				code += "div " + ft1 + ".y, " + ft1 + ".z, " + fc0 + ".z \n";
				code += "frc " + ft1 + ".z, " + ft1 + ".y \n";
				
				code += "mul " + ft1 + ".x, " + ft1 + ".z, " + fc0 + ".z \n";
				code += "frc " + ft1 + ".w, " + ft1 + ".x \n";
				code += "sub " + ft1 + ".xy, " + ft1 + ".xy, " + ft1 + ".wz \n";				
				// 进行UV偏移
				code += "div " + ft1 + ".zwzw, " + ft0 + ".xyxy, " + fc0 + ".zzzz \n";
				code += "div " + ft1 + ".xy, " + ft1 + ".xy, " + fc0 + ".zz \n";
				code += "add " + ft1 + ".xy, " + ft1 + ".xy, " + ft1 + ".zw \n";
				// 对lut采样
				code += "tex " + ft0 + ", " + ft1 + ", " + fsLut + " <2d, clamp, linear, mipnone> \n";
				code += "mov " + regCache.oc + ", " + ft0 + " \n";
			}
			
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			
			return code;
		}
		
	}
}
