package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import monkey.core.base.Object3D;
	import monkey.core.base.Surface3D;
	import monkey.core.entities.Mesh3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.materials.Material3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Viewer3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.TextureMapFilter;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.FPSStats;

	public class TestUnityLightmap extends Sprite {
		
		[Embed(source="../assets/AssetsCube.mesh", mimeType="application/octet-stream")]
		private var DATA  : Class;
		
		[Embed(source="../assets/141E5945-DF53-4D9B-BAA8-F01661E792B7.png")]
		private var IMAGE : Class;
		
		private var scene : Viewer3D;
		
		public function TestUnityLightmap() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;  
			this.scene.camera.transform.z = -3;
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.addChild(new FPSStats());
			
			var obj : Object3D = new Object3D();
			obj.addComponent(new MeshRenderer(new Cube(), new ColorMaterial(Color.GRAY)));
//			this.scene.addChild(obj);
			
//			this.addChild(new IMAGE());  
			
			var bytes : ByteArray = new DATA();
			bytes.endian = Endian.LITTLE_ENDIAN;
			var len : int = bytes.readInt();
			trace("顶点:", len);
			
			var vert : ByteArray = new ByteArray();
			vert.endian = Endian.LITTLE_ENDIAN;
			bytes.readBytes(vert, 0, len);
			
			len = bytes.readInt();
			trace("uv1:", len);
			var uv1 : ByteArray = new ByteArray();
			uv1.endian = Endian.LITTLE_ENDIAN;
			bytes.readBytes(uv1, 0, len);
			
			len = bytes.readInt();    
			trace("uv2:", len);
			var uv2 : ByteArray = new ByteArray();
			uv2.endian = Endian.LITTLE_ENDIAN;
			bytes.readBytes(uv2, 0, len);
			
			var uobj : Object3D  = new Object3D();
			var surf : Surface3D = new Surface3D();
			surf.setVertexBytes(Surface3D.POSITION, vert, 3);
//			surf.setVertexBytes(Surface3D.UV0, uv1, 2);
			surf.setVertexBytes(Surface3D.UV0, uv2, 2);
			surf.indexVector = new Vector.<uint>();
			
			for (var i:int = 0; i < surf.getVertexVector(Surface3D.UV0).length; i++) {
				var v : Number = surf.getVertexVector(Surface3D.UV0)[i];
			}
			
			len = bytes.readInt();  
			trace("索引:", len);
			for (i = 0; i < len; i++) {
				surf.indexVector.push(bytes.readInt());
			}
			trace("剩余数据:", bytes.bytesAvailable);  
			
			var texture: Bitmap2DTexture = new Bitmap2DTexture(new IMAGE().bitmapData);
			var shader : Shader3D = new Shader3D([new TextureMapFilter(texture)]);
			
			uobj.addComponent(new MeshRenderer(new Mesh3D([surf]), new Material3D(shader)));
			
			uobj.addEventListener(Object3D.ENTER_DRAW_EVENT, function(e:Event):void{
				texture.upload(scene);
			});
			
			this.scene.addChild(uobj);
		}
	}
}
