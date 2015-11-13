package {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.utils.Color;
	import monkey.core.utils.FPSStats;

	/**
	 *　　　　　　　　┏┓　　　┏┓+ +
	 *　　　　　　　┏┛┻━━━┛┻┓ + +
	 *　　　　　　　┃　　　　　　　┃ 　
	 *　　　　　　　┃　　　━　　　┃ ++ + + +
	 *　　　　　　 ████━████ ┃+
	 *　　　　　　　┃　　　　　　　┃ +
	 *　　　　　　　┃　　　┻　　　┃
	 *　　　　　　　┃　　　　　　　┃ + +
	 *　　　　　　　┗━┓　　　┏━┛
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + + + +
	 *　　　　　　　　　┃　　　┃　　　　　　　　　　　
	 *　　　　　　　　　┃　　　┃ + 　　　　　　
	 *　　　　　　　　　┃　　　┃
	 *　　　　　　　　　┃　　　┃　　+　　　　　　　　　
	 *　　　　　　　　　┃　 　　┗━━━┓ + +
	 *　　　　　　　　　┃ 　　　　　　　┣┓
	 *　　　　　　　　　┃ 　　　　　　　┏┛
	 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
	 *　　　　　　　　　　┃┫┫　┃┫┫
	 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
	 * @author neil
	 * @date   Oct 23, 2015
	 */
	public class TestCubes extends Sprite {
		
		private var scene : Scene3D;
		
		public function TestCubes() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
			this.stage.addChild(new FPSStats());
			
			this.scene = new Scene3D(this);
			this.scene.camera.transform.y = 500;
			this.scene.camera.transform.x = 500;
			this.scene.camera.transform.lookAt(0, 0, 0); 
			this.scene.autoResize = true;
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Cube(100, 1, 100), new ColorMaterial(Color.BLUE)));
			
			for (var i:int = 0; i < 50; i++) {
				for (var j:int = 0; j < 50; j++) {
					var c : Object3D = cube.clone();
					c.transform.x = (i - 25) * 100;
					c.transform.z = (j - 25) * 100;
					(cube.renderer.material as ColorMaterial).color = new Color(0xFFFFFF * Math.random());
					this.scene.addChild(c);
				}
			}
			
		}
		
		
	}
}
