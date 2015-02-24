package samples {

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Point;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.prop.value.PropConst;
	import monkey.core.entities.particles.prop.value.PropCurves;
	import monkey.core.scene.Viewer3D;

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
			particle.bursts.push(new Point(0, 100));
			particle.bursts.push(new Point(2, 100));
			particle.duration = 5;
			particle.startSpeed = new PropCurves();
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(0,   5));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(2.5, 5));
			(particle.startSpeed as PropCurves).curve.datas.push(new Point(5,   5));
			particle.rate = 50;
			particle.startLifeTime = new PropConst(5);
			particle.play();
			
			this.scene.addChild(particle);	
		}
	}
}
