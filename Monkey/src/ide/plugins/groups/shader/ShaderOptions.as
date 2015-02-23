package ide.plugins.groups.shader {

	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.events.Event;
	
	import L3D.core.shader.Shader3D;
	
	import ide.App;
	import ui.core.container.Accordion;
	import ui.core.controls.CheckBox;
	import ui.core.controls.ComboBox;
	import ui.core.event.ControlEvent;

	public class ShaderOptions extends ShaderProperties {

		private static const FactorList : Array = [
			Context3DBlendFactor.DESTINATION_ALPHA, 
			Context3DBlendFactor.DESTINATION_COLOR, 
			Context3DBlendFactor.ONE, 
			Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,
			Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR, 
			Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA, 
			Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR, 
			Context3DBlendFactor.SOURCE_ALPHA, 
			Context3DBlendFactor.SOURCE_COLOR, 
			Context3DBlendFactor.ZERO];

		private static const DepthCompareList : Array = [
			Context3DCompareMode.ALWAYS, 
			Context3DCompareMode.EQUAL, 
			Context3DCompareMode.GREATER, 
			Context3DCompareMode.GREATER_EQUAL, 
			Context3DCompareMode.LESS, 
			Context3DCompareMode.LESS_EQUAL, 
			Context3DCompareMode.NEVER, 
			Context3DCompareMode.NOT_EQUAL];

		private static const BlendList : Array = [
			Shader3D.BLEND_ADDITIVE,
			Shader3D.BLEND_ALPHA,
			Shader3D.BLEND_ALPHA_BLENDED,
			Shader3D.BLEND_MULTIPLY,
			Shader3D.BLEND_NONE,
			Shader3D.BLEND_SCREEN
		];
		
		private var _blendCombox : ComboBox;
		private var _srcFactor : ComboBox;
		private var _destFactor : ComboBox;
		private var _twoSide : CheckBox;
		private var _depthWrite : CheckBox;
		private var _depthCompare : ComboBox;
		private var _material : Shader3D;
		
		public function ShaderOptions() {
			super("AdvancedOptions");
			layout.space = 0;
			layout.margins = 0.5;
			this._depthWrite = layout.addControl(new CheckBox("DepthWrite:", true)) as CheckBox;
			this._twoSide = layout.addControl(new CheckBox("TwoSide:", true)) as CheckBox;
			var accor : Accordion = layout.addAccordionGroup("BlendMode:", false);
			accor.contentHeight = 170;
			accor.update();
			this._blendCombox = layout.addControl(new ComboBox(BlendList, BlendList)) as ComboBox;
			layout.endGroup();
			layout.addAccordionGroup("Factor:", false).contentHeight = 200;
			layout.addHorizontalGroup();
			layout.labelWidth = 55;
			this._srcFactor = layout.addControl(new ComboBox(FactorList, FactorList), "SrcFactor:") as ComboBox;
			this._destFactor = layout.addControl(new ComboBox(FactorList, FactorList), "DstFactor:") as ComboBox;
			layout.endGroup();
			layout.endGroup();
			layout.addAccordionGroup("DepthCompare", false).contentHeight = 150;
			this._depthCompare = layout.addControl(new ComboBox(DepthCompareList, DepthCompareList)) as ComboBox;
			this.accordion.contentHeight = 270;
			this._blendCombox.addEventListener(ControlEvent.CHANGE, changeBlendMode);
			this._srcFactor.addEventListener(ControlEvent.CHANGE, changeFactor);
			this._destFactor.addEventListener(ControlEvent.CHANGE, changeFactor);
			this._depthCompare.addEventListener(ControlEvent.CHANGE, changeDepthCompare);
			this._twoSide.addEventListener(ControlEvent.CHANGE, changeTwoSide);
			this._depthWrite.addEventListener(ControlEvent.CHANGE, changeDepthWrite);
		}
		
		protected function changeDepthCompare(event : Event) : void {
			this._material.depthCompare = this._depthCompare.selectedValue as String;
		}

		protected function changeFactor(event : Event) : void {
			_material.sourceFactor = this._srcFactor.selectedValue as String;
			_material.destFactor = this._destFactor.selectedValue as String;
			this._blendCombox.selectedItem = "Custom";
		}

		protected function changeDepthWrite(event : Event) : void {
			_material.depthWrite = this._depthWrite.value;
		}

		protected function changeTwoSide(event : Event) : void {
			_material.twoSided = this._twoSide.value;
		}

		protected function changeBlendMode(event : Event) : void {
			_material.blendMode = this._blendCombox.selectedValue as String;
			this._srcFactor.selectedItem = this._material.sourceFactor;
			this._destFactor.selectedItem = this._material.destFactor;
		}
		
		override public function update(shader : Shader3D, app : App) : Boolean {
			this._material = shader;
			this._blendCombox.selectedItem = this._material.blendMode;
			this._srcFactor.selectedItem = this._material.sourceFactor;
			this._destFactor.selectedItem = this._material.destFactor;
			this._depthCompare.selectedItem = this._material.depthCompare;
			this._depthWrite.value = this._material.depthWrite;
			this._twoSide.value = this._material.twoSided;
			return true;
		}

	}
}
