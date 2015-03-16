package monkey.core.camera.lens {
	
	/**
	 * 正交投影 
	 * @author Neil
	 * 
	 */	
	public class OrthogrhicLens extends Lens3D {
		
		private var _left 	: Number;
		private var _right 	: Number;
		private var _bottom : Number;
		private var _top 	: Number;
		
		public function OrthogrhicLens(left : Number, right : Number, bottom : Number, top : Number) {
			super();
			this.setOrth(left, right, bottom, top);
		}
		
		public function setOrth(left : Number, right : Number, bottom : Number, top : Number) : void {
			this._left 	= left;
			this._right = right;
			this._top 	= top;
			this._bottom= bottom;
			this.invalidateProjection();
		}
		
		override public function clone():Lens3D {
			return super.clone();
		}
		
		override public function copyfrom(lens:Lens3D):void {
			super.copyfrom(lens);
			if (lens is OrthogrhicLens) {
				var orth : OrthogrhicLens = lens as OrthogrhicLens;
				this._left 	= orth._left;
				this._right	= orth._right;
				this._top	= orth._top;
				this._bottom= orth._bottom;
			}
		}
		
		public function get top():Number {
			return _top;
		}
		
		public function get bottom():Number {
			return _bottom;
		}
		
		public function get right():Number {
			return _right;
		}
		
		public function get left():Number {
			return _left;
		}
		
		override public function setViewPort(x:int, y:int, width:int, height:int):void {
			super.setViewPort(x, y, width, height);
			this._left 	= -width 	/ 2;
			this._right = width 	/ 2;
			this._top 	= height 	/ 2;
			this._bottom= -height 	/ 2;
		}
		
		override public function updateProjectionMatrix():void {
			
			var rawData : Vector.<Number> = _projection.rawData;
			rawData[0] = 2 / (_right - _left);
			rawData[1] = 0;
			rawData[2] = 0;
			rawData[3] = 0;
			
			rawData[4] = 0;
			rawData[5] = 2 / (_top - _bottom);
			rawData[6] = 0;
			rawData[7] = 0;
			
			rawData[8] = 0;
			rawData[9] = 0;
			rawData[10] = 1 / (_far - _near);
			rawData[11] = -_near/(_far-_near);
			
			rawData[12] = 0;
			rawData[13] = 0;
			rawData[14] = 0;
			rawData[15] = 1;
			this._projection.copyRawDataFrom(rawData);
			
			super.updateProjectionMatrix();
		}
		
	}
}
