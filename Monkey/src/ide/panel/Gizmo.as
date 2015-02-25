package ide.panel {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import monkey.core.base.Object3D;
	import monkey.core.camera.Camera3D;
	import monkey.core.entities.particles.ParticleSystem;
	import monkey.core.light.Light3D;
	import monkey.core.renderer.MeshRenderer;

	/**
	 * 图标 
	 * @author Neil
	 * 
	 */	
	public class Gizmo extends Sprite {
		
		public var object	  : Object3D;
		public var w	 	  : int;
		private var icon 	  : MovieClip;
		private var _selected : Boolean = false;
		
		public function Gizmo(object : Object3D) {
			super();
			
			this.object = object;
			this.icon  = new McIcons();
			
			if (object is ParticleSystem) {
				this.icon.gotoAndStop(7);
			} else if (object.getComponent(MeshRenderer)) {
				this.icon.gotoAndStop(1);
			} else if (object is Light3D) {
				this.icon.gotoAndStop(11);
			} else if (object is Camera3D) {
				this.icon.gotoAndStop(4);
			} else {
				this.icon.gotoAndStop(2);
			}
			this.icon.mouseEnabled  = false;
			this.icon.mouseChildren = false;
			this.addChild(this.icon);
			this.draw();
		}
		
		public function draw() : void {
			graphics.clear();
			graphics.lineStyle(1, (this.selected ? 0xFFCB00 : 0x909090), 0.75, true);
			graphics.beginFill(0x202020, 0.6);
			graphics.drawRect(-10, -10, 20, 20);
		}
		
		override public function toString() : String {
			return super.toString() + ":" + this.object.name;
		}
		
		public function get selected() : Boolean {
			return this._selected;
		}

		public function set selected(selected : Boolean) : void {
			this._selected = selected;
			this.draw();
		}
		
	}
}
