package monkey.core.shader.filters {
	import flash.geom.Matrix3D;
	
	import monkey.core.camera.Camera3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;
	
	/**
	 * 二次线性插值过滤
	 * 对阴影贴图进行采样时,投影纹理坐标 (𝑢, 𝑣) 通常不会与阴影贴图中的纹理元素一一对应。
	 * 这些纹理坐标通常 会落在 4 个纹理元素之间。我们可以通过使用二次线性插值解决这一问题。
	 * 不过,不应该计算深度平均值,因为这会导致错误的结果,使本来没有阴影的地方出现阴影。
	 * (出于同样的原因,也不能为阴影贴图生成多级渐近纹理层。)所以, 应该对深度贴图的采样结果进行插值,
	 * 而不是对深度贴图 进行插值。也就是,我们使用点过滤
	 * 对坐标 (𝑢, 𝑣)、(𝑢 + ∆𝑥, 𝑣)、(𝑢, 𝑣 + ∆𝑥)、(𝑢 + ∆𝑥, 𝑣 + ∆𝑥) 进行采样,
	 * 其中 Δ𝑥 = 1/SHADOW_MAP_SIZE。由此,这 4 个点会分别命中与 (𝑢, 𝑣) 距离最近的 4 个纹理元素
	 *  𝐬0、 𝐬1、𝐬2、𝐬3,然后,我们对这些采样值进行阴影贴图测试,
	 * @author neil
	 *
	 */
	public class FilterShadowMapFilter extends Filter3D {
		
		private var _epsilon 		: Number = 0.01;
		private var _lightViewProj	: Matrix3D = new Matrix3D();
		private var _depthMapAxe 	: ShaderRegisterElement;
		private var _filterData 	: Vector.<Number>;				// 二次线性过滤数据
		private var _decRGBData 	: Vector.<Number>;				// rgb解码数据
		private var _projTxtAxeData : Vector.<Number>;				// 投影纹理坐标数据
		private var _shadowLabel	: FsRegisterLabel;
		private var _light 			: Camera3D;
		
		/**
		 * 阴影shader 
		 * @param shadowmap		shadowmmap图
		 * @param light			灯光
		 * 
		 */		
		public function FilterShadowMapFilter(shadowmap : Texture3D, light : Camera3D) {
			super("FilterShadowMapFilter");
			this.priority 		= 14;
			this._shadowLabel	= new FsRegisterLabel(shadowmap);
			this._filterData 	= Vector.<Number>([0.5, shadowmap.width, 1.0 / shadowmap.width, 0]);
			this._decRGBData 	= Vector.<Number>([1.0, 1.0 / 255, 1.0 / 65025, 1.0 / 16581375]);
			this._projTxtAxeData= Vector.<Number>([0.5, -0.5, 0, 0]);
			this._light 		= light;
			this.epsilon 		= 0.0009;
		}
		
		public function get epsilon():Number {
			return _epsilon;
		}
		
		/**
		 * epsilon 
		 * @param value
		 * 
		 */		
		public function set epsilon(value:Number):void {
			this._epsilon = value;
			this._projTxtAxeData[3] = -value;
		}
		
		override public function update() : void {
			this._lightViewProj.copyFrom(Device3D.world);
			this._lightViewProj.append(_light.viewProjection);
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			this._depthMapAxe = regCache.getFreeV();
			// 阴影图
			var shadowTexture : ShaderRegisterElement = regCache.getFs(_shadowLabel);
			// rgb解码
			var decRGB : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_decRGBData));
			// 线性过滤
			var filterFc0 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_filterData));
			// 阴影图颜色
			var shadowColor : ShaderRegisterElement = regCache.getFt();
			// uv
			var ft0 : ShaderRegisterElement = regCache.getFt();
			// target
			var ft1 : ShaderRegisterElement = regCache.getFt();
			
			var code : String = '';
			
			if (agal) {
				code += 'mov ' + ft0 + ', ' + _depthMapAxe + '\n';
				// (𝑢, 𝑣)
				code += 'tex ' + shadowColor + ', ' + _depthMapAxe + ', ' + shadowTexture + ' <2d, nearest, clamp>\n'; // 阴影图采样
				code += 'dp4 ' + shadowColor + '.z, ' + shadowColor + ', ' + decRGB + '\n';  // 计算深度
				code += 'slt ' + ft0 + '.z, ' + _depthMapAxe + '.z, ' + shadowColor + '.z\n'; // 获取s0
				//(𝑢 + ∆𝑥, 𝑣)
				code += 'add ' + ft0 + '.x, ' + _depthMapAxe + '.x, ' + filterFc0 + '.z\n'; // 
				code += 'tex ' + shadowColor + ', ' + ft0 + ', ' + shadowTexture + ' <2d, nearest, clamp>\n';
				code += 'dp4 ' + shadowColor + '.z, ' + shadowColor + ', ' + decRGB + '\n';
				code += 'slt ' + ft0 + '.w, ' + _depthMapAxe + '.z, ' + shadowColor + '.z\n'; // s1
				// lerp(result0, result1, t.x)
				code += 'mul ' + shadowColor + '.x, ' + _depthMapAxe + '.x, ' + filterFc0 + '.y\n'; // t.x
				code += 'frc ' + shadowColor + '.x, ' + shadowColor + '.x\n'; 
				code += 'sub ' + ft0 + '.w, ' + ft0 + '.w, ' + ft0 + '.z\n'; // s1 - s0
				code += 'mul ' + ft0 + '.w, ' + ft0 + '.w, ' + shadowColor + '.x\n'; // (s1 - s0) * t.x
				code += 'add ' + ft1 + '.w, ' + ft0 + '.z, ' + ft0 + '.w\n'; // (s1 - s0) * t.x + s0
				// (𝑢 , 𝑣 + ∆y)
				code += 'mov ' + ft0 + '.x, ' + _depthMapAxe + '.x\n';
				code += 'add ' + ft0 + '.y, ' + _depthMapAxe + '.y, ' + filterFc0 + '.z\n';
				code += 'tex ' + shadowColor + ', ' + ft0 + ', ' + shadowTexture + ' <2d, nearest, clamp>\n';
				code += 'dp4 ' + shadowColor + '.z, ' + shadowColor + ', ' + decRGB + '\n';
				code += 'slt ' + ft0 + '.z, ' + _depthMapAxe + '.z, ' + shadowColor + '.z\n'; // s2
				// (𝑢 + ∆𝑥, 𝑣 + ∆𝑥)
				code += 'add ' + ft0 + '.x, ' + _depthMapAxe + '.x, ' + filterFc0 + '.z\n';
				code += 'tex ' + shadowColor + ', ' + ft0 + ', ' + shadowTexture + ' <2d, nearest, clamp>\n';
				code += 'dp4 ' + shadowColor + '.z, ' + shadowColor + ', ' + decRGB + '\n';
				code += 'slt ' + ft0 + '.w, ' + _depthMapAxe + '.z, ' + shadowColor + '.z\n'; // s3
				// lerp(result2, result3, t.x)
				code += 'mul ' + shadowColor + '.x, ' + _depthMapAxe + '.x, ' + filterFc0 + '.y\n'; // t.x
				code += 'frc ' + shadowColor + '.x, ' + shadowColor + '.x\n';
				code += 'sub ' + ft0 + '.w, ' + ft0 + '.w, ' + ft0 + '.z\n'; // s3 - s2
				code += 'mul ' + ft0 + '.w, ' + ft0 + '.w, ' + shadowColor + '.x\n'; // (s3 - s2) * t.x
				code += 'add ' + ft0 + '.w, ' + ft0 + '.z, ' + ft0 + '.w\n'; // (s3 - s2) * t.x + s2
				// lerp(lerp(result0, result1, t.x), lerp(result2, result3, t.x), t.y)
				code += 'mul ' + shadowColor + '.x, ' + _depthMapAxe + '.y, ' + filterFc0 + '.y\n'; // t.y
				code += 'frc ' + shadowColor + '.x, ' + shadowColor + '.x\n';
				code += 'sub ' + ft0 + '.w, ' + ft0 + '.w, ' + ft1 + '.w\n';
				code += 'mul ' + ft0 + '.w, ' + ft0 + '.w, ' + shadowColor + '.x\n';
				code += 'add ' + ft1 + '.w, ' + ft1 + '.w, ' + ft0 + '.w\n';
				// 
				code += 'sat ' + ft1 + '.w, ' + ft1 + '.w\n';
				code += 'slt ' + ft1 + '.z, ' + ft1 + '.w, ' + filterFc0 + '.x \n';
				code += 'mul ' + ft1 + '.z, ' + filterFc0 + '.x, ' + ft1 + '.z \n';
				code += 'slt ' + ft1 + '.w, ' + filterFc0 + '.x, ' + ft1 + '.w \n';
				code += 'add ' + ft1 + '.w, ' + ft1 + '.z, ' + ft1 + '.w \n';
				code += 'mul ' + regCache.oc + '.xyz, ' + regCache.oc + '.xyz, ' + ft1 + '.w \n';
			}
			
			regCache.removeFt(shadowColor);
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			
			return code;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var vt0 : ShaderRegisterElement = regCache.getVt();
			var dataReg : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(_projTxtAxeData));
			var depthMapProj : ShaderRegisterElement = regCache.getVc(4, new VcRegisterLabel(_lightViewProj));
			var code : String = '';
			if (agal) {
				code += 'm44 ' + vt0 + ', ' + regCache.op + ', ' + depthMapProj + '\n';
				code += 'div ' + vt0 + ', ' + vt0 + ', ' + vt0 + '.w\n';
				// 转换到贴图坐标系
				code += 'mul ' + vt0 + '.xy, ' + vt0 + '.xy, ' + dataReg + '.xy\n'; // 0.5 -0.5
				code += 'add ' + _depthMapAxe + ', ' + vt0 + ', ' + dataReg + '.xxwz\n'; // 0.5 0.5 0 0
			}
			return code;
		}
		
		
	}
}
