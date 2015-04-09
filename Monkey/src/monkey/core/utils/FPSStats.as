package monkey.core.utils {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	public class FPSStats extends Sprite {
		
		protected var WIDTH 		: uint = 70;
		protected var HEIGHT 		: uint = 80;
		protected var xml 			: XML;
		protected var text 			: TextField;
		protected var style 		: StyleSheet;
		protected var timer 		: uint;
		protected var fps 			: uint;
		protected var ms 			: uint;
		protected var ms_prev 		: uint;
		protected var mem 			: Number;
		protected var mem_max 		: Number;
		protected var rectangle 	: Rectangle;
		protected var fps_graph 	: uint;
		protected var mem_graph 	: uint;
		protected var mem_max_graph : uint;
		protected var tri_graph 	: uint;
		protected var obj_graph 	: uint;
		protected var draws_graph 	: uint;
		
		protected var theme : Object = {
			bg: 0x000033, 
			fps: 0xffff00, 
			ms: 0x00ff00, 
			mem: 0x00ffff, 
			memmax: 0xff0070, 
			drawCalls: 0xff00ff, 
			trianglesDrawn: 0xffff00, 
			objectsDrawn: 0xff00f,
			textures: 0xff00f,
			surfaces: 0xff00f
		}
		
		public function FPSStats(alpha : Number = 1) : void {
			
			this.alpha = alpha;
			
			mem_max = 0;
			
			xml = <xml>
					<fps>FPS:</fps>
					<ms>MS:</ms>
					<mem>MEM:</mem>
					<memMax>MAX:</memMax>
					<drawCalls>DRA:</drawCalls>
					<trangles>TRI:</trangles>
					<objects>OBJ:</objects>
					<textures>TEX:</textures>
					<surfaces>GEO:</surfaces>
				  </xml>;
			
			style = new StyleSheet();
			style.setStyle("xml", {fontSize: '9px', fontFamily: '_sans', leading: '-2px'});
			style.setStyle("fps", {color: hex2css(theme.fps)});
			style.setStyle("ms", {color: hex2css(theme.ms)});
			style.setStyle("mem", {color: hex2css(theme.mem)});
			style.setStyle("memMax", {color: hex2css(theme.memmax)});
			style.setStyle("trangles", {color: hex2css(theme.trianglesDrawn)});
			style.setStyle("drawCalls", {color: hex2css(theme.drawCalls)});
			style.setStyle("objects", {color: hex2css(theme.objectsDrawn)});
			style.setStyle("textures", {color: hex2css(theme.textures)});
			style.setStyle("surfaces", {color: hex2css(theme.surfaces)});
			
			text = new TextField();
			text.width = WIDTH;
			text.height = 140;
			text.styleSheet = style;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			
			rectangle = new Rectangle(WIDTH - 1, 0, 1, HEIGHT - 50);
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
		}
		
		private function init(e : Event) : void {
			
			graphics.beginFill(theme.bg);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
			
			addChild(text);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function destroy(e : Event) : void {
			
			graphics.clear();
			
			while (numChildren > 0)
				removeChildAt(0);
			
			removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e : Event) : void {
			
			timer = getTimer();
			
			if (timer - 1000 > ms_prev) {
				
				ms_prev = timer;
				mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				mem_max = mem_max > mem ? mem_max : mem;
				
				xml.fps = "FPS: " + fps + " / " + stage.frameRate;
				xml.mem = "MEM: " + mem;
				xml.memMax = "MAX: " + mem_max;
				xml.ms = "MS:" + ms;
				xml.trangles = "TRI: " + Device3D.triangles;
				xml.drawCalls = "DRA: " + Device3D.drawCalls;
				xml.objects = "OBJ: " + Device3D.drawOBJNum;
				
				if (Device3D.scene) {
					xml.textures = "TEX: " + Device3D.scene.textures.length;
					xml.surfaces = "GEO: " + Device3D.scene.surfaces.length;
				}
				
				fps = 0;
			}
			
			fps++;
			
			xml.ms = "MS: " + (timer - ms);
			ms = timer;
			
			text.htmlText = xml;
		}	
		
		private function onClick(e : MouseEvent) : void {
			mouseY / height > .5 ? stage.frameRate-- : stage.frameRate++;
			xml.fps = "FPS: " + fps + " / " + stage.frameRate;
			text.htmlText = xml;
		}
		
		private function hex2css(color : int) : String {
			return "#" + color.toString(16);
		}
	}
}
