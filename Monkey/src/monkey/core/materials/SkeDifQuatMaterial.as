package monkey.core.materials {
	
	import monkey.core.materials.shader.SkeDifQuatShader;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;

	/**
	 * 四元数骨骼材质 
	 * @author Neil
	 * 
	 */	
	public class SkeDifQuatMaterial extends Material3D {
		
		private var _texture : Texture3D;
		
		public function SkeDifQuatMaterial(texture : Texture3D) {
			super(SkeDifQuatShader.instance);
			this.texture = texture;
		}
		
		override public function clone():Material3D {
			var c : SkeDifQuatMaterial = new SkeDifQuatMaterial(texture.clone());
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
			SkeDifQuatShader(shader).boneData = Device3D.BoneMatrixs;
			SkeDifQuatShader(shader).texture  = _texture;
		}
		
	}
}
