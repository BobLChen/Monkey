package monkey.core.textures {
	
	import flash.display3D.Context3DTextureFormat;
	import flash.events.Event;

	public class RttTexture extends Texture3D {
		
		public function RttTexture(width : int, height : int) {
			super();
			this.typeMode 	= TYPE_2D;
			this.magMode 	= MAG_LINEAR;
			this.wrapMode  	= WRAP_REPEAT;
			this.mipMode	= MIP_LINEAR;
			this._width 	= width;
			this._height	= height;
		}
		
		override protected function contextEvent(e:Event=null):void {
			super.contextEvent(e);
			this.texture = this.scene.context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
			this.scene.context.setRenderToTexture(texture, true);
			this.scene.context.clear(0, 0, 0, 0);
			this.scene.context.setRenderToBackBuffer();
		}
		
	}
}
