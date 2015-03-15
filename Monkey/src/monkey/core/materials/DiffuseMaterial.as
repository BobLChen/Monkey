package monkey.core.materials {

	import monkey.core.materials.shader.DiffuseShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;

	public class DiffuseMaterial extends Material3D {
		
		private var _texture : Texture3D;
		
		public function DiffuseMaterial(texture : Texture3D) {
			super(DiffuseShader.instance);
			this.texture = texture;
		}
		
		override public function clone():Material3D {
			var c : DiffuseMaterial = new DiffuseMaterial(texture.clone());
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
		}
		
	}
}
