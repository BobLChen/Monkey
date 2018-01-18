package monkey.core.shader.filters {
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.textures.Texture3D;

	/**
	 * 空气扭曲filter。
	 * 1、将plane坐标转换为贴图空间坐标
	 * 2、对转换后的贴图空间坐标进行偏移
	 * 3、通过贴图空间坐标对rtt进行采用，获取背景色
	 * 4、背景色和plane颜色进行混合
	 * 5、输出即可
	 * @author neil
	 *
	 */
	public class BumpFilter extends Filter3D {
		
		private var _rttLabel : FsRegisterLabel;
		private var _bumLabel : FsRegisterLabel;
		private var _bumpAmt  : Number = 10;
		private var _data 	  : Vector.<Number> = Vector.<Number>([_bumpAmt, 1.0 / 1024, 0.5, -0.5]);
		private var rttUV 	  : ShaderRegisterElement;
		
		/**
		 *  
		 * @param rtt	背景图
		 * @param bump	扭曲贴图
		 * 
		 */		
		public function BumpFilter(rtt : Texture3D, bump : Texture3D) {
			super("BumpFilter");
			this._rttLabel = new FsRegisterLabel(rtt);
			this._bumLabel = new FsRegisterLabel(bump);
		}
		
		public function get bumpAmt() : Number {
			return _bumpAmt;
		}
		
		/**
		 * 扭曲程序 
		 * @param value
		 * 
		 */		
		public function set bumpAmt(value : Number) : void {
			this._bumpAmt = value;
			this._data[0] = value;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			this.rttUV = regCache.getFreeV();
			
			var bumpFs 	: ShaderRegisterElement = regCache.getFs(this._bumLabel);
			var rttFs  	: ShaderRegisterElement  = regCache.getFs(this._rttLabel);
			var ft0 	: ShaderRegisterElement = regCache.getFt();
			var fc0 	: ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_data));
						
			var code : String = '';
			if (agal) {
				// 对bump进行采样
				code += 'tex ' + ft0 + ', ' + regCache.getV(Surface3D.UV0) + ', ' + bumpFs + description(_bumLabel.texture) + ' \n';
				code += 'mov ' + regCache.oc + '.w, ' + ft0 + '.w \n';
				// 获取rg值
				code += 'mul ' + ft0 + '.xy, ' + ft0 + '.xy, ' + regCache.fc0123 + '.z \n';
				code += 'sub ' + ft0 + '.xy, ' + ft0 + '.xy, ' + regCache.fc0123 + '.yy \n';
				// 获取offset
				code += 'sat ' + ft0 + '.w, ' + ft0 + '.w \n';
				code += 'mul ' + ft0 + '.xy, ' + ft0 + '.xy, ' + ft0 + '.w \n';
				code += 'mul ' + ft0 + '.xy, ' + ft0 + '.xy, ' + fc0 + '.x \n';
				code += 'mul ' + ft0 + '.xy, ' + ft0 + '.xy, ' + fc0 + '.y \n';
				code += 'add ' + ft0 + '.xy, ' + ft0 + '.xy, ' + rttUV + '.xy \n';
				// 对rtt进行采样
				code += 'tex ' + ft0 + ', ' + ft0 + '.xy, ' + rttFs + description(_rttLabel.texture) + ' \n';
				// 输出
				code += 'mov ' + regCache.oc + '.xyz, ' + ft0 + '.xyz \n';
			}
			regCache.removeFt(ft0);
			return code;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var vt0 : ShaderRegisterElement = regCache.getVt();
			var axe : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(_data));
			var code : String = '';
			if (agal) {
				code += 'm44 ' + vt0 + ', '    + regCache.getVa(Surface3D.POSITION) + ', ' + regCache.vcMvp + '\n'
				code += 'div ' + vt0 + ', '    + vt0 + ', ' + vt0 + '.w\n';
				code += 'mul ' + vt0 + '.xy, ' + vt0 + '.xy, ' + axe + '.zw\n'; // 0.5 -0.5
				code += 'add ' + rttUV + '.xy, ' + vt0 + '.xy, ' + axe + '.zz\n'; // 0.5 0.5 0 0
				code += 'mov ' + rttUV + '.zw, ' + vt0 + '.zw \n';
			}
			regCache.removeFt(vt0);
			return code;
		}
		
		
	}
}
