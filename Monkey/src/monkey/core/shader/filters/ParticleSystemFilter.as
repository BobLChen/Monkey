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
			const SIZE  : int = ParticleSystem.MAX_KEY_NUM;
			// 速度
			var speedVa : ShaderRegisterElement = regCache.getVa(Surface3D.CUSTOM1);
			// 时间:timeVa.x=>起始时间;timeVa.y=>lifetime
			var timeVa  : ShaderRegisterElement = regCache.getVa(Surface3D.CUSTOM2);
			// 当前时间
			var timeVc  : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(timeData));
			// 旋转 缩放 位移 关键帧
			var keysVc 	: ShaderRegisterElement = regCache.getVc(SIZE * 3, keyframeLabel);
			// step
			var stepVc 	: ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(Vector.<Number>([SIZE - 1, SIZE, keysVc.index, 3])));
			// billboard
			var billVc  : ShaderRegisterElement = regCache.getVc(4, billboardLabel);
			// uv
			var frameVc : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(frameData));
			
			var vtKey 	: ShaderRegisterElement = regCache.getVt();			// 临时变量
			var vtTime 	: ShaderRegisterElement = regCache.getVt();			// 粒子时间
			var vt2 	: ShaderRegisterElement = regCache.getVt();			// left， 左边关键帧
			var vt3 	: ShaderRegisterElement = regCache.getVt();			// right，右边关键帧
			var rotAxis : ShaderRegisterElement = regCache.getVt();
			var xAxis 	: ShaderRegisterElement = regCache.getVt();
			var temp 	: ShaderRegisterElement = regCache.getVt();
			var cos 	: String = temp + ".x";
			var sin 	: String = temp + ".y";
			var cos2 	: String = temp + ".z";
			var single 	: String = temp + ".w";
			var R 		: ShaderRegisterElement = vt2;
			var R_rev 	: ShaderRegisterElement = vt3;
									
			var code : String = "";
			
			if (agal) {
				// 当前时间-延时
				code += "sub " + vtTime + ".w, " + timeVc + ".x, " + timeVa + ".x \n";				
				// 计算循环次数
				// vt1.z = 时间/粒子生命周期
				code += "div " + vtTime + ".z, " + vtTime + ".w, " + timeVc + ".w \n";
				code += "frc " + vtTime + ".x, " + vtTime + ".z \n";
				code += "sub " + vtTime + ".z, " + vtTime + ".z, " + vtTime + ".x \n";
				// 循环次数 * duration
				code += "mul " + vtTime + ".z, " + vtTime + ".z, " + timeVc + ".w \n";
				// 当前时间 - 循环次数 * duration
				code += "sub " + vtTime + ".x, " + timeVc + ".x, " + vtTime + ".z \n";
				// 减去延时
				code += "sub " + vtTime + ".x, " + vtTime + ".x, " + timeVa + ".x \n";
				// 计算比率
				code += "div " + vtTime + ".y, " + vtTime + ".x, " + timeVa + ".y \n";
				
				
				// 计算当前关键帧
				code += "mul " + vtKey + ".x, " + vtTime + ".y, " + stepVc + ".x \n";
				// 取分数: 1.7 => 0.7
				code += "frc " + vtKey + ".y, " + vtKey + ".x \n";
				// 获取整数部分: => 1.7 - 0.7 = 1.0，得到关键帧索引
				code += "sub " + vtKey + ".x, " + vtKey + ".x, " + vtKey + ".y \n";
				// vt0.x=>关键帧索引；vt0.y=>插值
				
				// 旋转,插值
				code += "mov " + vt2 + ".xyzw, " + "vc[" + vtKey + ".x+" + (keysVc.index + 0) + "].xyzw \n";
				code += "mov " + vt3 + ".xyzw, " + "vc[" + vtKey + ".x+" + (keysVc.index + 1) + "].xyzw \n";
				code += "sub " + vt3 + ".xyzw, " + vt3 + ".xyzw, " + vt2 + ".xyzw \n";
				code += "mul " + vt3 + ".xyzw, " + vt3 + ".xyzw, " + vtKey + ".y  \n";
				code += "add " + vt2 + ".xyzw, " + vt2 + ".xyzw, " + vt3 + ".xyzw \n";
				// 旋转
				code += "mov " + rotAxis + ".xyzw," + vt2 + ".xyzw \n";
				code += "mov " + single + "," + rotAxis + ".w\n";
				code += "cos " + cos + "," + single + "\n";
				code += "sin " + sin + "," + single + "\n";
				code += "mul " + R + ".xyz," + sin + "," + rotAxis + ".xyz\n";
				code += "neg " + R_rev + ".xyz," + R + ".xyz\n";
				code += "crs " + rotAxis + ".xyz," + R + ".xyz," + regCache.op + ".xyz\n";
				code += "mul " + xAxis + ".xyz," + cos + "," + regCache.op + ".xyz\n";
				code += "add " + rotAxis + ".xyz," + rotAxis + ".xyz," + xAxis + ".xyz\n";
				code += "dp3 " + xAxis + ".w," + R + ".xyz," + regCache.op + ".xyz\n";
				code += "neg " + rotAxis + ".w," + xAxis + ".w\n";
				code += "crs " + R + ".xyz," + rotAxis + ".xyz," + R_rev + ".xyz\n";
				code += "mul " + xAxis + ".xyzw," + rotAxis + ".xyzw," + cos + "\n";
				code += "add " + R + ".xyz," + R + ".xyz," + xAxis + ".xyz\n";
				code += "mul " + xAxis + ".xyz," + rotAxis + ".w," + R_rev + ".xyz\n";
				code += "add " + regCache.op + "," + R + ".xyz," + xAxis + ".xyz\n";
				code += "mov " + regCache.op + ".w, " + regCache.vc0123 + ".y \n";
				// 缩放
				code += "mul " + vt2 + ".xyz, " + regCache.op + ".xyz, " + "vc[" + vtKey + ".x+" + (keysVc.index + SIZE + 0) + "].x \n";
				code += "mul " + vt3 + ".xyz, " + regCache.op + ".xyz, " + "vc[" + vtKey + ".x+" + (keysVc.index + SIZE + 1) + "].x \n";
				code += "sub " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt2 + ".xyz \n";
				code += "mul " + vt3 + ".xyz, " + vt3 + ".xyz, " + vtKey + ".y \n";
				code += "add " + regCache.op + ".xyz, " + vt2 + ".xyz, " + vt3 + ".xyz \n";
				// 位移
				code += "mov " + vt2 + ".xyzw, " + "vc[" + vtKey + ".x+" + (keysVc.index + SIZE * 2 + 0) + "].xyzw \n";
				code += "mov " + vt3 + ".xyzw, " + "vc[" + vtKey + ".x+" + (keysVc.index + SIZE * 2 + 1) + "].xyzw \n";
				code += "sub " + vt3 + ".xyz, " + vt3 + ".xyz, " + vt2 + ".xyz \n";
				code += "mul " + vt3 + ".xyz, " + vt3 + ".xyz, " + vtKey + ".y \n";
				code += "add " + vt2 + ".xyz, " + vt2 + ".xyz, " + vt3 + ".xyz \n";
				code += "mul " + vt2 + ".xyz, " + vt2 + ".xyz, " + timeVa + ".y \n";
				code += "div " + vt2 + ".xyz, " + vt2 + ".xyz, " + vt2 + ".w \n";
				
				// 速度 * 时间
				code += "mul " + vt3 + ".xyz, " + speedVa + ".xyz, " + vtTime + ".x \n";
				// lifetime位移 + 速度 * 时间 + offset
				code += "add " + vtKey + ".xyz, " + vt2 + ".xyz, " + vt3 + ".xyz \n";
				code += "add " + vtKey + ".xyz, " + vtKey + ".xyz, " + regCache.getVa(Surface3D.CUSTOM4) + " \n";
				// 广告牌
				code += "m33 " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + billVc + " \n";
				// 顶点 + 最终位移
				code += "add " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + vtKey + ".xyz \n";
				
				// =============uv动画=============
				code += "mul " + vt2 + ".xy, " + regCache.getVa(Surface3D.UV0) + ".xy, " + frameVc + ".yz \n";
				// 计算总量
				code += "mul " + vt3 + ".x, " + vtTime + ".y, " + frameVc + ".x \n";	// 计算出总量
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
				code += "sge " + vtKey + ".x, " + vtTime + ".w, " + timeVc + ".y \n";
				// 当前时间 >= 生命周期时不显示 vt1.z = 1 - (vt1.w >= timeVa.y ? 1 : 0);
				code += "add " + vtTime + ".z, " + vtTime + ".z, " + timeVa + ".y \n";
				code += "sge " + vtTime + ".z, " + vtTime + ".w, " + vtTime + ".z \n";
				code += "sub " + vtTime + ".z, " + timeVc + ".z, " + vtTime + ".z \n";
				code += "mul " + vtKey + ".x, " + vtKey + ".x, " + vtTime + ".z \n";
				// mul
				code += "mul " + regCache.op + ".xyz, " + regCache.op + ".xyz, " + vtKey + ".x \n";
				// 将时间参数传递给fragment着色器
				code += "mov " + timeVary + ", " + vtTime + " \n";	
			}
			
			regCache.removeVt(vt3);
			regCache.removeVt(vt2);
			regCache.removeVt(vtTime);
			regCache.removeVt(vtKey);
			
			regCache.removeVt(rotAxis);
			regCache.removeVt(xAxis);
			regCache.removeVt(temp);
			
			return code;
		}
		
	}
}
