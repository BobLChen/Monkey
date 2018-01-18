package monkey.core.shader.filters {
	import flash.geom.Matrix3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;

	/**
	 * 径向模糊 
	 * @author Neil
	 * 
	 */	
	public class RadiaBlurFilter extends Filter3D {
		
		/** 计算步长矩阵 */
		private var matrix 	: Matrix3D = new Matrix3D();
		private var consts 	: Vector.<Number>;
		private var label   : FsRegisterLabel;
				
		/**
		 * 径向模糊 
		 * @param texture	贴图
		 * @param step		步长
		 * @param xBias		x偏移量
		 * @param yBias		y偏移量
		 * 
		 */		
		public function RadiaBlurFilter(texture : Texture3D, step : int = 10, xBias : Number = 0.0025, yBias : Number = 0.005) {
			super("RadiaBlurFilter");
			this.label	= new FsRegisterLabel(texture);
			this.consts = Vector.<Number>([xBias, yBias, 1.0 / step, step]);
		}
		
		/** y步长 */
		public function get yBias() : Number {
			return consts[1];
		}
		
		/**
		 * @private
		 */
		public function set yBias(value : Number) : void {
			this.consts[1] = value;
		}
		
		/** x步长 */
		public function get xBias() : Number {
			return consts[0];
		}
		
		/**
		 * @private
		 */
		public function set xBias(value : Number) : void {
			this.consts[0] = value;
		}
		
		public function get texture() : Texture3D {
			return label.texture;
		}
		
		public function set texture(value : Texture3D) : void {
			label.texture = value;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var fc4 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(consts));
			var fc0 : ShaderRegisterElement = regCache.getFc(4, new FcRegisterLabel(matrix));
			var fc1 : ShaderRegisterElement = new ShaderRegisterElement(fc0.regName, fc0.index + 1);
			var fc2 : ShaderRegisterElement = new ShaderRegisterElement(fc0.regName, fc1.index + 1);
			var fc3 : ShaderRegisterElement = new ShaderRegisterElement(fc0.regName, fc2.index + 1);
			
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();
			var ft2 : ShaderRegisterElement = regCache.getFt();
			var ft3 : ShaderRegisterElement = regCache.getFt();
			var ft4 : ShaderRegisterElement = regCache.getFt();
			
			var fs0 : ShaderRegisterElement = regCache.getFs(label);
						
			var code : String = '';
			code += 'mov ' + ft0 + ', ' + fc0 + ' \n';
			code += 'mov ' + ft1 + ', ' + fc1 + ' \n';
			code += 'mov ' + ft2 + ', ' + fc2 + ' \n';
			code += 'mov ' + ft3 + ', ' + fc3 + ' \n';
			code += 'tex ' + regCache.oc + ', ' + regCache.getV(Surface3D.UV0) + ', ' + fs0 + description(label.texture) + ' \n';
			
			for (var i : int = 1; i < consts[3]; i++) {
				code += 'sub ' + ft0 + '.x, ' + ft0 + '.x, ' + fc4 + '.y \n';
				code += 'sub ' + ft1 + '.y, ' + ft1 + '.y, ' + fc4 + '.y \n';
				code += 'add ' + ft0 + '.w, ' + ft0 + '.w, ' + fc4 + '.x \n';
				code += 'add ' + ft1 + '.w, ' + ft1 + '.w, ' + fc4 + '.x \n';
				code += 'm44 ' + ft4 + ', ' + regCache.getV(Surface3D.UV0) + ', ' + ft0 + ' \n';
				code += 'tex ' + ft4 + ', ' + ft4 + ', ' + fs0 + description(label.texture) + ' \n';
				code += 'add ' + regCache.oc + ', ' + regCache.oc + ', ' + ft4 + ' \n';
			}
			
			code += 'mul ' + regCache.oc + ', ' + regCache.oc + ', ' + fc4 + '.z \n';
			
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			regCache.removeFt(ft2);
			regCache.removeFt(ft3);
			regCache.removeFt(ft4);
			
			return code;
		}
		
		
	}
}
