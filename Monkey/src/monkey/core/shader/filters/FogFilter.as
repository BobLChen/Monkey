package monkey.core.shader.filters {
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.FcRegisterLabel;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.utils.Color;
	import monkey.core.utils.Device3D;
	
	/**
	 * fog filter 
	 * @author Neil
	 * 
	 */	
	public class FogFilter extends Filter3D {
		
		private var eyeVary 	: ShaderRegisterElement;
		private var _fogConst 	: ShaderRegisterElement;
		private var _fogData 	: Vector.<Number>;
		private var _eyePosData	: Vector.<Number>;
		private var _fogDistance: Number = 1;
		private var _fogColor 	: Color;
		
		/**
		 *  
		 * @param fogDistance	雾气距离
		 * @param color			雾颜色
		 * 
		 */		
		public function FogFilter(fogDistance : Number, color : Color) {
			super("FogFilter");
			this._fogDistance 	= fogDistance;
			this._fogData 	  	= Vector.<Number>([0, 0, 0, 0]);
			this._eyePosData	= Vector.<Number>([0, 0, 0, 0]);
			this.fogColor 		= color;
		}
		
		/**
		 * 设置fog距离 
		 * @param value
		 * 
		 */		
		public function set fogDistance(value : Number) : void {
			if (value <= 0) {
				value = 1;
			}
			this._fogDistance = value;
			this._fogData[3]  = 1 / value;
		}
		
		public function get fogDistance() : Number {
			return _fogDistance;
		}
		
		/**
		 * 雾颜色 
		 * @param value
		 * 
		 */		
		public function set fogColor(value : Color) : void {
			this._fogColor = value;
			this._fogData[0] = value.r;
			this._fogData[1] = value.g;
			this._fogData[2] = value.b;
			this._fogData[3] = 1 / fogDistance;
		}
		
		public function get fogColor() : Color {
			return _fogColor;
		}
		
		override public function update():void {
			this._eyePosData[0] = Device3D.cameraPos.x;
			this._eyePosData[1] = Device3D.cameraPos.y;
			this._eyePosData[2] = Device3D.cameraPos.z;
		}
		
		override public function getFragmentCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			this.eyeVary = regCache.getFreeV();
			
			var fogFc : ShaderRegisterElement = regCache.getFc(1, new FcRegisterLabel(_fogData));
			var ft0   : ShaderRegisterElement = regCache.getFt();
			var code : String = '';
			
			if (agal) {
				code += 'dp3 ' + ft0 + '.w, ' + eyeVary + '.xyz, ' + eyeVary + '.xyz \n';
				// 顶点距离相机距离
				code += 'sqt ' + ft0 + '.w, ' + ft0 + '.w \n';
				// 距离除以distance
				code += 'mul ' + ft0 + '.w, ' + ft0 + '.w, ' + fogFc + ' .w \n';			
				// -1
				code += 'sub ' + ft0 + '.w, ' + ft0 + '.w, ' + regCache.fc0123 + '.y \n';
				// max 0 or dis
				code += 'max ' + ft0 + '.w, ' + regCache.fc0123 + '.x, ' + ft0 + '.w \n';
				code += 'neg ' + ft0 + '.w, ' + ft0 + '.w \n';
				code += 'exp ' + ft0 + '.w, ' + ft0 + '.w \n';
				code += 'sub ' + ft0 + '.xyz, ' + regCache.oc + '.xyz, ' + fogFc + '.xyz \n';
				code += 'mul ' + ft0 + '.xyz, ' + ft0 + '.xyz, ' + ft0 + '.w \n';
				code += 'add ' + regCache.oc + '.xyz, ' + fogFc + '.xyz, ' + ft0 + '.xyz \n';
			}
			
			regCache.removeFt(ft0);
			return code;
		}
		
		override public function getVertexCode(regCache:ShaderRegisterCache, agal:Boolean):String {
			var eyeVc : ShaderRegisterElement = regCache.getVc(1, new VcRegisterLabel(_eyePosData));
			var vt0 : ShaderRegisterElement = regCache.getVt();
			var code : String = '';
			if (agal) {
				code += 'm44 ' + vt0 + ', ' + regCache.getVa(Surface3D.POSITION) + ', ' + regCache.vcWorld + ' \n';			
				code += 'sub ' + eyeVary + ', ' + vt0 + ', ' + eyeVc + ' \n';			
			}
			regCache.removeVt(vt0);
			return code;
		}
				
	}
}
