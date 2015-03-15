package ide.plugins {

	import flash.events.Event;
	import flash.system.Capabilities;
	
	import ide.App;
	import ide.events.LogEvent;
	import ide.utils.FbxParserMacCMD;
	import ide.utils.FbxSceneLoader;
	
	import ui.core.controls.Button;
	import ui.core.controls.CheckBox;
	import ui.core.controls.InputText;
	import ui.core.controls.Layout;
	import ui.core.controls.Spinner;
	import ui.core.controls.Window;
	import ui.core.event.ControlEvent;

	public class FbxPlugin extends Layout {
		
		private var uv0		: CheckBox;
		private var uv1		: CheckBox;
		private var normal 	: CheckBox;
		private var tangent	: CheckBox;
		private var anim	: CheckBox;
		private var geometry: CheckBox;
		private var world	: CheckBox;
		private var quat	: CheckBox;
		private var quatNum : Spinner;
		private var m34Num	: Spinner;
		private var mount	: InputText;
		private var parse	: Button;
		private var fbxPath : String;
		
		public function FbxPlugin(fbxpath : String) {
			super();
			
			this.fbxPath	= fbxpath;
			this.labelWidth	= 125;
						
			this.uv0 		= this.addControl(new CheckBox(), "UV0") as CheckBox;
			this.uv1 		= this.addControl(new CheckBox(), "UV1") as CheckBox;
			this.normal  	= this.addControl(new CheckBox(), "Normal")  as CheckBox;
			this.tangent 	= this.addControl(new CheckBox(), "Tangent") as CheckBox;
			this.anim    	= this.addControl(new CheckBox(), "Anim") as CheckBox;
			this.geometry	= this.addControl(new CheckBox(), "Geometry") as CheckBox;
			this.world	 	= this.addControl(new CheckBox(), "World") as CheckBox;
			this.quat	 	= this.addControl(new CheckBox(), "Quat") as CheckBox;
			this.quatNum 	= this.addControl(new Spinner(56, 1, 56, 2, 1), "QuatBoneNum") as Spinner;
			this.m34Num	 	= this.addControl(new Spinner(36, 1, 36, 2, 1), "MatrixBoneNum") as Spinner;
			this.mount	 	= this.addControl(new InputText(), "Mount") as InputText;
			this.parse	 	= this.addControl(new Button("Import")) as Button;
			
			this.uv0.value = true;
			this.normal.value = true;
			this.geometry.value = false;
									
			this.uv0.toolTip = "解析UV0";
			this.uv1.toolTip = "解析UV1";
			this.normal.toolTip  = "解析法线";
			this.tangent.toolTip = "解析切线";
			this.anim.toolTip	 = "解析动画";
			this.geometry.toolTip= "使用Geometry变换数据";
			this.world.toolTip	 = "使用全局变换数据";
			this.quat.toolTip	 = "使用四元数骨骼";
			this.quatNum.toolTip = "四元数最大骨骼数";
			this.m34Num.toolTip	 = "矩阵最大骨骼数";
			this.mount.toolTip	 = "挂节点骨骼名称->使用 ',' 分割";
						
			this.minHeight 	= 300;
			this.height    	= 300;
			this.width	   	= 250;
			
			this.parse.addEventListener(ControlEvent.CLICK, onClick);
		}
		
		private function onClick(event:Event) : void {
			Window.popWindow.visible = false;	
			if (Capabilities.os.indexOf("Mac") != -1) {
				var macParser : FbxParserMacCMD = new FbxParserMacCMD(normal.value, tangent.value, uv0.value, uv1.value, anim.value, geometry.value,
					world.value, quat.value, quatNum.value, m34Num.value, mount.text, fbxPath);
				macParser.addEventListener(Event.COMPLETE, onParseComplete);
			}
		}
		
		private function onParseComplete(event:Event) : void {
			var tokens : Array = this.fbxPath.split(".");		
			tokens.pop();
			var path : String = tokens.join(".") + ".scene";
			App.core.dispatchEvent(new LogEvent("开始载入配置文件:" + path));
			var loader : FbxSceneLoader = new FbxSceneLoader(path);
			loader.load();
			App.core.selection.objects = [loader];
			App.core.scene.addChild(loader);
		}
		
	}
}
