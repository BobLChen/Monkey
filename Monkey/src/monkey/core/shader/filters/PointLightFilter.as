package monkey.core.shader.filters {
	
	import flash.events.Event;
	
	import monkey.core.base.Surface3D;
	import monkey.core.components.Transform3D;
	import monkey.core.light.PointLight;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.utils.Vector3DUtils;

	/**
	 * 点光 
	 * @author Neil
	 * 
	 */	
	public class PointLightFilter extends LightFilter {
		
		private var _pointData 	: Vector.<Number>;
		private var _light 		: PointLight;
		private var v1			: ShaderRegisterElement;
		
		public function PointLightFilter(light : PointLight) {
			this._pointData = Vector.<Number>([0.0, 0, 0, 10000]);
			this.name 		= "PointLightFilter";
			this.priority 	= 13;
			this.light		= light;
		}
				
		public function set light(value:PointLight):void {
			if (!value) {
				return;
			}
			if (this._light) {
				this._light.removeEventListener(Event.CHANGE, change);
				this._light.transform.removeEventListener(Transform3D.UPDATE_TRANSFORM_EVENT, change);
			}
			this._light = value;
			this._light.addEventListener(Event.CHANGE, change);
			this._light.transform.addEventListener(Transform3D.UPDATE_TRANSFORM_EVENT, change);
			this.change(null);
		}
		
		private function change(e : Event) : void {
			this.ambient    = this._light.ambient;
			this.lightColor = this._light.color;
			this.intensity	= this._light.intensity;
			this._light.transform.getPosition(false, Vector3DUtils.vec0);
			this._pointData[0] = Vector3DUtils.vec0.x;
			this._pointData[1] = Vector3DUtils.vec0.y;
			this._pointData[2] = Vector3DUtils.vec0.z;
			this._pointData[3] = this._light.radius * this._light.radius;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			
			v1 = regCache.getFreeV();
			
			var ft1 : ShaderRegisterElement = regCache.getFt();
			var ft2 : ShaderRegisterElement = regCache.getFt();
			var ft3 : ShaderRegisterElement = regCache.getFt();
			var ft4 : ShaderRegisterElement = regCache.getFt();
			
			var posFc : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_pointData));
			var diffuseFc : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_lightData));
			var fc5 : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_ambientData));
						
			var code : String = "";
			
			code += "mov " + ft1 + ", " + regCache.fc0123 + ".xxxx \n";
			code += "nrm " + ft1 + ".xyz, " + regCache.normalFt + " \n";
			code += "mov " + ft1 + ".w, " + regCache.fc0123 + ".x \n";
			code += "mov " + ft2 + ".xyzw, " + regCache.fc0123 + ".xxxx \n";
			code += "sub " + ft2 + ", " + posFc + ", " + v1 + ".xyzx \n";
			code += "dp3 " + ft1 + ".w, " + ft2 + ", " + ft2 + " \n";
			code += "div " + ft4 + ", " + ft1 + ".w, " + posFc + ".w \n";
			code += "sub " + ft1 + ".w, " + regCache.fc0123 + ".y, " + ft4 + ".x \n";
			code += "max " + ft4 + ".x, " + ft1 + ".w, " + diffuseFc + ".w \n";
			code += "nrm " + ft2 + ".xyz, " + ft2 + " \n";
			code += "dp3 " + ft1 + ".w, " + ft1 + ", " + ft2 + " \n";
			code += "mul " + ft2 + ", " + diffuseFc + ", " + ft4 + ".xxxx \n";
			code += "max " + ft1 + ".x, " + ft1 + ".w, " + regCache.fc0123 + ".x \n";
			code += "mul " + ft4 + ", " + ft1 + ".xxxx, " + ft2 + " \n";
			code += "mov " + ft3 + ", " + ft4 + " \n";
			code += "add " + ft3 + ", " + ft3 + ", " + fc5 + " \n";
			code += "mul " + ft3 + ", " + ft3 + ", " + regCache.oc + " \n";
			code += "mov " + ft3 + ".w, " + regCache.oc + ".w \n";
			code += "sat " + regCache.oc + ", " + ft3 + " \n";
			
			regCache.removeFt(ft1);
			regCache.removeFt(ft2);
			regCache.removeFt(ft3);
			regCache.removeFt(ft4);
			
			return code;
		}
				
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var vt0 : ShaderRegisterElement = regCache.getVt();
			var code : String = "";
			code += "m34 " + v1 + ".xyz, " + regCache.getVa(Surface3D.POSITION) + ", " + regCache.vcWorld + " \n";
			code += "mov " + v1 + ".w, " + regCache.vc0123 + ".y \n";
			regCache.removeVt(vt0);
			return code;
		}
		
	}
}
