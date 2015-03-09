package monkey.core.shader.filters {

	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	import monkey.core.base.Surface3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Matrix3DUtils;
	
	/**
	 * 粒子系统filter
	 * 粒子位置由cpu生成
	 * 粒子的速度和方向绑定到一起
	 * 粒子的startColor由顶点颜色决定
	 * 粒子的lifetime color用贴图实现
	 * 粒子的lifetime transform由6个关键字决帧。强制为6个关键帧。
	 * @author Neil
	 *
	 */
	public class ParticleSystemFilter extends Filter3D {
		
		public static const RADIANS_TO_DEGREES : Number = 180 / Math.PI;
				
		public var billboard 		: Boolean = false;			// 广告牌
		private var timeData  		: Vector.<Number>;			// 时间数据
		private var frameData		: Vector.<Number>;			// uv动画数据
		private var textureLabel    : FsRegisterLabel;			// 粒子贴图
		private var blendedLabel 	: FsRegisterLabel;			// 混合贴图
		private var keyframeLabel	: VcRegisterLabel;			// lifetime关键帧
		private var timeVary 	 	: ShaderRegisterElement;	// 时间v寄存器
		private var billboardMatrix	: Matrix3D;					// 广告牌
		private var billboardLabel  : VcRegisterLabel;			// 广告牌
		
		/**
		 * 粒子系统filter 
		 * @param texture		粒子贴图
		 * @param blend			color overt lifetime
		 * 
		 */		
		public function ParticleSystemFilter() {
			super("ParticleSystemFilter");
			this.priority 		 = 14;
			this.timeData	  	 = Vector.<Number>([0, 0, 1, 5]);
			this.frameData		 = Vector.<Number>([1, 1, 1, 1]);
			this.blendedLabel 	 = new FsRegisterLabel(null);
			this.textureLabel 	 = new FsRegisterLabel(null);
			this.keyframeLabel	 = new VcRegisterLabel(null);
			this.billboardMatrix = new Matrix3D();
			this.billboardLabel  = new VcRegisterLabel(billboardMatrix);
			this.frame			 = new Point(1, 1);
		}
		
		override public function update():void {
			if (billboard) {
				Matrix3DUtils.setOrientation(billboardMatrix, Device3D.cameraDir);
			} else {
				this.billboardMatrix.identity();
			}
		}
		
		/**
		 * uv动画 
		 * @param value		value.x为行数，value.y为列数
		 * 
		 */		
		public function set frame(value : Point) : void {
			this.frameData[0] = value.y * value.x - 1;
			this.frameData[1] = 1 / value.y;
			this.frameData[2] = 1 / value.x;
			this.frameData[3] = value.y;
		}
		
		/**
		 * 整个粒子系统的生命周期 
		 * @param value
		 * 
		 */		
		public function set totalLife(value : Number) : void {
			this.timeData[3] = value;
		}
		
		/**
		 * 必须为16 * 6长度,强制使用5个关键帧
		 * @param bytes
		 * 
		 */		
		public function set keyframe(bytes : ByteArray) : void {
			keyframeLabel.bytes = bytes;	
		}
				
		/**
		 * 设置混合贴图(Color Over Lifetime)
		 * @param texture
		 * 
		 */		
		public function set blendTexture(texture : Texture3D) : void {
			this.blendedLabel.texture = texture;
		}
		
		/**
		 * 设置贴图 
		 * @param texture
		 * 
		 */		
		public function set texture(texture : Texture3D) : void {
			this.textureLabel.texture = texture;
		}
		
		/**
		 * 设置粒子当前时间 
		 * @param value
		 * 
		 */		
		public function set time(value : Number) : void {
			this.timeData[0] = value;
		}
		
		public function get time() : Number {
			return timeData[0];
		}
						
		/**
		 * 片段着色器 
		 * @param regCache
		 * @return 
		 * 
		 */		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			this.timeVary = regCache.getFreeV();
			var fs0 : ShaderRegisterElement = regCache.getFs(textureLabel);
			var fs1 : ShaderRegisterElement = regCache.getFs(blendedLabel);
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var code : String = "";
			if (agal) {
				// 粒子贴图
				code += "tex " + regCache.oc + ", " + regCache.getV(Surface3D.UV0) + ", " + fs0 + "<2d, linear, miplinear, repeat> \n";
				// 混合顶点颜色
				code += "mul " + regCache.oc + ".xyz, " + regCache.oc + ".xyz, " + regCache.getV(Surface3D.CUSTOM3) + ".xyz \n";
				code += "mul " + regCache.oc + ".xyz, " + regCache.oc + ".xyz, " + regCache.getV(Surface3D.CUSTOM3) + ".w \n";
				// 采样混合贴图(color over lifetime)
				code += "mov " + ft0 + ".xyzw, " + regCache.fc0123 + ".xxxx \n";
				code += "mov " + ft0 + ".x, " + timeVary + ".y \n";
				code += "tex " + ft0 + ", " + ft0 + ".xy, " + fs1 + "<2d, linear, miplinear, clamp> \n";
				// 混合
				code += "mul " + regCache.oc + ", " + regCache.oc + ", " + ft0 + " \n";				
			}
			regCache.removeFt(ft0);
			return code;
		}
		
		/**
		 * 顶点程序 
		 * @param regCache
		 * @return 
		 * 
		 */		
		override public function getVertexCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			
			// 速度
			var speedVa : ShaderRegisterElement = regCache.getVa(Surface3D.CUSTOM1);
			// 时间:timeVa.x=>起始时间;timeVa.y=>lifetime
			var timeVa  : ShaderRegisterElement = regCache.getVa(Surface3D.CUSTOM2);
			// 当前时间
			var timeVc  : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(timeData));
			// 缩放 旋转 速度关键帧
			var keysVc 	: ShaderRegisterElement = regCache.getVc(ParticleSystem.MAX_KEY_NUM * 4, keyframeLabel);
			// step
			var stepVc 	: ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(Vector.<Number>([ParticleSystem.MAX_KEY_NUM - 1, 4, keysVc.index, 3])));
			// billboard
			var billVc  : ShaderRegisterElement = regCache.getVc(4, billboardLabel);
			// uv
			var frameVc : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(frameData));
			
			var vt0 : ShaderRegisterElement = regCache.getVt();			// 临时变量
			var vt1 : ShaderRegisterElement = regCache.getVt();			// 粒子时间
			var vt2 : ShaderRegisterElement = regCache.getVt();			// left， 左边关键帧
			var vt3 : ShaderRegisterElement = regCache.getVt();			// right，右边关键帧
			
			var code : String = "";
			
			if (agal) {
				// 当前时间-延时
				code += "sub " + vt1 + ".w, " + timeVc + ".x, " + timeVa + ".x \n";				
				// 计算循环次数
				// vt1.z = 时间/粒子生命周期
				code += "div " + vt1 + ".z, " + vt1 + ".w, " + timeVc + ".w \n";
				code += "frc " + vt1 + ".x, " + vt1 + ".z \n";
				code += "sub " + vt1 + ".z, " + vt1 + ".z, " + vt1 + ".x \n";
				// 循环次数 * duration
				code += "mul " + vt1 + ".z, " + vt1 + ".z, " + timeVc + ".w \n";
				// 当前时间 - 循环次数 * duration
				code += "sub " + vt1 + ".x, " + timeVc + ".x, " + vt1 + ".z \n";
				// 减去延时
				code += "sub " + vt1 + ".x, " + vt1 + ".x, " + timeVa + ".x \n";
				// 计算比率
				code += "div " + vt1 + ".y, " + vt1 + ".x, " + timeVa + ".y \n";
				// 根据时间计算出当前关键帧的索引:例如比率 * 10 => 0.34 * 5 = 1.7
				code += "mul " + vt0 + ".x, " + vt1 + ".y, " + stepVc + ".x \n";
				// 取分数: 1.7 => 0.7
				code += "frc " + vt0 + ".y, " + vt0 + ".x \n";
				// 获取整数部分: => 1.7 - 0.7 = 1.0
				code += "sub " + vt0 + ".x, " + vt0 + ".x, " + vt0 + ".y \n";
				
				// 当前时间:vt1.x
				// 当前比率:vt1.y
				// 当前索引:vt0.x
				
				// 跳转到矩阵
				// vt0.z = 4
				code += "mov " + vt0 + ".z, " + stepVc + ".y \n";
				// vt0.z = 4 * 3 = 12 (0, 4, 8, 12 ....36)
				code += "mul " + vt0 + ".z, " + vt0 + ".z, " + vt0 + ".x \n";
				// vt0.z = vt0.z + index
				code += "add " + vt0 + ".z, " + vt0 + ".z, " + stepVc + ".z \n";
				// m33 应用旋转和缩放
				code += "m33 " + vt2 + ".xyz, " + regCache.op + ".xyz, " + "vc[" + vt0 + ".z" + "]\n";		// 乘以左边矩阵
				code += "add " + vt0 + ".z, " + vt0 + ".z, " + stepVc + ".y \n";							// 偏移4个
				code += "m33 " + vt3 + ".xyz, " + regCache.op + ".xyz, " + "vc[" + vt0 + ".z" + "]\n";		// 乘以右边矩阵
				// 线性插值
				code += "sub " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt2 + ".xyz \n";
				code += "mul " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt0 + ".y \n";
				code += "add " + regCache.op + ".xyz, " + vt2 + ".xyz, " + vt3 + ".xyz \n";
				// 最后一个vc为位移->偏移3个
				code += "add " + vt0 + ".z, " + vt0 + ".z, " + stepVc + ".w \n";							// 右边位移
				code += "mov " + vt3 + ", " + "vc[" + vt0 + ".z" + "]\n";									// 获取右边位移
				code += "sub " + vt0 + ".z, " + vt0 + ".z, " + stepVc + ".y \n";							// 左移四个得到左边位移
				code += "mov " + vt2 + ", " + "vc[" + vt0 + ".z" + "]\n";									// 获取左边位移
				// 线性插值
				code += "sub " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt2 + ".xyz \n";
				code += "mul " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt0 + ".y \n";
				code += "add " + vt2 + ".xyz, " + vt2 + ".xyz, " + vt3 + ".xyz \n";
				code += "mul " + vt2 + ".xyz, " + vt2 + ".xyz, " + timeVa + ".y \n";
				code += "div " + vt2 + ".xyz, " + vt2 + ".xyz, " + vt2 + ".w \n";
				// 速度 * 时间
				code += "mul " + vt3 + ".xyz, " + speedVa + ".xyz, " + vt1 + ".x \n";
				// lifetime位移 + 速度 * 时间 + offset
				code += "add " + vt0 + ".xyz, " + vt2 + ".xyz, " + vt3 + ".xyz \n";
				code += "add " + vt0 + ".xyz, " + vt0 + ".xyz, " + regCache.getVa(Surface3D.CUSTOM4) + " \n";
				// 广告牌
				code += "m33 " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + billVc + " \n";
				// 顶点 + 最终位移
				code += "add " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + vt0 + ".xyz \n";
				
				// =============uv动画=============
				code += "mul " + vt2 + ".xy, " + regCache.getVa(Surface3D.UV0) + ".xy, " + frameVc + ".yz \n";
				// 计算总量
				code += "mul " + vt3 + ".x, " + vt1 + ".y, " + frameVc + ".x \n";	// 计算出总量
				code += "frc " + vt3 + ".y, " + vt3 + ".x \n";
				code += "sub " + vt3 + ".x, " + vt3 + ".x, " + vt3 + ".y \n";
				// 计算出行数
				code += "mul " + vt3 + ".z, " + vt3 + ".x, " + frameVc + ".y \n";
				code += "frc " + vt3 + ".y, " + vt3 + ".z \n";
				code += "sub " + vt3 + ".z, " + vt3 + ".z, " + vt3 + ".y \n";
				// 计算列索引
				code += "mul " + vt3 + ".w, " + vt3 + ".y, " + frameVc + ".w \n";
				// 
				code += "mov " + vt2 + ".zw, " + frameVc + ".yzyz \n";
				code += "mul " + vt2 + ".zw, " + vt2 + ".zwzw, " + vt3 + ".wzwz \n";
				code += "add " + vt2 + ".xy, " + vt2 + ".xyxy, " + vt2 + ".zwzw \n";
				code += "mov " + regCache.getV(Surface3D.UV0) + ".xy, " + vt2 + ".xy \n";
				// =============uv动画=============
				
				// 当前时间 < 0 时不显示 vt1.z = vt1.w >= 0 ? 1 : 0;
				code += "sge " + vt0 + ".x, " + vt1 + ".w, " + timeVc + ".y \n";
				// 当前时间 >= 生命周期时不显示 vt1.z = 1 - (vt1.w >= timeVa.y ? 1 : 0);
				code += "add " + vt1 + ".z, " + vt1 + ".z, " + timeVa + ".y \n";
				code += "sge " + vt1 + ".z, " + vt1 + ".w, " + vt1 + ".z \n";
				code += "sub " + vt1 + ".z, " + timeVc + ".z, " + vt1 + ".z \n";
				code += "mul " + vt0 + ".x, " + vt0 + ".x, " + vt1 + ".z \n";
				// mul
				code += "mul " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + vt0 + ".x \n";
				// 将时间参数传递给fragment着色器
				code += "mov " + timeVary + ", " + vt1 + " \n";	
			}
			
			regCache.removeVt(vt3);
			regCache.removeVt(vt2);
			regCache.removeVt(vt1);
			regCache.removeVt(vt0);
			
			return code;
		}
		
	}
}
