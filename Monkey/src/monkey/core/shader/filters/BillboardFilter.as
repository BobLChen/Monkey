package monkey.core.shader.filters {

	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	
	import monkey.core.base.Surface3D;
	import monkey.core.shader.utils.ShaderRegisterCache;
	import monkey.core.shader.utils.ShaderRegisterElement;
	import monkey.core.shader.utils.VcRegisterLabel;
	import monkey.core.utils.Device3D;

	/**
	 * 广告牌
	 * @author Neil
	 *
	 */
	public class BillboardFilter extends Filter3D {

		public static const RADIANS_TO_DEGREES : Number = 180 / Math.PI;

		private var matrix : Matrix3D = new Matrix3D();

		public function BillboardFilter() {
			super("BillboardFilter");
			this.priority = 10;
		}
		
		override public function update():void {
			this.matrix.copyFrom(Device3D.world);
			this.matrix.append(Device3D.view);
			var comps : Vector.<Vector3D> = matrix.decompose(Orientation3D.AXIS_ANGLE);
			this.matrix.identity();
			this.matrix.appendRotation(-comps[1].w * RADIANS_TO_DEGREES, comps[1]);
		}
		
		override public function getVertexCode(regCache : ShaderRegisterCache, agal : Boolean) : String {
			var rotate : ShaderRegisterElement = regCache.getVc(4, new VcRegisterLabel(matrix));
			var code : String = "";
			if (agal) {
				code += "m33 " + regCache.op + ".xyz, " + regCache.getVa(Surface3D.POSITION) + ".xyz, " + rotate + " \n";				
			}
			return code;
		}

	}
}
