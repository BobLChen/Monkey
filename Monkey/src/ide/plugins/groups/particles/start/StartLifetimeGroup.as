package ide.plugins.groups.particles.start {
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import ide.App;
	import ide.events.SelectionEvent;
	import ide.plugins.groups.particles.ImageButtonMenu;
	import ide.plugins.groups.particles.ParticleBaseGroup;
	import ide.plugins.groups.particles.lifetime.LifetimeData;
	
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.entities.particles.prop.value.DataConst;
	import monkey.core.entities.particles.prop.value.DataCurves;
	import monkey.core.entities.particles.prop.value.DataRandomTwoConst;
	import monkey.core.utils.ParticleUtils;
	
	import ui.core.Menu;
	import ui.core.container.Box;
	import ui.core.controls.CurvesEditor;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class StartLifetimeGroup extends ParticleBaseGroup {
		
		[Embed(source="arrow.png")]
		private static var ARROW : Class;
		
		private var arrow	 : ImageButtonMenu;
		private var label	 : Label;
		private var header	 : Box;
		private var data	 : LifetimeData;
		
		// const模式
		private var oneConst : Spinner;
		// curve模式
		private var curves	 : CurvesEditor;
		// two const
		private var minConst : Spinner;
		private var maxConst : Spinner;
		
		public function StartLifetimeGroup() {
			super(); 
			this.header	  = new Box();
			this.header.orientation = Box.HORIZONTAL;
			this.arrow	  = new ImageButtonMenu(new ARROW());
			this.label	  = new Label("Lifetime:", 160);
			this.header.addControl(this.arrow);
			this.header.addControl(this.label);
			this.header.maxHeight = 20;
			this.oneConst = new Spinner();
			this.curves   = new CurvesEditor();
			this.minConst = new Spinner();
			this.maxConst = new Spinner();
			this.curves   = new CurvesEditor(230, 150);
			var curveMenu : Menu = new Menu();
			curveMenu.addMenuItem("build", changeCurves);
			this.curves.view.contextMenu = curveMenu.menu;
			this.oneConst.addEventListener(ControlEvent.CHANGE, changeOne);
			this.minConst.addEventListener(ControlEvent.CHANGE, changeRandomTwoConst);
			this.maxConst.addEventListener(ControlEvent.CHANGE, changeRandomTwoConst);
			
			this.minHeight = 20;
			this.maxHeight = 20;
			
			this.arrow.addMenu("Const", changeToConst);
			this.arrow.addMenu("Curve", changeToCurve);
			this.arrow.addMenu("RandomTwoConst", changeToRandomTwoConst);
		}
		
		private function changeToRandomTwoConst(e : Event) : void {
			this.particle.startLifeTime = new DataRandomTwoConst(5, 5);
			this.updateKeyFrameData(5);
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
				
		private function changeToCurve(e : Event) : void {
			this.particle.startLifeTime = new DataCurves(5);
			this.updateKeyFrameData(5);
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		private function changeToConst(e : Event) : void {
			this.particle.startLifeTime = new DataConst(5);
			this.updateKeyFrameData(5);
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
				
		private function changeRandomTwoConst(event:Event) : void {
			this.particle.startLifeTime = new DataRandomTwoConst(minConst.value, maxConst.value);	
			this.updateKeyFrameData(maxConst.value);
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		private function changeCurves(event:Event) : void {
			var data : DataCurves = new DataCurves();
			data.curve.datas = new Vector.<Point>();
			for each (var point : Point in this.curves.points) {
				data.curve.datas.push(point.clone());
			}
			data.yValue = this.curves.axisYValue;
			this.particle.startLifeTime = data;
			this.updateKeyFrameData(this.curves.axisYValue);
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		private function changeOne(event:Event) : void {
			this.particle.startLifeTime = new DataConst(this.oneConst.value);		
			this.updateKeyFrameData(this.oneConst.value);
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.data = particle.userData.lifetime;
			this.removeAllControls();
			this.addControl(this.header);
			this.minHeight = 20;
			this.maxHeight = 20;
			this.particle.addEventListener(ParticleSystem.BUILD_EVENT, onParticleBuild);
			if (particle.startLifeTime is DataConst) {
				this.orientation = HORIZONTAL;
				this.addControl(this.oneConst);
				this.oneConst.value = (particle.startLifeTime as DataConst).value;
				this.minHeight = 20;
				this.maxHeight = 20;
			} else if (particle.startLifeTime is DataRandomTwoConst) {
				this.orientation = HORIZONTAL;
				var randomTwoConst : DataRandomTwoConst = particle.startLifeTime as DataRandomTwoConst;
				this.addControl(this.minConst);
				this.addControl(this.maxConst);
				this.minConst.value = randomTwoConst.minValue;
				this.maxConst.value = randomTwoConst.maxValue;
				this.minHeight = 20;
				this.maxHeight = 20;
			} else if (particle.startLifeTime is DataCurves) {
				this.orientation = VERTICAL;
				var propCurves : DataCurves = particle.startLifeTime as DataCurves;
				this.addControl(this.curves);
				this.curves.axisXValue = particle.duration;
				this.curves.axisYValue = propCurves.yValue;
				this.curves.points = propCurves.curve.datas;
				this.minHeight = 230;
				this.maxHeight = 230;
			}
		}
		
		private function onParticleBuild(event:Event) : void {
			this.curves.axisXValue = particle.duration;
		}
		
		private function updateKeyFrameData(lifetime : Number) : void {
			this.data.lifetime = lifetime;
			this.particle.keyFrames = ParticleUtils.GeneratelifetimeBytes(
				data.lifetime,
				data.speedX,
				data.speedY,
				data.speedZ,
				data.axisX,
				data.axisY,
				data.axisZ,
				data.angle,
				data.size
			);
		}
		
	}
}
