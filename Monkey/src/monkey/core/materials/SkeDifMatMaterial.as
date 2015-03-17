package monkey.core.materials {
	
	import monkey.core.materials.shader.SkeDifMatShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;

	public class SkeDifMatMaterial extends Material3D {
		
		private var _texture : Texture3D;
		
		public function SkeDifMatMaterial(texture : Texture3D) {
			super(SkeDifMatShader.instance);
			this.texture = texture;
		}
		
		override public function clone():Material3D {
			var c : SkeDifMatMaterial = new SkeDifMatMaterial(texture.clone());
			return c;
		}
		
		override public function dispose(force:Boolean=false):void {
			super.dispose(force);
			this.texture.dispose(force);
		}
				
		public function get texture():Texture3D {
			return _texture;
		}

		public function set texture(value:Texture3D):void {
			_texture = value;
		}
		
		override public function updateMaterial(scene:Scene3D):void {
			this._texture.upload(scene);
			SkeDifMatShader(shader).boneData = Device3D.BoneMatrixs;
			SkeDifMatShader(shader).texture  = _texture;
		}
		
	}
}
