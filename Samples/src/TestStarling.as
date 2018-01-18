package {

	import flash.display.Sprite;
	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.ColorMaterial;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.Color;
	
	import starling.core.Starling;

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
	 * @date   Sep 15, 2015
	 */
	[SWF(width = "1440", height = "720", frameRate = "60", backgroundColor = "#ffffff")]
	public class TestStarling extends Sprite {
		
		private var scene : Scene3D;
		private var sl	  : Starling;
		
		public function TestStarling() {
			super();
			
			this.scene = new Viewer3D(this);
			this.scene.addEventListener(Scene3D.CREATE_EVENT, onCreate);
			this.scene.addEventListener(Scene3D.POST_RENDER_EVENT, postRenderEvent);
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Cube(), new ColorMaterial(Color.GRAY)));
			
			for (var i:int = 0; i < 5; i++) {
				for (var j:int = 0; j < 5; j++) {
					var c : Object3D = cube.clone();
					c.transform.x = (i - 2.5) * 15;
					c.transform.y = (j - 2.5) * 15;
					c.transform.z = -50;
					this.scene.addChild(c);
				}
			}
			
		}
		
		private function onCreate(event:Event) : void {
			sl = new Starling(StarlingMain, stage, null, scene.stage3d);
			sl.start();
		}
		
		private function postRenderEvent( e:flash.events.Event ):void {
			sl.nextFrame();
		}
		
	}
}
