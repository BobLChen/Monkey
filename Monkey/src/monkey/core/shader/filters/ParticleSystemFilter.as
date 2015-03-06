package monkey.core.shader.filters {

	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FsRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;
	
	/**
	 * 粒子系统filter
	 * 粒子位置由cpu生成
	 * 粒子的速度和方向绑定到一起
	 * 粒子的startColor由顶点颜色决定
	 * 粒子的lifetime color用贴图实现
	 * 粒子的lifetime transform由11个关键字决帧。强制为11个关键帧。
	 * @author Neil
	 *
	 */
	public class ParticleSystemFilter extends Filter3D {
		
		public static const RADIANS_TO_DEGREES : Number = 180 / Math.PI;
		
		/** 是否开启广告牌 */
		public var billboard : Boolean = false;					// 广告牌
		
		private var timeData  		: Vector.<Number>;			// 时间数据
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
			this.priority = 14;
			this.timeData	  = Vector.<Number>([0, 0, 1, 5]);
			this.blendedLabel = new FsRegisterLabel(null);
			this.textureLabel = new FsRegisterLabel(null);
			this.keyframeLabel= new VcRegisterLabel(null);
			this.billboardMatrix = new Matrix3D();
			this.billboardLabel  = new VcRegisterLabel(billboardMatrix);
		}
		
		override public function update():void {
			if (billboard) {
				this.billboardMatrix.copyFrom(Device3D.world);
				this.billboardMatrix.append(Device3D.view);
				var comps : Vector.<Vector3D> = billboardMatrix.decompose(Orientation3D.AXIS_ANGLE);
				this.billboardMatrix.identity();
				this.billboardMatrix.appendRotation(-comps[1].w * RADIANS_TO_DEGREES, comps[1]);
			} else {
				this.billboardMatrix.identity();
			}
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
		 * 必须为16 * 11长度 
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
			var keysVc 	: ShaderRegisterElement = regCache.getVc(44, keyframeLabel);
			// step
			var stepVc 	: ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(Vector.<Number>([10, 4, keysVc.index, 3])));
			// billboard
			var billVc  : ShaderRegisterElement = regCache.getVc(4, billboardLabel);
			
			var vt0 : ShaderRegisterElement = regCache.getVt();		// 临时变量
			var vt1 : ShaderRegisterElement = regCache.getVt();		// 粒子时间
			var vt2 : ShaderRegisterElement = regCache.getVt();		// left， 左边关键帧
			var vt3 : ShaderRegisterElement = regCache.getVt();		// right，右边关键帧
			
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
				// 根据时间计算出当前关键帧的索引:例如比率 * 10 => 0.34 * 10 = 3.4
				code += "mul " + vt0 + ".x, " + vt1 + ".y, " + stepVc + ".x \n";
				// 取分数: 3.4 => 0.4
				code += "frc " + vt0 + ".y, " + vt0 + ".x \n";
				// 获取整数部分: => 3.4 - 0.4 = 3.0
				code += "sub " + vt0 + ".x, " + vt0 + ".x, " + vt0 + ".y \n";
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
				// 最后一个vc为速度->偏移3个
				code += "add " + vt0 + ".z, " + vt0 + ".z, " + stepVc + ".w \n";							// 右边速度
				code += "mov " + vt3 + ".xyz, " + "vc[" + vt0 + ".z" + "]\n";								// 获取右边速度
				code += "sub " + vt0 + ".z, " + vt0 + ".z, " + stepVc + ".y \n";							// 左移四个得到左边速度
				code += "mov " + vt2 + ".xyz, " + "vc[" + vt0 + ".z" + "]\n";								// 获取左边速度
				// 线性插值
				code += "sub " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt2 + ".xyz \n";
				code += "mul " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt0 + ".y \n";
				code += "add " + vt2 + ".xyz, " + vt2 + ".xyz, " + vt3 + ".xyz \n";
				// 速度 + speed over lifetime			
				code += "add " + vt2 + ".xyz, " + vt2 + ".xyz, " + speedVa + ".xyz \n";
				// 速度乘以时间
				code += "mul " + vt0 + ".xyz, " + vt2 + ".xyz, " + vt1 + ".x \n";
								
				// billboard
				code += "m33 " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + billVc + " \n";
				// 位置 + 速度
				code += "add " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + vt0 + ".xyz \n";
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
