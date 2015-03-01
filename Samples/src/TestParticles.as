package  {
	
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
	import monkey.core.scene.Viewer3D;
	import monkey.core.utils.FPSStats;
	
	public class TestParticles extends Sprite {
		
		private var scene : Viewer3D;
		
		public function TestParticles() {
			super();
			
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align 	 = StageAlign.TOP_LEFT;
			this.stage.frameRate = 60;
						
			this.scene = new Viewer3D(this);
			this.scene.autoResize = true;
			
			var particle : ParticleSystem = new ParticleSystem();
			particle.bursts.push(new Point(0, 500));
			particle.bursts.push(new Point(2, 500));
			particle.duration = 3;
			particle.loops = 0;
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
			
			this.addChild(new FPSStats());
			this.scene.addChild(particle);	
		}
		
	}
}
