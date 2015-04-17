package {

	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import monkey.core.base.Object3D;
	import monkey.core.materials.DiffuseMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.FPSStats;
	import monkey.core.utils.Input3D;

	public class Test_CubeMeshs extends Sprite {

		private var obj : Object3D;
		private var scene : Scene3D;
		private var count : int;

		public function Test_CubeMeshs() {
			super();

			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			
			this.addChild(new FPSStats());

			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.setPosition(0, 30, -50);
			this.scene.camera.transform.lookAt(0, 0, 0);
			this.scene.autoResize = true;

			var mtx : Matrix = new Matrix();
			mtx.createGradientBox(256, 10);

			var shp : Shape = new Shape();
			shp.graphics.beginGradientFill(GradientType.LINEAR, [0x00FCFF, 0xB48AFF, 0xF72335, 0xFFD73A], null, null, mtx);
			shp.graphics.drawRect(0, 0, 256, 10);

			var bmp : BitmapData = new BitmapData(256, 2, false, 0);
			bmp.draw(shp);

			var cubes : CubesMesh = new CubesMesh();
			var total : int = 256 * 256;

			for (var i : int = 0; i < total; i++) {
				var x : Number = Math.random() * 1000 - 500;
				var y : Number = Math.random() * 1000 - 500;
				var z : Number = Math.random() * 1000 - 500;
				var color : Number = Math.random() * 0.99 + 0.01;
				cubes.addCube(x, y, z, 5, color);
			}

			this.obj = new Object3D();
			this.obj.addComponent(new MeshRenderer(cubes, new DiffuseMaterial(new Bitmap2DTexture(bmp))));

			this.scene.addChild(obj);
			this.scene.addEventListener(Object3D.ENTER_FRAME_EVENT, updateEvent);
		}

		protected function updateEvent(event : Event) : void {
			if (!Input3D.mouseDown) {
				count++
				this.obj.transform.rotateX(0.2);
				this.obj.transform.rotateZ(0.22);
				scene.camera.transform.translateZ(Math.sin(count / 150) * 5);
			}
		}

	}
}
import monkey.core.base.Surface3D;
import monkey.core.entities.Mesh3D;

class CubesMesh extends Mesh3D {

	public function CubesMesh() : void {
		super([]);
		this.surfaces.push(new Surface3D());
		this.surfaces[0].setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
		this.surfaces[0].setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
		this.surfaces[0].indexVector = new Vector.<uint>();
	}

	public function addCube(x : Number, y : Number, z : Number, size : Number = 5, color : Number = 0) : void {

		var surf : Surface3D = surfaces[surfaces.length - 1];

		if (surf.getVertexVector(Surface3D.POSITION).length / 3 >= 65000) {
			surf = new Surface3D();
			surf.setVertexVector(Surface3D.POSITION, new Vector.<Number>(), 3);
			surf.setVertexVector(Surface3D.UV0, new Vector.<Number>(), 2);
			surf.indexVector = new Vector.<uint>();
			surfaces.push(surf);
		}

		//color = 0.5;
		var s : Number = size * 0.5;
		var i : int = surf.getVertexVector(Surface3D.POSITION).length / 3;

		surf.getVertexVector(Surface3D.POSITION).push(
			-s + x,  s + y, -s + z, 	
			s + x,  s + y, -s + z, 	
			-s + x, -s + y, -s + z, 	
			s + x, -s + y, -s + z, 
			// back	
			-s + x, -s + y,  s + z, 	
			s + x, -s + y,  s + z, 	
			-s + x,  s + y,  s + z, 	
			s + x,  s + y,  s + z, 
			// left	
			-s + x,  s + y,  s + z, 	
			-s + x,  s + y, -s + z, 	
			-s + x, -s + y,  s + z, 	
			-s + x, -s + y, -s + z, 	
			// right 	
			s + x,  s + y, -s + z, 	
			s + x,  s + y,  s + z, 	
			s + x, -s + y, -s + z, 	
			s + x, -s + y,  s + z, 	
			// top 	
			-s + x,  s + y,  s + z, 	
			s + x,  s + y,  s + z, 	
			-s + x,  s + y, -s + z, 	
			s + x,  s + y, -s + z, 
			// bottom	
			-s + x, -s + y, -s + z, 	
			s + x, -s + y, -s + z, 	
			-s + x, -s + y,  s + z, 	
			s + x, -s + y,  s + z
		);

		surf.getVertexVector(Surface3D.UV0).push(
			// front
			color, 0, color, 0, color, 0, color, 0,
			// back	
			color, 0, color, 0, color, 0, color, 0,
			// left	
			color, 0, color, 0, color, 0, color, 0,
			// right 	
			color, 0, color, 0, color, 0, color, 0,
			// top 	
			color, 0, color, 0, color, 0, color, 0,
			// bottom	
			color, 0, color, 0, color, 0, color, 0)

		var l : int = i + 24;

		for (i; i < l; i += 4)
			surf.indexVector.push(i, i + 1, i + 2, i + 1, i + 3, i + 2);

		this.download(true);
	}

}