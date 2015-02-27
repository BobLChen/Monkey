package monkey.core.shader.filters {
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.textures.Texture3D;
	
	/**
	 * fxaa 1 
	 * @author Neil
	 * 
	 */	
	public class FXAAFilter extends Filter3D {
		
		private var _rttLabel : FsRegisterLabel;
		
		public function FXAAFilter(rtt : Texture3D) {
			super("FXAAFilter");
			this._rttLabel = new FsRegisterLabel(rtt);
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			var fxaa  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(Vector.<Number>([8.0, 1.0 / 32.0, 1.0 / 128.0, 1.0 / 2048.0])));
			var fs0   : ShaderRegisterElement = regCache.getFs(_rttLabel);
			var rgbNW : ShaderRegisterElement = regCache.getFt();
			var rgbNE : ShaderRegisterElement = regCache.getFt();
			var rgbSW : ShaderRegisterElement = regCache.getFt();
			var rgbSE : ShaderRegisterElement = regCache.getFt();
			var rgbM  : ShaderRegisterElement = regCache.getFt();
			var luma  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(Vector.<Number>([0.299, 0.587, 0.114, -1.0])));
			var ft0   : ShaderRegisterElement = regCache.getFt();
			var uv0   : ShaderRegisterElement = regCache.getV(Surface3D.UV0);
			var fc0   : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(Vector.<Number>([1.0 / 3.0 - 0.5, 2.0 / 3.0 - 0.5, 0.0 / 3.0 - 0.5, 3.0 / 3.0 - 0.5])));
			var fc1   : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(Vector.<Number>([1.0 / 2.0, 1.0 / 2.0 + 1.0 / 4.0, 1.0, 0.5])));
			
			var code : String = "";
			
			if (agal) {
				code += "mov " + ft0 + ".xy, " + fxaa + ".ww \n";
				code += "mul " + ft0 + ".xy, " + ft0 + ".xy, " + luma + ".ww \n"; //(-1, -1)
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + " \n";
				code += "tex " + rgbNW + ", " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				
				code += "mov " + ft0 + ".xy, " + fxaa + ".ww \n";
				code += "mul " + ft0 + ".y, " + ft0 + ".y, " + luma + ".w \n"; // (1.0, -1.0)
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + " \n";
				code += "tex " + rgbNE + ", " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				
				code += "mov " + ft0 + ".xy, " + fxaa + ".ww \n";
				code += "mul " + ft0 + ".x, " + ft0 + ".x, " + luma + ".w \n"; // (-1.0, 1.0)
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + " \n";
				code += "tex " + rgbSW + ", " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				
				code += "mov " + ft0 + ".xy, " + fxaa + ".ww \n"; // (1.0, 1.0)
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + " \n";
				code += "tex " + rgbSE + ", " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				code += "tex " + rgbM + ", " + uv0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				
				code += "dp3 " + ft0 + ".x, " + rgbNW + ".xyz, " + luma + ".xyz \n"; // lumaNW
				code += "dp3 " + ft0 + ".y, " + rgbNE + ".xyz, " + luma + ".xyz \n"; // lumaNE
				code += "dp3 " + ft0 + ".z, " + rgbSW + ".xyz, " + luma + ".xyz \n"; // lumaSW
				code += "dp3 " + ft0 + ".w, " + rgbSE + ".xyz, " + luma + ".xyz \n"; // lumaSE
				// rgbNW rgbNE rgbSW rgbSE not used. we can use them now.
				
				// rgbNW.x used
				code += "dp3 " + rgbNW + ".x, " + rgbM + ".xyz, " + luma + ".xyz \n"; // lumaM
				// rgbNE.xyzw used
				// min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
				code += "min " + rgbNE + ".x, " + ft0 + ".z, " + ft0 + ".w \n"; // min(lumaSW, lumaSE)
				code += "min " + rgbNE + ".y, " + ft0 + ".x, " + ft0 + ".y \n"; // min(lumaNW, lumaNE)
				code += "min " + rgbNE + ".z, " + rgbNE + ".x, " + rgbNE + ".y \n"; // min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
				code += "min " + rgbNW + ".y, " + rgbNW + ".x, " + rgbNW + ".z \n"; // min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
				// lumaMin = rgbNW.y
				
				// rgbSW used
				// max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
				code += "max " + rgbSW + ".x, " + ft0 + ".z, " + ft0 + ".w \n"; // max(lumaSW, lumaSE)
				code += "max " + rgbSW + ".y, " + ft0 + ".x, " + ft0 + ".y \n"; // max(lumaNW, lumaNE)
				code += "max " + rgbSW + ".z, " + rgbSW + ".x, " + rgbSW + ".y \n"; // max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
				code += "max " + rgbNW + ".z, " + rgbNW + ".x, " + rgbSW + ".z \n"; // max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
				// lumaMax = rgbNW.z
				
				// rgbSE.xy used
				// -((lumaNW + lumaNE) - (lumaSW + lumaSE));
				code += "add " + rgbSE + ".w, " + ft0 + ".x, " + ft0 + ".y \n"; // lumaNW + lumaNE
				code += "add " + rgbSE + ".z, " + ft0 + ".z, " + ft0 + ".w \n"; // lumaSW + lumaSE
				code += "sub " + rgbSE + ".x, " + rgbSE + ".z, " + rgbSE + ".w \n"; // -((lumaNW + lumaNE) - (lumaSW + lumaSE));
				// dir.x = rgbSE.x
				
				// ((lumaNW + lumaSW) - (lumaNE + lumaSE));
				code += "add " + rgbSE + ".w, " + ft0 + ".x, " + ft0 + ".z \n"; // lumaNW + lumaSW
				code += "add " + rgbSE + ".z, " + ft0 + ".y, " + ft0 + ".w \n"; // (lumaNE + lumaSE)
				code += "sub " + rgbSE + ".y, " + rgbSE + ".w, " + rgbSE + ".z \n"; // ((lumaNW + lumaSW) - (lumaNE + lumaSE));
				// dir.y = rgbSE.y
				
				// max((lumaNW + lumaNE + lumaSW + lumaSE) * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
				code += "add " + rgbNW + ".w, " + ft0 + ".x, " + ft0 + ".y \n";
				code += "add " + rgbNW + ".w, " + rgbNW + ".w, " + ft0 + ".z \n";
				code += "add " + rgbNW + ".w, " + rgbNW + ".w, " + ft0 + ".w \n"; // (lumaNW + lumaNE + lumaSW + lumaSE)
				code += "mul " + rgbNW + ".w, " + rgbNW + ".w, " + fxaa + ".y \n"; // (lumaNW + lumaNE + lumaSW + lumaSE) * FXAA_REDUCE_MUL)
				code += "max " + rgbNW + ".w, " + rgbNW + ".w, " + fxaa + ".z \n"; // max((lumaNW + lumaNE + lumaSW + lumaSE) * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
				// dirReduce = rgbNW.w
				
				// 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
				code += "abs " + rgbNE + ".x, " + rgbSE + ".x \n";
				code += "abs " + rgbNE + ".y, " + rgbSE + ".y \n";
				code += "min " + rgbNE + ".z, " + rgbNE + ".x, " + rgbNE + ".y \n"; //min(abs(dir.x), abs(dir.y))
				code += "add " + rgbNE + ".w, " + rgbNE + ".z, " + rgbNW + ".w \n"; //(min(abs(dir.x), abs(dir.y)) + dirReduce)
				code += "div " + rgbNE + ".w, " + luma + ".w, " + rgbNE + ".w \n";
				code += "neg " + rgbNE + ".w, " + rgbNE + ".w \n";
				// rcpDirMin = rgbNE.w
				
				// dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) / frameBufSize;
				code += "mul " + rgbSE + ".zw, " + rgbSE + ".xy, " + rgbNE + ".ww \n"; // dir * rcpDirMin
				code += "mov " + rgbNE + ".zw, " + fxaa + ".xx \n"; // FXAA_SPAN_MAX
				code += "mul " + rgbNE + ".zw, " + rgbNE + ".zw, " + luma + ".ww \n"; // vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX)
				code += "max " + rgbNE + ".zw, " + rgbNE + ".zw, " + rgbSE + ".zw \n"; //max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)
				code += "mov " + rgbSE + ".zw, " + fxaa + ".xx \n"; // vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX)
				code += "min " + rgbSE + ".zw, " + rgbSE + ".zw, " + rgbNE + ".zw \n";
				code += "mul " + rgbSE + ".zw, " + rgbSE + ".zw, " + fxaa + ".ww \n";
				// dir=rgbSE.zw
				
				
				// dir=rgbSE.zw
				// lumaMin=rgbNW.y
				// lumaMax=rgbNW.z
				// rgbNE rgbSW can be used
				// texture2D(buf0, texCoords.xy + dir * (1.0/3.0 - 0.5)).xyz
				code += "mul " + ft0 + ".xy, " + rgbSE + ".zw, " + fc0 + ".x \n"; // dir * (1.0/3.0 - 0.5)
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + ".xy \n"; // texCoords.xy + dir * (1.0/3.0 - 0.5)
				code += "tex " + rgbNE + ".xyz, " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				// texture2D(buf0, texCoords.xy + dir * (2.0/3.0 - 0.5)).xyz)
				code += "mul " + ft0 + ".xy, " + rgbSE + ".zw, " + fc0 + ".y \n";
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + ".xy \n";
				code += "tex " + rgbSW + ".xyz, " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				// add
				code += "add " + rgbSW + ".xyz, " + rgbSW + ".xyz, " + rgbNE + ".xyz \n";
				code += "mul " + rgbSW + ".xyz, " + rgbSW + ".xyz, " + fc1 + ".xx \n";
				// rgbA = rgbSW.xyz
				
				// texture2D(buf0, texCoords.xy + dir * (0.0/3.0 - 0.5)).xyz
				code += "mul " + ft0 + ".xy, " + rgbSE + ".zw, " + fc0 + ".z \n";
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + ".xy \n";
				code += "tex " + rgbNE + ".xyz, " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				
				// texture2D(buf0, texCoords.xy + dir * (3.0/3.0 - 0.5)).xyz
				code += "mul " + ft0 + ".xy, " + rgbSE + ".zw, " + fc0 + ".w \n";
				code += "add " + ft0 + ".xy, " + ft0 + ".xy, " + uv0 + ".xy \n";
				code += "tex " + rgbSE + ".xyz, " + ft0 + ".xy, " + fs0 + description(_rttLabel.texture) + " \n";
				// add
				code += "add " + rgbSE + ".xyz, " + rgbSE + ".xyz, " + rgbNE + ".xyz \n";
				code += "mul " + rgbSE + ".xyz, " + rgbSE + ".xyz, " + fc1 + ". y \n";
				code += "mul " + rgbSE + ".xyz, " + rgbSE + ".xyz, " + rgbSW + ".xyz \n";
				// rgbB = rgbSE.xyz
				
				code += "dp3 " + rgbSE + ".w, " + rgbSE + ".xyz, " + luma + ".xyz \n";
				
				// rgbA = rgbSW.xyz
				// rgbB = rgbSE.xyz
				// lumaB = rgbSE.w
				// lumaMin=rgbNW.y
				// lumaMax=rgbNW.z
				
				//			code += "slt " + ft0 + ".x, " + rgbSE + ".w, " + rgbNW + ".y \n"; // lumaB < lumaMin
				//			code += "slt " + ft0 + ".y, " + rgbNW + ".z, " + rgbSE + ".w \n"; // lumaMax < lumaB
				//			code += "add " + ft0 + ".x, " + ft0 + ".x, " + ft0 + ".y \n"; // (lumaB < lumaMin) + (lumaMax < lumaB)
				//			code += "sge " + ft0 + ".x, " + ft0 + ".x, " + regCache.fc0123 + ".y \n"; // >= 1 ? 1 : 0
				//			code += "mul " + rgbSW + ".xyz, " + rgbSW + ".xyz, " + ft0 + ".x \n"; // 1 or 0 * rgbA
				//			code += "sub " + ft0 + ".x, " + regCache.fc0123 + ".y, " + ft0 + ".x \n"; // 0 or 1
				//			code += "mul " + rgbSE + ".xyz, " + rgbSE + ".xyz, " + ft0 + ".x \n"; // 0 or 1 * rgbB
				
				code += "add " + regCache.oc + ".xyz, " + rgbSE + ".xyz, " + rgbSW + ".xyz \n"; // add...
				code += "mov " + regCache.oc + ".xyz, " + rgbSW + ".xyz \n";
				code += "mov " + regCache.oc + ".w, " + regCache.fc0123 + ".y \n";	
			}
			
			regCache.removeFt(rgbNW);
			regCache.removeFt(rgbNE);
			regCache.removeFt(rgbSW);
			regCache.removeFt(rgbSE);
			regCache.removeFt(rgbM);
			regCache.removeFt(ft0);
			
			return code;
		}
		
	}
}
