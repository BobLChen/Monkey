package monkey.core.shader.filters {
	
	import flash.utils.getTimer;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.textures.CubeTextue3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.Device3D;
	
	/**
	 * 海水filter 
	 * @author Neil
	 * 
	 */	
	public class WaveFilter extends Filter3D {
		
		private var _camPos 	: Vector.<Number>;
		private var _time 		: Vector.<Number>;
		private var _fc0Data	: Vector.<Number>;
		private var _fc1Data	: Vector.<Number>;
		private var _blendData 	: Vector.<Number>;
		private var _blendColor : Color;
		private var _heightData : Vector.<Number>;
		private var mvpPosVary 	: ShaderRegisterElement;
		private var _nrmLabel	: FsRegisterLabel;
		private var _texLabel	: FsRegisterLabel;
				
		public function WaveFilter() {
			super("WaveFilter");
			this.priority 	= 15;
			this._nrmLabel  = new FsRegisterLabel(null);
			this._texLabel	= new FsRegisterLabel(null);
			this._camPos 	= Vector.<Number>([0.0, 0.0, 0.0, 0.09]);
			this._time 		= Vector.<Number>([0.0, 0, 0, 0]);
			this._fc0Data 	= Vector.<Number>([0, 1.0, 0, 50]);
			this._fc1Data 	= Vector.<Number>([0.05, 0.5, 0.1, 2]);
			this._blendData = Vector.<Number>([0.4, 0.5, 0.6, 1.0]);
			this._heightData= Vector.<Number>([20, 2, 4, 8.0]);
			this.waveHeight = 20;
			this.blendColor = new Color(0x668099);
		}
		
		/**
		 * 海水波纹贴图 
		 * @return 
		 * 
		 */		
		public function get normalTexture():Texture3D {
			return _nrmLabel.texture;
		}
			
		/**
		 * 海水波纹贴图 
		 * @return 
		 * 
		 */		
		public function set normalTexture(value:Texture3D):void {
			_nrmLabel.texture = value;
		}
		
		/**
		 * 海水贴图 
		 * @return 
		 * 
		 */		
		public function get cubeTexture():CubeTextue3D {
			return _texLabel.texture as CubeTextue3D;
		}
			
		/**
		 * 海水贴图 
		 * @return 
		 * 
		 */	
		public function set cubeTexture(value:CubeTextue3D):void {
			_texLabel.texture = value;
		}
		
		/**
		 * 海水闪光色
		 * @param value
		 * 
		 */		
		public function set blendColor(value : Color) : void {
			this._blendData[0] = value.r;
			this._blendData[1] = value.g;
			this._blendData[2] = value.b;
			this._blendColor = value;
		}
		
		/**
		 * 海水闪光色
		 * @param value
		 * 
		 */		
		public function get blendColor() : Color {
			return _blendColor;
		}
		
		/**
		 * 波纹等级
		 * @param value
		 * 
		 */		
		public function set waterWave(value : Number) : void {
			this._fc0Data[3] = value;
		}
		
		/**
		 * 波纹等级
		 * @param value
		 * 
		 */	
		public function get waterWave() : Number {
			return this._fc0Data[3];
		}
		
		/**
		 * 波峰
		 * @param	height
		 */
		public function set waveHeight(height : Number) : void {
			this._heightData[0] = height;
			this._heightData[1] = height * 0.5;
		}
		
		/**
		 * 波峰
		 * @param	height
		 */
		public function get waveHeight() : Number {
			return _heightData[0];
		}
		
		/**
		 * update 
		 */		
		override public function update() : void {
			this._camPos[0] = Device3D.cameraPos.x;
			this._camPos[1] = Device3D.cameraPos.y;
			this._camPos[2] = Device3D.cameraPos.z;
			this._time[0] 	= getTimer() / 1000;
			this._time[1] 	= getTimer() / 2000;
			this._time[2] 	= getTimer() / 4000;
			this._time[3] 	= getTimer() / 16000;
		}
		
		override public function getVertexCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			var hVc : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(_heightData));
			var vt0 : ShaderRegisterElement = regCache.getVt();
			
			var code : String = "";
			
			code += "mov " + regCache.op + ".y, " + regCache.getVa(Surface3D.CUSTOM3) + ".x \n";
			code += "mul " + regCache.op + ".y, " + regCache.op + ".y, " + hVc + ".x \n";
			code += "sub " + regCache.op + ".y, " + regCache.op + ".y, " + hVc + ".y \n";
			code += "m44 " + mvpPosVary + ", " + regCache.op + ", " + regCache.vcMvp + " \n";
			
			code += "mov " + vt0 + ".w, " + regCache.getVa(Surface3D.CUSTOM3) + ".x \n";
			code += "pow " + vt0 + ".w, " + vt0 + ".w, " + hVc + ".z \n";
			code += "mov " + mvpPosVary + ".z, " + vt0 + ".w \n";
			code += "mov " + regCache.op + ".w, " + regCache.vc0123 + ".y \n";
			
			regCache.removeVt(vt0);
			return code;
		}
		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			
			this.mvpPosVary = regCache.getFreeV();
			
			var fc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_fc0Data));
			var fc1 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_fc1Data));
			var fc2 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_camPos));
			var fc3 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_time));
			var fc4 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_blendData));
			
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();
			var ft2 : ShaderRegisterElement = regCache.getFt();
			var ft3 : ShaderRegisterElement = regCache.getFt();
			var fs0 : ShaderRegisterElement = regCache.getFs(_nrmLabel);
			var fs1 : ShaderRegisterElement = regCache.getFs(_texLabel);
			
			// 开始code拼接
			var code : String = "";
			
			code += "sub " + ft0 + ", " + regCache.getV(Surface3D.POSITION) + ", " + fc2 + " \n";
			code += "mov " + ft1 + ", " + fc0 + " \n";
			code += "mul " + ft2 + ", " + regCache.getV(Surface3D.UV0) + ", " + fc0 + ".www \n";
			code += "mov " + ft2 + ".zw, " + fc3 + ".xxwz \n";
			code += "mul " + ft3 + ", " + ft2 + ".zwzz, " + fc1 + ".xxxx \n";
			code += "add " + ft2 + ".zw, " + ft2 + ".xxxy, " + ft3 + ".xxxy \n";
			code += "tex " + ft3 + ", " + ft2 + ".zwzz, " + fs0 + description(_nrmLabel.texture) + " \n";
			code += "sub " + ft2 + ".xyz, " + ft3 + ".xzyx, " + fc1 + ".yyyy \n";
			code += "add " + ft1 + ".xyz, " + ft1 + ", " + ft2 + " \n";
			code += "mul " + ft2 + ".xy, " + regCache.getV(Surface3D.UV0) + ", " + fc0 + ".wwww \n";
			code += "mov " + ft2 + ".zw, " + fc3 + ".xxzw \n";
			code += "mul " + ft3 + ".xy, " + ft2 + ".zwzw, " + fc1 + ".zzzz \n";
			code += "sub " + ft2 + ".zw, " + ft2 + ".xxxy, " + ft3 + ".xxxy \n";
			code += "tex " + ft3 + ", " + ft2 + ".zwzz, " + fs0 + description(_nrmLabel.texture) + " \n";
			code += "sub " + ft2 + ".xyz, " + ft3 + ".xzyx, " + fc1 + ".yyyy \n";
			code += "add " + ft1 + ".xyz, " + ft1 + ", " + ft2 + " \n";
			code += "nrm " + ft1 + ".xyz, " + ft1 + " \n";
			//			code += "mov " + regCache.uvTemp + ".zw, " + ft1 + ".xz \n";
			// cubemap sample
			code += "mul " + ft2 + ".xyz, " + ft1 + ", " + fc1 + ".wwww \n";
			code += "dp3 " + ft0 + ".w, " + ft0 + ", " + ft1 + " \n";
			code += "mul " + ft1 + ".xyz, " + ft2 + ", " + ft0 + ".wwww \n";
			code += "sub " + ft2 + ".xyz, " + ft0 + ", " + ft1 + " \n";
			code += "tex " + regCache.oc + ", " + ft2 + ", " + fs1 + description(_texLabel.texture) + " \n";
			// uv fog
			//			code += "sub " + ft1 + ".xy, " + regCache.getV(Geometry3D.UV0) + ".xy, " + fc1 + ".yy \n";
			//			code += "mul " + ft1 + ".xy, " + ft1 + ".xy, " + ft1 + ".xy \n";
			//			code += "add " + ft1 + ".x, " + ft1 + ".x, " + ft1 + ".y \n";
			//			code += "sqt " + ft1 + ".x, " + ft1 + ".x \n";
			//			code += "sub " + ft1 + ".y, " + fc0 + ".y, " + ft1 + ".x \n";
			
			//		// mirror 禁止使用ft1
			//		code += "div " + ft2 + ".xy, " + _mvpPosVary + ".xy, " + _mvpPosVary + ".w \n"; // xy/w
			//		code += "mov " + ft0 + ".xy, " + fc0 + ".yx \n"; // ft0.xy = 1,0
			//		code += "sub " + ft0 + ".xy, " + ft0 + ".xy, " + fc1 + ".yy \n"; //0.5, -0.5
			//		code += "mul " + ft2 + ".xy, " + ft2 + ".xy, " + ft0 + ".xy \n"; // xy * (0.5, -0.5)
			//		code += "add " + ft2 + ".xy, " + ft2 + ".xy, " + fc1 + ".yy \n"; // xy * (0.5, -0.5) + 0.5
			//		// append uv translate
			//		code += "mul " + regCache.uvTemp + ".zw, " + regCache.uvTemp + ".zw, " + fc2 + ".w \n";
			//		code += "add " + ft2 + ".xy, " + regCache.uvTemp + ".zw, " + ft2 + ".xy \n";// normal.xz * 0.1 * 2 + proUV
			//		code += "tex " + ft0 + ", " + ft2 + ".xy, " + fs2 + getTextureDescription(_mirror) + " \n";
			
			code += "mov " + ft0 + ".xyzw, " + regCache.fc0123 + ".xxxx \n";
			
			// wave等级乘以blend color
			code += "mov " + ft2 + ".xyz, " + fc4 + ".xyz \n";
			code += "mul " + ft2 + ".xyz, " + ft2 + ".xyz, " + mvpPosVary + ".z \n";
			// 混合 使用ft1结果
			code += "mul " + ft0 + ".xyz, " + ft0 + ".xyz, " + ft0 + ".w \n"; // color * a
			code += "sub " + ft0 + ".w, " + fc4 + ".w, " + ft0 + ".w \n"; // blend * (1-a)
			code += "mul " + ft2 + ".xyz, " + ft2 + ".xyz, " + ft0 + ".w \n";
			code += "add " + ft0 + ".xyz, " + ft0 + ".xyz, " + ft2 + ".xyz \n"; // 相加
			// 本色乘以是fog权重
			//code += "mul " + regCache.outColor + ", " + regCache.outColor + ", " + ft1 + ".y \n";
			code += "add " + regCache.oc + ".xyz, " + regCache.oc + ".xyz, " + ft0 + ".xyz \n";
			
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			regCache.removeFt(ft2);
			regCache.removeFt(ft3);
			
			return code;
		}
		
	}
}
