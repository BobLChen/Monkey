package {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.materials.Material3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Scene3D;
	import monkey.core.scene.Viewer3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.DissolveFilter;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;

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
	 * @date   Dec 23, 2015
	 */
	public class Test_Dissolve extends Sprite {
		
		[Embed(source="button_square.png")]
		private var IMG0 : Class;
		[Embed(source="Clouds.png")]
		private var IMG1 : Class;
		
		private var scene : Scene3D;
		private var cube  : Object3D;
		private var shader: Shader3D;
		
		public function Test_Dissolve() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			this.scene = new Viewer3D(this);
			this.scene.background = new Color(0x000000);
			this.scene.camera.transform.z = -50;
			this.scene.autoResize = true;
			
			var filter : DissolveFilter = new DissolveFilter();
			filter.diffuse  = new Bitmap2DTexture(new IMG0().bitmapData);
			filter.dissolve = new Bitmap2DTexture(new IMG1().bitmapData);
			
			this.stage.addEventListener(Event.ENTER_FRAME, function(e : Event):void{
				filter.step += 0.01;
				if (filter.step >= 1) {
					filter.step = 0;
				}
			});
			
			this.shader = new Shader3D([]);
			this.shader.addFilter(filter);
			
			this.cube = new Object3D();
			this.cube.addComponent(new MeshRenderer(new Cube(10, 10, 10), new Material3D(shader)));
			
			this.scene.addChild(cube);
		}
	}
}
