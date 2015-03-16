package monkey.core.materials {

	import monkey.core.materials.shader.DiffuseShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;

	public class DiffuseMaterial extends Material3D {
		
		private var _texture : Texture3D;
		private var _offsetX : Number = 0;
		private var _offsetY : Number = 0;
		private var _repeatX : Number = 1;
		private var _repeatY : Number = 1;
		
		public function DiffuseMaterial(texture : Texture3D) {
			super(DiffuseShader.instance);
			this.texture = texture;
		}
		
		public function get repeatY():Number {
			return _repeatY;
		}

		public function set repeatY(value:Number):void {
			_repeatY = value;
		}

		public function get repeatX():Number {
			return _repeatX;
		}

		public function set repeatX(value:Number):void {
			_repeatX = value;
		}

		public function get offsetY():Number {
			return _offsetY;
		}

		public function set offsetY(value:Number):void {
			_offsetY = value;
		}

		public function get offsetX():Number {
			return _offsetX;
		}

		public function set offsetX(value:Number):void {
			_offsetX = value;
		}

		override public function clone():Material3D {
			var c : DiffuseMaterial = new DiffuseMaterial(texture.clone());
			c.copyFrom(this);
			c._repeatX = _repeatX;
			c._repeatY = _repeatY;
			c._offsetX = _offsetX;
			c._offsetY = _offsetY;
			return c;
		}
		
		public function get texture():Texture3D {
			return _texture;
		}

		public function set texture(value:Texture3D):void {
			_texture = value;
		}
		
		override public function dispose():void {
			super.dispose();
			this.texture.dispose();
		}
		
		override protected function setShaderDatas(scene:Scene3D):void {
			this.texture.upload(scene);
			DiffuseShader(shader).texture = this.texture;	
			DiffuseShader(shader).tillingOffset(repeatX, repeatY, offsetX, offsetY);
		}
		
	}
}
