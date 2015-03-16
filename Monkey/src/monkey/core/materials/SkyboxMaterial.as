package monkey.core.materials {

	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.materials.shader.SkyboxShader3D;
	import monkey.core.scene.Scene3D;
	import monkey.core.textures.Texture3D;
	import monkey.core.utils.Device3D;

	public class SkyboxMaterial extends Material3D {
		
		private var _textures : Vector.<Texture3D>;
		
		public function SkyboxMaterial(textures : Array) {
			super(SkyboxShader3D.instance);
			this.textures = Vector.<Texture3D>(textures);
		}
		
		public function get textures():Vector.<Texture3D> {
			return _textures;
		}
		
		public function set textures(value:Vector.<Texture3D>):void {
			_textures = value;
		}
		
		override public function clone():Material3D {
			var c : SkyboxMaterial = new SkyboxMaterial([]);
			c.copyFrom(this);
			for each (var texture : Texture3D in textures) {
				c.textures.push(texture.clone());
			}
			return c;
		}
		
		override public function dispose():void {
			super.dispose();
			for each (var texture : Texture3D in textures) {
				texture.dispose();
			}
		}
		
		override public function draw(scene:Scene3D, mesh:Mesh3D):void {
			// 修改混合、深度测试、裁减
			if (_stateDirty) {
				scene.context.setBlendFactors(sourceFactor, destFactor);
				scene.context.setDepthTest(depthWrite, depthCompare);
				scene.context.setCulling(cullFace);
			}
			for (var i:int = 0; i < textures.length; i++) {
				textures[i].upload(scene);
				SkyboxShader3D(shader).texture = textures[i];
				var surf : Surface3D = mesh.surfaces[i];
				shader.draw(scene, surf, 0, surf.numTriangles);
			}
			// 重置回默认状态
			if (_stateDirty) {
				scene.context.setBlendFactors(Device3D.defaultSourceFactor, Device3D.defaultDestFactor);
				scene.context.setDepthTest(Device3D.defaultDepthWrite, Device3D.defaultCompare);
				scene.context.setCulling(Device3D.defaultCullFace);
			}
		}
		
	}
}
