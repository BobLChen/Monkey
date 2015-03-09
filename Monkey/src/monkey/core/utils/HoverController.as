package monkey.core.utils {
	
	import flash.geom.Vector3D;
	
	import monkey.core.base.Object3D;

	public class HoverController {

		public static const RADIANS_TO_DEGREES : Number = 180 / Math.PI;
		public static const DEGREES_TO_RADIANS : Number = Math.PI / 180;
		
		public var minPanAngle			: Number = -360;		// minPan
		public var maxPanAngle			: Number = 360; 		// maxpan
		public var minTiltAngle			: Number = 15; 			//
		public var maxTiltAngle			: Number = 85;
		public var steps				: int 	 = 8; 			// steps
		public var yFactor				: Number = 2; 			//
		public var wrapPanAngle			: Boolean= false;
		public var hasTweenStep			: Boolean= true;
		public var maxDistance 			: Number = 1000;
		public var minDistance 			: Number = -1000;
		
		private var _panAngle			: Number = 0; 			// panAngle
		private var _tiltAngle			: Number = 45; 			// tileAngle
		private var _distance			: Number = 300; 		// distance
		private var _pivot				: Object3D;
		private var _ref				: Object3D;
		private var _out 				: Vector3D;
		private var _currentPanAngle	: Number = 0;
		private var _currentDistance	: Number = 0;
		private var _currentTiltAngle	: Number = 90;
		
		public function HoverController(pivot:Object3D, ref:Object3D, pan : Number, tilt : Number, dist : Number) {
			this._currentTiltAngle 	= tilt;
			this._currentPanAngle  	= pan;
			this._currentDistance  	= dist;
			this._pivot 			= pivot;
			this._ref   			= ref;
			this._out   			= new Vector3D();
			this.panAngle  			= pan;
			this.tiltAngle 			= tilt;
			this.distance  			= dist;
		}
		
		public function get target():Object3D {
			return _ref;
		}

		public function set target(value:Object3D):void {
			_ref = value;
		}
		
		public function get pivot():Object3D {
			return _pivot;
		}

		public function set pivot(value:Object3D):void {
			_pivot = value;
		}

		public function get distance():Number {
			return _distance;
		}

		public function set distance(value:Number):void {
			value = Math.max(value, minDistance);
			value = Math.min(value, maxDistance);
			_distance = value;
		}
		
		public function get tiltAngle():Number {
			return _tiltAngle;
		}

		public function set tiltAngle(value:Number):void {
			value = Math.max(value, minTiltAngle);
			value = Math.min(value, maxTiltAngle);
			_tiltAngle = value;
		}

		public function get panAngle():Number {
			return _panAngle;
		}
		
		public function set panAngle(value:Number):void {
			value = Math.max(value, minPanAngle);
			value = Math.min(value, maxPanAngle);
			_panAngle = value;
		}
		
		public function update():void {
			if (tiltAngle != _currentTiltAngle || panAngle != _currentPanAngle || distance != _currentDistance) {
				if (wrapPanAngle) {
					if (panAngle < 0) {
						panAngle = (panAngle % 360) + 360;
					} else {
						panAngle = panAngle % 360;
					}
					if (panAngle - _currentPanAngle < -180) {
						_currentPanAngle -= 360;
					} else if (panAngle - _currentPanAngle > 180) {
						_currentPanAngle += 360;
					}
				}
				if (hasTweenStep) {
					_currentTiltAngle += (tiltAngle - _currentTiltAngle) / (steps + 1);
					_currentPanAngle += (panAngle - _currentPanAngle) / (steps + 1);
					_currentDistance += (distance - _currentDistance)/ (steps + 1);
				} else {
					_currentTiltAngle = tiltAngle;
					_currentPanAngle = panAngle;
				}
				if ((Math.abs(tiltAngle - _currentTiltAngle) < 0.01) &&
					(Math.abs(panAngle - _currentPanAngle) < 0.01) &&
					(Math.abs(distance - _currentDistance) < 0.01)
				) {
					_currentTiltAngle = tiltAngle;
					_currentPanAngle = panAngle;
					_currentDistance = distance;
				}
			}
			
			_ref.transform.getPosition(false, _out);
			_pivot.transform.x = _out.x + _currentDistance * Math.sin(_currentPanAngle * DEGREES_TO_RADIANS) * Math.cos(_currentTiltAngle * DEGREES_TO_RADIANS);
			_pivot.transform.z = _out.z + _currentDistance * Math.cos(_currentPanAngle * DEGREES_TO_RADIANS) * Math.cos(_currentTiltAngle * DEGREES_TO_RADIANS);
			_pivot.transform.y = _out.y + _currentDistance * Math.sin(_currentTiltAngle * DEGREES_TO_RADIANS) * yFactor;
			_pivot.transform.lookAt(_out.x, _out.y, _out.z);
		}

	}
}
