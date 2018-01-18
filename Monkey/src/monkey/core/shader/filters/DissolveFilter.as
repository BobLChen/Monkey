package monkey.core.shader.filters {

	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Color;

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
	 * 消融filter
	 * @author neil
	 * @date   Dec 23, 2015
	 */
	public class DissolveFilter extends Filter3D {
		
		/** 溶解贴图 dissolve */
		private var dissLabel : FsRegisterLabel;
		/** 颜色贴图 */
		private var diffLabel : FsRegisterLabel;
		/** 参数 */
		private var bias : Vector.<Number>;
		/** 颜色 */
		private var tint : Vector.<Number>;
		
		public function DissolveFilter() {
			super("DissolveFilter");
			this.bias = Vector.<Number>([0.0, 0.1, 0.05, 0.0]);	
			this.tint = Vector.<Number>([0.0, 1.0, 0.0, 1.0]);
			this.diffLabel = new FsRegisterLabel(null);
			this.dissLabel = new FsRegisterLabel(null);
		}
		
		public function set intensity(value : Number) : void {
			this.bias[3] = value;
		}
		
		/**
		 * 强度 
		 * @return 
		 * 
		 */		
		public function get intensity() : Number {
			return this.bias[3];
		}
		
		/**
		 * 溶解阀值 
		 * @param value
		 * 
		 */		
		public function set valve(value : Number) : void {
			this.bias[1] = value;
		}
		
		public function get valve() : Number {
			return this.bias[1];
		}
		
		/**
		 * 溶解进度 
		 * @return 
		 * 
		 */		
		public function get step() : Number {
			return this.bias[0];
		}
		
		/**
		 * 溶解进度 
		 * @param value
		 * 
		 */		
		public function set step(value : Number) : void {
			this.bias[0] = value;
		}
		
		/**
		 * 设置溶解色 
		 * @param color
		 * 
		 */		
		public function set tintColor(color : Color) : void {
			this.tint[0] = color.r;
			this.tint[1] = color.g;
			this.tint[2] = color.b;
		}
		
		/**
		 * 溶解材质 
		 * @return 
		 * 
		 */		
		public function get dissolve() : Texture3D {
			return this.dissLabel.texture;
		}
		
		public function set dissolve(tex : Texture3D) : void {
			this.dissLabel.texture = tex;
		}
		
		/**
		 * 材质 
		 * @return 
		 * 
		 */		
		public function get diffuse() : Texture3D {
			return this.diffLabel.texture;
		}
		
		public function set diffuse(tex : Texture3D) : void {
			this.diffLabel.texture = tex;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(bias));
			var fc1 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(tint));
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();
			var ft2 : ShaderRegisterElement = regCache.getFt();
			var fs0 : ShaderRegisterElement = regCache.getFs(diffLabel);
			var fs1 : ShaderRegisterElement = regCache.getFs(dissLabel);
			
			var ret : String = "";
			ret += "tex " + ft0 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs0 + " <2d, linear, miplinear, repeat>\n";
			ret += "tex " + ft1 + ", " + regCache.getV(Surface3D.UV0) + ", " + fs1 + " <2d, linear, miplinear, repeat>\n";
			ret += "sub " + ft1 + ".x, " + ft1 + ".x, " + fc0 + ".x \n";
			ret += "kill " + ft1 + ".x \n";
			// 检测差值是否小于阀值,小于为1，不小于为0
			ret += "slt " + ft1 + ".y, " + ft1 + ".x, " + fc0 + ".y \n"; 
			// 通过差值计算出强度
			ret += "div " + ft1 + ".z, " + fc0 + ".z, " + ft1 + ".x \n";
			// 强度乘以混合色
			ret += "mul " + ft2 + ".xyz, " + ft1 + ".z, " + fc1 + ".xyz \n";
			// 混合色乘以阀值结果
			ret += "mul " + ft2 + ".xyz, " + ft2 + ".xyz, " + ft1 + ".y \n";
			// 乘以原色
			ret += "mul " + regCache.oc + ".xyz, " + ft0 + ".xyz, " + ft2 + ".xyz \n";
			// 1-阀值结果
			ret += "sub " + ft1 + ".y, " + regCache.fc0123 + ".y, " + ft1 + ".y \n";
			// 乘以原色
			ret += "mul " + ft0 + ".xyz, " + ft0 + ".xyz, " + ft1 + ".y \n";
			// 相加
			ret += "add " + regCache.oc + ".xyz, " + regCache.oc + ".xyz, " + ft0 + ".xyz \n";
			
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			regCache.removeFt(ft2);
			return ret;
		}
		
	}
}
