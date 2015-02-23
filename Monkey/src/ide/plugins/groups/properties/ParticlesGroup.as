package ide.plugins.groups.properties {

	import flash.events.Event;
	
	import L3D.core.entities.primitives.Particles3D;
	
	import ide.events.SelectionEvent;
	import ide.plugins.groups.particles.AccelerateLocalActionGroup;
	import ide.plugins.groups.particles.AutoRotateActionGroup;
	import ide.plugins.groups.particles.BezierGlobalGroup;
	import ide.plugins.groups.particles.BillboardActionGroup;
	import ide.plugins.groups.particles.BlendTextureGroup;
	import ide.plugins.groups.particles.CircleLoaclActionGroup;
	import ide.plugins.groups.particles.DriftLocalActionGroup;
	import ide.plugins.groups.particles.GrivityGlobalActionGroup;
	import ide.plugins.groups.particles.OffsetPositionGroup;
	import ide.plugins.groups.particles.ParticlesBaseGroup;
	import ide.plugins.groups.particles.ParticlesProperties;
	import ide.plugins.groups.particles.RotateByLifeActionGroup;
	import ide.plugins.groups.particles.ScaleByLifeGlobalGroup;
	import ide.plugins.groups.particles.ScaleByTimeActionGroup;
	import ide.plugins.groups.particles.TextureActionGroup;
	import ide.plugins.groups.particles.UVDriftActionGroup;
	import ide.plugins.groups.particles.UVEaseActionGroup;
	import ide.plugins.groups.particles.UVMovieActionGroup;
	import ide.plugins.groups.particles.VelocityActionGroup;
	import ide.plugins.groups.particles.VelocityGlobalActionGroup;
	
	import ide.App;

	public class ParticlesGroup extends PropertiesGroup {

		private var _app : App;
		private var _particles : Particles3D;
		private var _actionGroups : Vector.<ParticlesProperties>;

		public function ParticlesGroup() {
			super("Particles", true);
			
			accordion.contentHeight = 700;
			layout.margins = 5;
			layout.space = 1;

			this._actionGroups = new Vector.<ParticlesProperties>();
			this._actionGroups.push(new ParticlesBaseGroup());
			this._actionGroups.push(new TextureActionGroup());
			this._actionGroups.push(new BlendTextureGroup());
			this._actionGroups.push(new BillboardActionGroup());
			this._actionGroups.push(new OffsetPositionGroup());
			this._actionGroups.push(new VelocityActionGroup());
			this._actionGroups.push(new VelocityGlobalActionGroup());
			this._actionGroups.push(new AccelerateLocalActionGroup());
			this._actionGroups.push(new GrivityGlobalActionGroup());
			this._actionGroups.push(new BezierGlobalGroup());
			this._actionGroups.push(new CircleLoaclActionGroup());
			this._actionGroups.push(new DriftLocalActionGroup());
			this._actionGroups.push(new AutoRotateActionGroup());
			this._actionGroups.push(new RotateByLifeActionGroup());
			this._actionGroups.push(new ScaleByLifeGlobalGroup());
			this._actionGroups.push(new ScaleByTimeActionGroup());
			this._actionGroups.push(new UVMovieActionGroup());
			this._actionGroups.push(new UVDriftActionGroup());
			this._actionGroups.push(new UVEaseActionGroup());
		}

		override public function update(app : App) : Boolean {
			this._app = app;

			if (_app.selection.main != null && _app.selection.main is Particles3D) {
				_particles = _app.selection.main as Particles3D;
				_particles.addEventListener(Particles3D.BUILD_EVENT, buildParticles);
				for each (var group : ParticlesProperties in _actionGroups) {
					group.update(_particles, _app)
					layout.addControl(group.accordion);
				}
				layout.draw();
				return true;
			}
			return false;
		}

		private function buildParticles(event : Event) : void {
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_MATERIAL));
			this._app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE_GEOMETRY));
		}

	}
}
