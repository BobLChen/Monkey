package monkey.core.shader.filters {
	
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.components.Transform3D;
	import monkey.core.light.DirectionalLight;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.utils.Color;
	import monkey.core.utils.Device3D;
	import monkey.core.utils.Vector3DUtils;
	
	/**
	 * 太阳光filter 
	 * @author Neil
	 * 
	 */	
	public class DirectionalLightFilter extends LightFilter {
		
		private var _light 			: DirectionalLight;		// 平行灯
		private var _dirData		: Vector.<Number>;		// 方向数据
		private var _eyeData		: Vector.<Number>;		// eye
		private var _specular 		: Color;				// 高光
		private var _specularData	: Vector.<Number>;		// 高光数据
		private var _power 			: Number = 50;			// 高光强度
		
		/**
		 * 太阳光filter 
		 * @param light
		 * 
		 */		
		public function DirectionalLightFilter(light : DirectionalLight) {
			this.priority = 13;
			this._specularData 	= Vector.<Number>([1, 1, 1, 1]);
			this._eyeData 		= Vector.<Number>([0, 0, 0, 0]);
			this._dirData 		= Vector.<Number>([0, 0, 0, 0]);
			this.light			= light;
		}
		
		public function set light(light : DirectionalLight) : void {
			
			if (this._light) {
				this._light.removeEventListener(Event.CHANGE, change);
				this._light.transform.removeEventListener(Transform3D.UPDATE_TRANSFORM, change);
			}
			this._light = light;
			this._light.addEventListener(Event.CHANGE, change);
			this._light.transform.addEventListener(Transform3D.UPDATE_TRANSFORM, change);
			light.transform.getDir(false, Vector3DUtils.vec0);
			this.dirData 		= Vector3DUtils.vec0;
			this.lightColor 	= light.color;
			this.power 			= light.power;
			this.ambient 		= light.ambient;
			this.specular 		= light.specular;
		}
		
		/**
		 * 灯光方向改变 
		 * @param event
		 * 
		 */		
		private function change(event:Event) : void {
			this.dirData 	= _light.transform.getDir(true);
			this.lightColor = _light.color;
			this.ambient 	= _light.ambient;
			this.specular 	= _light.specular;
			this.power 		= _light.power;
		}
		
		/**
		 * 高光强度
		 * @param value
		 *
		 */
		public function set power(value : Number) : void {
			this._power = value;
			this._specularData[3] = value;
		}
		
		public function get power() : Number {
			return _power;
		}
		
		/**
		 * 高光 
		 * @return 
		 * 
		 */		
		public function get specular() : Color {
			return _specular;
		}
		
		/**
		 * 高光颜色
		 * @param value
		 * 
		 */		
		public function set specular(value : Color) : void {
			this._specular = value;
			this._specularData[0] = value.r;
			this._specularData[1] = value.g;
			this._specularData[2] = value.b;
		}
		
		/**
		 * 视角位置 
		 * @param pos
		 * 
		 */		
		private function set eyeData(pos : Vector3D):void {
			this._eyeData[0] = pos.x;
			this._eyeData[1] = pos.y;
			this._eyeData[2] = pos.z;
		}
		
		/**
		 * 灯光方向 
		 * @param dir
		 * 
		 */		
		private function set dirData(dir : Vector3D):void {
			dir.normalize();
			this._dirData[0] = -dir.x;
			this._dirData[1] = -dir.y;
			this._dirData[2] = -dir.z;
			this._dirData[3] = 0;
		}
		
		override public function update():void {
			super.update();
			this.eyeData = Device3D.cameraPos;
		}
		
		override public function getFragmentCode(regCache : ShaderRegisterCache, agal:Boolean):String {
			
			var eyeFc    : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_eyeData));
			var specuFc  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_specularData));
			var lightDir : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_dirData));
			var colorFc  : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_lightData));
			var ambFc    : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_ambientData));
						
			var ft0 : ShaderRegisterElement = regCache.getFt();
			var ft1 : ShaderRegisterElement = regCache.getFt();	
			var ft2 : ShaderRegisterElement = regCache.getFt();
			
			var code : String = '';
			
			// 法线ft0
			code += 'mov ' + ft0 + '.xyz, ' + regCache.normalFt + '.xyz \n';
			code += 'sub ' + ft1 + '.xyz, ' + eyeFc + '.xyz, ' + regCache.getV(Surface3D.POSITION) + " \n";
			// camer 法线ft1
			code += 'nrm ' + ft1 + '.xyz, ' + ft1 + '.xyz \n';
			// 高光颜色ft2
			code += 'add ' + ft2 + '.xyz, ' + lightDir + '.xyz, ' + ft1 + '.xyz \n';
			code += 'nrm ' + ft2 + '.xyz, ' + ft2 + '.xyz \n';
			code += 'dp3 ' + ft2 + '.w, ' + ft0 + '.xyz, ' + ft2 + '.xyz \n';
			code += 'max ' + ft2 + '.w, ' + ft2 + '.w, ' + regCache.fc0123 + '.x \n';
			code += 'pow ' + ft2 + '.w, ' + ft2 + '.w, ' + specuFc + '.w \n';
			// 灯光颜色ft0.xyz
			code += 'dp3 ' + ft0 + '.w, ' + ft0 + '.xyz, ' + lightDir + '.xyz \n';
			code += 'max ' + ft0 + '.w, ' + ft0 + '.w, ' + regCache.fc0123 + '.x \n';
			code += 'mul ' + ft0 + '.xyz, ' + colorFc + '.xyz, ' + ft0 + '.w \n';
			// sat 灯光颜色
			code += 'sat ' + ft0 + '.xyz, ' + ft0 + '.xyz \n';
			// 灯光颜色=灯光颜色+环境色
			code += 'add ' + ft0 + '.xyz, ' + ft0 + '.xyz, ' + ambFc + '.xyz \n';
			code += 'mul ' + ft0 + '.xyz, ' + ft0 + '.xyz, ' + regCache.oc + '.xyz \n';
			// 高光颜色*高光
			code += 'mul ' + ft2 + '.xyz, ' + ft2 + '.w, ' + specuFc + '.xyz \n';
			code += 'add ' + ft0 + '.xyz, ' + ft0 + '.xyz, ' + ft2 + '.xyz \n';
			// 强度
			code += 'mul ' + regCache.oc + '.xyz, ' + ft0 + '.xyz, ' + colorFc + '.w \n';
						
			regCache.removeFt(ft0);
			regCache.removeFt(ft1);
			regCache.removeFt(ft2);
			
			return code;
		}
		
	}
}
