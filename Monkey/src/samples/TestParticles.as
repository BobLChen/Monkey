package samples {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import monkey.core.base.Object3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.prop.value.PropConst;
	import monkey.core.entities.particles.prop.value.PropCurves;
	import monkey.core.entities.primitives.Cube;
	import monkey.core.light.DirectionalLight;
	import monkey.core.materials.Material3D;
	import monkey.core.renderer.MeshRenderer;
	import monkey.core.scene.Viewer3D;
	import monkey.core.shader.Shader3D;
	import monkey.core.shader.filters.ColorFilter;
	import monkey.core.shader.filters.DirectionalLightFilter;

	public class TestParticles extends Sprite {
		
		private var scene : Viewer3D;
				
		public function TestParticles() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.nativeWindow.maximize();
			
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;
			
			var particle : ParticleSystem = new ParticleSystem();
			particle.bursts.push(new Point(0, 500));
			particle.bursts.push(new Point(2, 500));
			particle.duration = 3;
			particle.loops = true;
			particle.rate = 50;
			particle.startSpeed = new PropCurves();
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(0,   5));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(1.9, 5));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(2,   50));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(2.1, 5));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(5,   5));
			particle.startLifeTime = new PropConst(5);
			particle.billboard = true;
			particle.gotoAndPlay(0);
			
			var txt : TextField = new TextField();
			txt.defaultTextFormat = new TextFormat(null, 24, 0xFFFFFF);
			addChild(txt);
			txt.addEventListener(MouseEvent.CLICK, function(e : Event):void{
				if (particle.playing) {
					particle.stop();
				} else {
					particle.play();
				}
			});
			
			particle.addEventListener(Object3D.ENTER_DRAW, function(e:Event):void{
				txt.text = "" + particle.time.toFixed(2);
			});
			
			var shader : Shader3D = new Shader3D([]);
			shader.addFilter(new ColorFilter(0.6, 0.6, 0.6, 1.0));
			shader.addFilter(new DirectionalLightFilter(new DirectionalLight()));
			
			var cube : Object3D = new Object3D();
			cube.addComponent(new MeshRenderer(new Cube(), new Material3D(shader)));
			
			this.scene.addChild(cube);
			this.scene.addChild(particle);	
		}
		
	}
}
