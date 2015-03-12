package ide.plugins.groups.particles.emission {
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import ide.App;
	import ide.events.SelectionEvent;
	import ide.plugins.groups.particles.ParticleBaseGroup;
	
	import monkey.core.entities.particles.ParticleSystem;
	
	import ui.core.container.Box;
	import ui.core.controls.ImageButton;
	import ui.core.controls.Label;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;

	public class BurstsGroup extends ParticleBaseGroup {
		
		[Embed(source="add.png")]
		private static const ADD : Class;
		[Embed(source="sub.png")]
		private static const SUB : Class;
		
		private var button : ImageButton;
		private var dict   : Dictionary;
		private var header : Box;
		private var title  : Box;
		
		public function BurstsGroup() {
			super();
			this.dict	= new Dictionary();
			this.button = new ImageButton(new ADD());
			this.title	= new Box();
			this.title.orientation = HORIZONTAL;			
			this.title.addControl(new Label("Bursts:"));
			this.title.addControl(this.button);
			this.addControl(title);
			this.header = new Box();
			this.header.orientation = HORIZONTAL;
			this.header.addControl(new Label("Time"));
			this.header.addControl(new Label("Particles"));
			this.addControl(header);
			this.maxHeight = 60;
			this.minHeight = 60;
			this.button.addEventListener(ControlEvent.CLICK, onAddBursts);
		}
				
		private function createItem(data : Point) : void {
			
			var btn  : ImageButton = new ImageButton(new SUB());
			var time : Spinner = new Spinner(data.x);
			var num  : Spinner = new Spinner(data.y);
			var item : Box = new Box();
			
			item.orientation = HORIZONTAL;
			item.addControl(time);
			item.addControl(num);
			item.addControl(btn);
						
			this.addControl(item);
			this.dict[time]= data;		// 时间->数据
			this.dict[num] = data;		// 数量->数据
			this.dict[btn] = item;		// 按钮->item
			this.dict[item]= data;		// item->data
			this.maxHeight += 20;
			this.minHeight += 20;
			
			time.addEventListener(ControlEvent.CHANGE, changeTime);
			num.addEventListener(ControlEvent.CHANGE, changeNum);
			btn.addEventListener(ControlEvent.CLICK, onDeleteBursts);
		}
		
		private function changeTime(event:Event) : void {
			var time : Spinner = event.target as Spinner;
			var data : Point = this.dict[time];
			data.x = time.value;
			this.particle.build();
		}
		
		private function changeNum(event:Event) : void {
			var num  : Spinner = event.target as Spinner;
			var data : Point = this.dict[num];
			data.y = num.value;
			this.particle.build();
		}
		
		private function onAddBursts(event:Event) : void {
			var data : Point = new Point(0, 30);
			this.createItem(data);
			this.particle.bursts.push(data);
			this.particle.build();
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
				
		private function onDeleteBursts(event:Event) : void {
			var btn  : ImageButton = event.target as ImageButton;
			var data : Point = this.dict[dict[btn]];
			this.removeControl(this.dict[btn]);
			this.maxHeight -= 20;
			this.minHeight -= 20;
			delete this.dict[btn];
			var idx : int = this.particle.bursts.indexOf(data);
			this.particle.bursts.splice(idx, 1);
			this.particle.build();
			this.app.dispatchEvent(new SelectionEvent(SelectionEvent.CHANGE));
		}
		
		override public function updateGroup(app:App, particle:ParticleSystem):void {
			super.updateGroup(app, particle);
			this.removeAllControls();
			this.addControl(title);
			this.addControl(header);
			for each (var point : Point in particle.bursts) {
				this.createItem(point);
			}
		}
		
	}
}
