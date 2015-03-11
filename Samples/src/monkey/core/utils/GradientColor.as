package monkey.core.utils {
	
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class GradientColor {
		
		private static const shape  : Shape = new Shape();
		private static const matrix : Matrix = new Matrix();
		
		public var gridient 	 : BitmapData;
		
		private var _rgba   	 : Vector3D;
		private var _colors 	 : Array;
		private var _alphas 	 : Array;
		private var _alphaRatios : Array;
		private var _colorRatios : Array;
		
		public function GradientColor() {
			this.gridient = new BitmapData(256, 16, true);
			this._rgba = new Vector3D();
			this._alphas = [];
			this._colors = [];
			this._alphaRatios = [];
			this._colorRatios = [];
			this.setColors([0xFFFFFF], [0]);
			this.setAlphas([1, 0], [0, 0xFF]);
		}
		
		public function getRGBA(idx : Number) : Vector3D {
			var index : int = int(idx * 256);
			if (index <= 1) {
				index = 1;
			} else if (index >= 255) {
				index = 255;
			}
			var color : uint = gridient.getPixel(index, 2);
			this._rgba.w = ((gridient.getPixel32(index, 2) >> 24) & 0xFF) / 0xFF;
			this._rgba.z = (color & 0xFF) / 0xFF;
			this._rgba.y = ((color >> 8)  & 0xFF) / 0xFF;
			this._rgba.x = ((color >> 16) & 0xFF) / 0xFF;
			return _rgba;
		}
		
		public function get colorRatios():Array {
			return _colorRatios;
		}
		
		public function get alphaRatios():Array {
			return _alphaRatios;
		}
		
		public function get alphas() : Array {
			return _alphas;
		}
		
		public function get colors() : Array {
			return _colors;
		}
		
		public function setAlphas(alphas : Array, ratios : Array) : void {
			
			this._alphas = alphas;
			this._alphaRatios = ratios;
			matrix.createGradientBox(256, 16);
			
			var rect : Rectangle = new Rectangle(0, 8, 256, 8);
			var colors : Array = [];
			var i : int = 0;
			while (i < alphas.length) {
				colors.push(0xFFFFFF);
				i++;
			}
			shape.graphics.clear();
			shape.graphics.beginGradientFill(GradientType.LINEAR, colors, this._alphas, this._alphaRatios, matrix, "pad", InterpolationMethod.RGB);
			shape.graphics.drawRect(0, 8, 256, 16);
			this.gridient.fillRect(rect, 0);
			this.gridient.draw(shape);
			this.setColors(this._colors, this._colorRatios);
			this.gridient.copyChannel(this.gridient, rect, new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		}
		
		public function setColors(colors : Array, ratios : Array) : void {
			this._colors = colors;
			this._colorRatios = ratios;
			matrix.createGradientBox(256, 16);
			shape.graphics.clear();
			shape.graphics.beginGradientFill(GradientType.LINEAR, this._colors, null, this._colorRatios, matrix, "pad", InterpolationMethod.RGB);
			shape.graphics.drawRect(0, 0, 256, 8);
			this.gridient.draw(shape);
			colors = [];
			var i : int = 0;
			while (i < this._alphas.length) {
				colors.push(0xFFFFFF);
				i++;
			}
			shape.graphics.clear();
			shape.graphics.beginGradientFill(GradientType.LINEAR, colors, this._alphas, this._alphaRatios, matrix, "pad", InterpolationMethod.RGB);
			shape.graphics.drawRect(0, 8, 256, 8);
			this.gridient.copyChannel(this.gridient, new Rectangle(0, 8, 256, 8), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
		}
	}
}
