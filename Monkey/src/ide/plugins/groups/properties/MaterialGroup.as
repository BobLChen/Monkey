package ide.plugins.groups.properties {

	import flash.display.BitmapData;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	import ide.App;
	import ide.utils.FileUtils;
	
	import monkey.core.materials.Material3D;
	import monkey.core.textures.Bitmap2DTexture;
	import monkey.core.utils.Color;
	import monkey.core.utils.Texture3DUtils;
	
	import ui.core.container.Accordion;
	import ui.core.container.Box;
	import ui.core.controls.CheckBox;
	import ui.core.controls.ColorPicker;
	import ui.core.controls.ComboBox;
	import ui.core.controls.Image;
	import ui.core.controls.Label;
	import ui.core.controls.Layout;
	import ui.core.controls.Separator;
	import ui.core.controls.Spinner;
	import ui.core.event.ControlEvent;
	import ui.core.type.Align;
	import ui.core.type.ColorMode;
	
	/**
	 * 材质 
	 * @author Neil
	 * 
	 */	
	public class MaterialGroup {

		[Embed(source = "image 79.png")]
		private var AddIcon  	: Class;
		
		public var accordion 	: Accordion;
		public var layout 	 	: Layout;
		
		private var app			: App;
		private var material	: Material3D;
		private var option		: Accordion;
		private var params		: Accordion;
		private var blendMode 	: ComboBox;
		private var sourceFactor: ComboBox;
		private var destFactor  : ComboBox;
		private var cullFace	: ComboBox;
		private var depthCompare: ComboBox;
		private var depthWrite	: CheckBox;
		private var inited		: Boolean;
		
		public function MaterialGroup() {
			this.inited = false;
			this.layout = new Layout(true);
			this.layout.labelWidth = 90;
			this.layout.labelAlign = Align.RIGHT;
			this.accordion = new Accordion("Material");
			this.accordion.addControl(this.layout);
			this.accordion.contentHeight = 800;
			this.layout.margins = 0;
			this.layout.space	= 0;
			this.layout.maxHeight = 800;
			this.layout.minHeight = 800;
			this.initOptions();
		}
		
		private function initOptions() : void {
			this.option = new Accordion("Options");
			this.option.contentHeight = 160;
			var header : Layout = new Layout();
			header.labelWidth = 90;
			header.margins = 0;
			header.space   = 0;
			header.minHeight = 160;
			header.maxHeight = 160;
			header.labelAlign= Align.RIGHT;
			this.option.addControl(header);
			this.layout.addControl(this.option);
			
			this.blendMode    	= header.addControl(new ComboBox(blends,  blends),  "Blend Mode:")    	as ComboBox;
			this.sourceFactor 	= header.addControl(new ComboBox(factors, factors), "Source Factor:") 	as ComboBox;
			this.destFactor		= header.addControl(new ComboBox(factors, factors), "Dest Factor:")		as ComboBox;
			header.addControl(new Separator(Separator.HORIZONTAL));
			this.cullFace		= header.addControl(new ComboBox(culls, culls), "Cull Face:")			as ComboBox;
			header.addControl(new Separator(Separator.HORIZONTAL));
			this.depthCompare	= header.addControl(new ComboBox(compares, compares), "Depth Compare:")	as ComboBox;
			this.depthWrite		= header.addControl(new CheckBox("", true), "Depth Write:")				as CheckBox;
			header.addControl(new Separator(Separator.HORIZONTAL));
			
			this.blendMode.addEventListener(ControlEvent.CHANGE, changeOption);
			this.sourceFactor.addEventListener(ControlEvent.CHANGE, changeOption);
			this.destFactor.addEventListener(ControlEvent.CHANGE, changeOption);
			this.cullFace.addEventListener(ControlEvent.CHANGE, changeOption);
			this.depthCompare.addEventListener(ControlEvent.CHANGE, changeOption);
			this.depthWrite.addEventListener(ControlEvent.CHANGE, changeOption);
		}
		
		private function changeOption(event:Event) : void {
			this.material.blendMode 	= this.blendMode.selectData as String;
			if (event.target == this.blendMode) {
				this.sourceFactor.text 	= this.material.sourceFactor;
				this.destFactor.text	= this.material.destFactor;
			}
			this.material.sourceFactor 	= this.sourceFactor.selectData as String;
			this.material.destFactor	= this.destFactor.selectData as String;
			this.material.cullFace		= this.cullFace.selectData as String;
			this.material.depthCompare	= this.depthCompare.selectData as String;
			this.material.depthWrite	= this.depthWrite.value;
		}
		
		private static function get compares() : Array {
			return [
				Context3DCompareMode.ALWAYS,
				Context3DCompareMode.EQUAL,
				Context3DCompareMode.GREATER,
				Context3DCompareMode.GREATER_EQUAL,
				Context3DCompareMode.LESS,
				Context3DCompareMode.LESS_EQUAL,
				Context3DCompareMode.NEVER,
				Context3DCompareMode.NOT_EQUAL
			];
		}
		
		private static function get culls() : Array {
			return [
				Context3DTriangleFace.BACK,
				Context3DTriangleFace.FRONT,
				Context3DTriangleFace.FRONT_AND_BACK,
				Context3DTriangleFace.NONE
			];
		}
		
		private static function get blends() : Array {
			return [
				Material3D.BLEND_ADDITIVE, 
				Material3D.BLEND_ALPHA, 
				Material3D.BLEND_ALPHA_BLENDED, 
				Material3D.BLEND_MULTIPLY, 
				Material3D.BLEND_NONE, 
				Material3D.BLEND_SCREEN
			];
		}
		
		private static function get factors() : Array {
			return [
				Context3DBlendFactor.DESTINATION_ALPHA,
				Context3DBlendFactor.DESTINATION_COLOR,
				Context3DBlendFactor.ONE,
				Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,
				Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR,
				Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA,
				Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR,
				Context3DBlendFactor.SOURCE_ALPHA,
				Context3DBlendFactor.SOURCE_COLOR,
				Context3DBlendFactor.ZERO
			];
		}
		
		public function update(material:Material3D, app:App) : void {
			this.material = material;
			this.app	  = app;
			this.updateOption();
			if (!this.inited) {
				this.createParamUI();
			}
		}
		
		private function updateOption() : void {
			this.blendMode.text 	= this.material.blendMode;
			this.sourceFactor.text 	= this.material.sourceFactor;
			this.destFactor.text	= this.material.destFactor;
			this.cullFace.text		= this.material.cullFace;
			this.depthCompare.text	= this.material.depthCompare;
			this.depthWrite.value	= this.material.depthWrite;
		}
				
		private function createParamUI() : void {
			this.params = new Accordion("Params");
			var content : Layout = new Layout();
			this.params.addControl(content);
			this.layout.addControl(params);
			this.inited = true;
			var xml : XML = describeType(this.material);
			for each (var acc : Object in xml.accessor) {
				var declared : Class = getDefinitionByName(acc.@declaredBy) as Class;
				if (declared == Material3D) {
					continue;
				}
				this.createVarUI(acc, content);
			}
			this.params.contentHeight = content.maxHeight + 20;
		}
		
		private function createVarUI(acc : Object, content : Layout) : void {
			if (acc.@access != "readwrite") {
				return;
			}
			var type : Class = getDefinitionByName(acc.@type) as Class;
			if (this.material[acc.@name] is Color) {
				this.createColorUI(acc, content);
			} else if (this.material[acc.@name] is Number) {
				this.createNumberUI(acc, content);
			} else if (this.material[acc.@name] is int) {
				this.createIntUI(acc, content);
			} else if (this.material[acc.@name] is Bitmap2DTexture) {
				this.createBitmap2DTextureUI(acc, content);
			}  else if (this.material[acc.@name] is Point) {
				this.createPointUI(acc, content);
			} else if (this.material[acc.@name] is Boolean) {
				this.createBoolUI(acc, content);
			} else if (this.material[acc.@name] is Vector3D) {
				this.createVector3DUI(acc, content);
			}
		}
		
		private function createVector3DUI(acc:Object, content : Layout) : void {
			content.addHorizontalGroup(acc.@name + ":");
			var vx : Spinner = content.addControl(new Spinner()) as Spinner;
			var vy : Spinner = content.addControl(new Spinner()) as Spinner;
			var vz : Spinner = content.addControl(new Spinner()) as Spinner;
			content.endGroup();		
			
			vx.value = this.material[acc.@name].x;
			vy.value = this.material[acc.@name].y;
			vz.value = this.material[acc.@name].z;
			
			var change : Function = function(e : Event):void{
				material[acc.@name].x = vx.value;
				material[acc.@name].y = vy.value;
				material[acc.@name].z = vz.value;
			};
			
			vx.addEventListener(ControlEvent.CHANGE, change);
			vy.addEventListener(ControlEvent.CHANGE, change);
			vz.addEventListener(ControlEvent.CHANGE, change);
			
			content.maxHeight += 25;
			content.minHeight += 25;
		}
		
		private function createBoolUI(acc:Object, content : Layout) : void {
			var bool : CheckBox = content.addControl(new CheckBox(), acc.@name + ":") as CheckBox;
			bool.value = this.material[acc.@name];
			bool.addEventListener(ControlEvent.CHANGE, function():void{
				material[acc.@name] = bool.value;
			});
			content.maxHeight += 25;
			content.minHeight += 25;
		}
		
		private function createPointUI(acc:Object, content : Layout) : void {
			content.addHorizontalGroup(acc.@name + ":");
			var px : Spinner = content.addControl(new Spinner()) as Spinner;
			var py : Spinner = content.addControl(new Spinner()) as Spinner;
			content.endGroup();
			
			px.value = this.material[acc.@name].x;
			py.value = this.material[acc.@name].y;
			
			var change : Function = function(e : Event):void{
				material[acc.@name].x = px.value;
				material[acc.@name].y = py.value;
			};
			
			px.addEventListener(ControlEvent.CHANGE, change);
			py.addEventListener(ControlEvent.CHANGE, change);
			
			content.maxHeight += 25;
			content.minHeight += 25;
		}
		
		private function createNumberUI(acc:Object, content : Layout) : void {
			var value : Spinner = content.addControl(new Spinner(), acc.@name + ":") as Spinner;			
			value.value = this.material[acc.@name];
			value.addEventListener(ControlEvent.CHANGE, function(e : Event):void{
				material[acc.@name] = value.value;
			});
			content.maxHeight += 25;
			content.minHeight += 25;
		}
		
		private function createBitmap2DTextureUI(acc:Object, content : Layout) : void {
			var image   : Image = new Image(Texture3DUtils.nullBitmapData, true, 100, 100);
			image.source = material[acc.@name].bitmapData;
			image.addEventListener(ControlEvent.CLICK, function(e : Event):void{
				var file : FileUtils = new FileUtils();
				file.openForImage(function(bmp:BitmapData):void{
					material[acc.@name].dispose();
					material[acc.@name] = new Bitmap2DTexture(bmp);
					material[acc.@name].upload(app.scene);
					image.source = bmp;
				});
			});
			
			var box : Box = new Box();
			box.minHeight = 100;
			box.maxHeight = 100;
			box.orientation = Box.HORIZONTAL;
			box.addControl(new Label(acc.@name + ":", content.labelWidth, content.labelAlign));
			box.addControl(image);
			
			content.addControl(box);
			content.maxHeight += 120;
			content.minHeight += 120;
		}
		
		private function createIntUI(acc:Object, content : Layout) : void {
			var value : Spinner = content.addControl(new Spinner(0, 0, 0, 2, 1), acc.@name + ":") as Spinner;
			value.value = material[acc.@name];
			value.addEventListener(ControlEvent.CHANGE, function(e : Event):void{
				material[acc.@name] = value.value;
			});
			content.maxHeight += 25;
			content.minHeight += 25;
		}
		
		private function createColorUI(acc : Object, content : Layout) : void {
			var color : ColorPicker = content.addControl(new ColorPicker(0xFFFFFF, 1, ColorMode.MODE_RGBA), acc.@name + ":") as ColorPicker;
			color.color = material[acc.@name].color;
			color.alpha = material[acc.@name].alpha;
			color.addEventListener(ControlEvent.CHANGE, function(e : Event):void{
				material[acc.@name].color = color.color;
				material[acc.@name].alpha = color.alpha;
			});
			content.maxHeight += 25;
			content.minHeight += 25;
		}
				
	}
}
