package monkey.core.utils {
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	public class Input3D {
		
		public static const A : uint = Keyboard.A;
		public static const B : uint = Keyboard.B;
		public static const C : uint = Keyboard.C;
		public static const D : uint = Keyboard.D;
		public static const E : uint = Keyboard.E;
		public static const F : uint = Keyboard.F;
		public static const G : uint = Keyboard.G;
		public static const H : uint = Keyboard.H;
		public static const I : uint = Keyboard.I;
		public static const J : uint = Keyboard.J;
		public static const K : uint = Keyboard.K;
		public static const L : uint = Keyboard.L;
		public static const M : uint = Keyboard.M;
		public static const N : uint = Keyboard.N;
		public static const O : uint = Keyboard.O;
		public static const P : uint = Keyboard.P;
		public static const Q : uint = Keyboard.Q;
		public static const R : uint = Keyboard.R;
		public static const S : uint = Keyboard.S;
		public static const T : uint = Keyboard.T;
		public static const U : uint = Keyboard.U;
		public static const V : uint = Keyboard.V;
		public static const W : uint = Keyboard.W;
		public static const X : uint = Keyboard.X;
		public static const Y : uint = Keyboard.Y;
		public static const Z : uint = Keyboard.Z;
		public static const ALTERNATE 		: uint = Keyboard.ALTERNATE;
		public static const BACKQUOTE 		: uint = Keyboard.BACKQUOTE;
		public static const BACKSLASH		: uint = Keyboard.BACKSLASH;
		public static const BACKSPACE 		: uint = Keyboard.BACKSPACE;
		public static const CAPS_LOCK 		: uint = Keyboard.CAPS_LOCK;
		public static const COMMA 			: uint = Keyboard.COMMA;
		public static const COMMAND 		: uint = Keyboard.COMMAND;
		public static const CONTROL 		: uint = Keyboard.CONTROL;
		public static const DELETE 			: uint = Keyboard.DELETE;
		public static const DOWN 			: uint = Keyboard.DOWN;
		public static const END 			: uint = Keyboard.END;
		public static const ENTER 			: uint = Keyboard.ENTER;
		public static const EQUAL 			: uint = Keyboard.EQUAL;
		public static const ESCAPE 			: uint = Keyboard.ESCAPE;
		public static const F1 				: uint = Keyboard.F1;
		public static const F10 			: uint = Keyboard.F10;
		public static const F11 			: uint = Keyboard.F11;
		public static const F12 			: uint = Keyboard.F12;
		public static const F13 			: uint = Keyboard.F13;
		public static const F14 			: uint = Keyboard.F14;
		public static const F15 			: uint = Keyboard.F15;
		public static const F2 				: uint = Keyboard.F2;
		public static const F3 				: uint = Keyboard.F3;
		public static const F4 				: uint = Keyboard.F4;
		public static const F5 				: uint = Keyboard.F5;
		public static const F6 				: uint = Keyboard.F6;
		public static const F7 				: uint = Keyboard.F7;
		public static const F8 				: uint = Keyboard.F8;
		public static const F9 				: uint = Keyboard.F9;
		public static const HOME 			: uint = Keyboard.HOME;
		public static const INSERT 			: uint = Keyboard.INSERT;
		public static const LEFT 			: uint = Keyboard.LEFT;
		public static const LEFTBRACKET 	: uint = Keyboard.LEFTBRACKET;
		public static const MINUS 			: uint = Keyboard.MINUS;
		public static const NUMBER_0 		: uint = Keyboard.NUMBER_0;
		public static const NUMBER_1 		: uint = Keyboard.NUMBER_1;
		public static const NUMBER_2 		: uint = Keyboard.NUMBER_2;
		public static const NUMBER_3 		: uint = Keyboard.NUMBER_3;
		public static const NUMBER_4 		: uint = Keyboard.NUMBER_4;
		public static const NUMBER_5 		: uint = Keyboard.NUMBER_5;
		public static const NUMBER_6 		: uint = Keyboard.NUMBER_6;
		public static const NUMBER_7 		: uint = Keyboard.NUMBER_7;
		public static const NUMBER_8 		: uint = Keyboard.NUMBER_8;
		public static const NUMBER_9 		: uint = Keyboard.NUMBER_9;
		public static const NUMPAD 			: uint = Keyboard.NUMPAD;
		public static const NUMPAD_0 		: uint = Keyboard.NUMPAD_0;
		public static const NUMPAD_1 		: uint = Keyboard.NUMPAD_1;
		public static const NUMPAD_2 		: uint = Keyboard.NUMPAD_2;
		public static const NUMPAD_3 		: uint = Keyboard.NUMPAD_3;
		public static const NUMPAD_4 		: uint = Keyboard.NUMPAD_4;
		public static const NUMPAD_5 		: uint = Keyboard.NUMPAD_5;
		public static const NUMPAD_6 		: uint = Keyboard.NUMPAD_6;
		public static const NUMPAD_7 		: uint = Keyboard.NUMPAD_7;
		public static const NUMPAD_8 		: uint = Keyboard.NUMPAD_8;
		public static const NUMPAD_9 		: uint = Keyboard.NUMPAD_9;
		public static const NUMPAD_ADD 		: uint = Keyboard.NUMPAD_ADD;
		public static const NUMPAD_DECIMAL	: uint = Keyboard.NUMPAD_DECIMAL;
		public static const NUMPAD_DIVIDE 	: uint = Keyboard.NUMPAD_DIVIDE;
		public static const NUMPAD_ENTER 	: uint = Keyboard.NUMPAD_ENTER;
		public static const NUMPAD_MULTIPLY : uint = Keyboard.NUMPAD_MULTIPLY;
		public static const NUMPAD_SUBTRACT : uint = Keyboard.NUMPAD_SUBTRACT;
		public static const PAGE_DOWN 		: uint = Keyboard.PAGE_DOWN;
		public static const PAGE_UP 		: uint = Keyboard.PAGE_UP;
		public static const PERIOD 			: uint = Keyboard.PERIOD;
		public static const QUOTE 			: uint = Keyboard.QUOTE;
		public static const RIGHT 			: uint = Keyboard.RIGHT;
		public static const RIGHTBRACKET	: uint = Keyboard.RIGHTBRACKET;
		public static const SEMICOLON 		: uint = Keyboard.SEMICOLON;
		public static const SHIFT 			: uint = Keyboard.SHIFT;
		public static const SLASH 			: uint = Keyboard.SLASH;
		public static const SPACE 			: uint = Keyboard.SPACE;
		public static const TAB 			: uint = Keyboard.TAB;
		public static const UP 				: uint = Keyboard.UP;
		
		private static var _ups 				: Array;
		private static var _downs 				: Array;
		private static var _hits 				: Array;
		private static var _keyCode 			: int = 0;
		private static var _delta 				: int = 0;
		private static var _deltaMove 			: int = 0;
		private static var _mouseUp 			: int = 0;
		private static var _mouseHit 			: int = 0;
		private static var _mouseDown 			: int;
		private static var _rightMouseUp		: int = 0;
		private static var _rightMouseHit		: int = 0;
		private static var _rightMouseDown 		: int;
		private static var _middleMouseUp		: int = 0;
		private static var _middleMouseHit 		: int = 0;
		private static var _middleMouseDown 	: int;
		private static var _mouseDoubleClick	: int = 0;
		private static var _mouseX 				: Number = 0;
		private static var _mouseY 				: Number = 0;
		private static var _mouseXSpeed 		: Number = 0;
		private static var _mouseYSpeed 		: Number = 0;
		private static var _mouseUpdated		: Boolean = true;
		private static var _stage 				: Stage;
		private static var _doubleClickEnabled	: Boolean;
		private static var _rightClickEnabled 	: Boolean;
		private static var _stageX 				: Number = 0;
		private static var _stageY 				: Number = 0;
		private static var _currFrame 			: int;
		private static var _movementX 			: Number = 0;
		private static var _movementY 			: Number = 0;
		
		/**
		 * 初始化 
		 * @param stage
		 * 
		 */		
		public static function initialize(stage : Stage) : void {
			
			if (stage == null) {
				throw("The 'stage' parameter is null");
			}
			
			_stage 	= stage;
			_downs 	= new Array();
			_hits 	= new Array();
			_ups 	= new Array();
			_mouseX = _stage.mouseX;
			_mouseY = _stage.mouseY;
						
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, 		keyDownEvent, 			false, 0, true);
			_stage.addEventListener(KeyboardEvent.KEY_UP, 			keyUpEvent, 			false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, 			mouseMove, 			false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, 		mouseWheelEvent, 		false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, 			mouseDownEvent, 		false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_UP, 			mouseUpEvent, 			false, 0, true);
			_stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, 	middleMouseDownEvent, 	false, 0, true);
			_stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, 	middleMouseUpEvent, 	false, 0, true);
			_stage.addEventListener(Event.DEACTIVATE, 				deactivateEvent, 		false, 0, true);
			
			doubleClickEnabled = _doubleClickEnabled;
			rightClickEnabled  = _rightClickEnabled;
		}
		
		private static function deactivateEvent(e : Event) : void {
			reset();
		}
		
		public static function dispose() : void {
			if (!_stage) {
				return;
			}
			_downs 	= null;
			_hits 	= null;
			_ups 	= null;
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, 	keyDownEvent);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, 	keyUpEvent);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, 	mouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, 	mouseDownEvent);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, 	mouseUpEvent);
			_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, 	mouseWheelEvent);
			_stage.removeEventListener(MouseEvent.DOUBLE_CLICK, mouseDoubleClickEvent);
			_stage.removeEventListener(Event.DEACTIVATE, 		deactivateEvent);
			_stage = null;
		}
		
		private static function mouseMove(e : MouseEvent) : void {
			_mouseUpdated = true;
			_stageX 	  = e.stageX;
			_stageY 	  = e.stageY;
			_movementX 	  = e.movementX;
			_movementY 	  = e.movementY;
		}
		
		public static function update() : void {
			_currFrame++;
			if (_mouseUpdated) {
				_mouseXSpeed  = _stageX - _mouseX;
				_mouseYSpeed  = _stageY - _mouseY;
				_mouseUpdated = false;
			} else {
				_mouseXSpeed = 0;
				_mouseYSpeed = 0;
			}
			_mouseX = _stageX;
			_mouseY = _stageY;
		}
		
		public static function clear() : void {
			_movementX = 0;
			_movementY = 0;
			_delta = 0;
		}
		
		public static function reset() : void {
			for (var i:int = 0; i < 0xFF; i++) {
				_downs[i] = 0;
				_hits[i]  = 0;
				_ups[i]   = 0;
			}
			_movementX 	 	= 0;
			_movementY 	 	= 0;
			_mouseXSpeed 	= 0;
			_mouseYSpeed 	= 0;
			_mouseUp 	 	= 0;
			_mouseDown 	 	= 0;
			_mouseHit 	 	= 0;
			_rightMouseUp 	= 0;
			_rightMouseDown = 0;
			_rightMouseHit 	= 0;
			_middleMouseUp 	= 0;
			_middleMouseHit = 0;
			_middleMouseDown  = 0;
			_mouseDoubleClick = 0;
		}
		
		private static function keyDownEvent(e : KeyboardEvent) : void {
			if (!_downs[e.keyCode]) {
				_hits[e.keyCode] = _currFrame + 1;
			}
			_downs[e.keyCode] = _currFrame + 1;
			_keyCode = e.keyCode;
		}
		
		private static function keyUpEvent(e : KeyboardEvent) : void {
			_downs[e.keyCode] = 0;
			_hits[e.keyCode]  = 0;
			_ups[e.keyCode]   = _currFrame + 1;
			_keyCode = 0;
		}
		
		private static function mouseDownEvent(e : MouseEvent) : void {
			_mouseDown = 1;
			_mouseUp   = 0;
			_mouseHit  = _currFrame + 1;
		}
		
		private static function mouseWheelEvent(e : MouseEvent) : void {
			_delta 	   = e.delta;
			_deltaMove = _currFrame + 1;
		}
		
		private static function mouseUpEvent(e : MouseEvent) : void {
			_mouseDown = 0;
			_mouseUp   = _currFrame + 1;
			_mouseHit  = 0;
		}
		
		private static function rightMouseDownEvent(e : Event) : void {
			_rightMouseDown = 1;
			_rightMouseUp   = 0;
			_rightMouseHit  = _currFrame + 1;
		}
		
		private static function rightMouseUpEvent(e : Event) : void {
			_rightMouseDown = 0;
			_rightMouseUp   = _currFrame + 1;
			_rightMouseHit  = 0;
		}
		
		private static function middleMouseDownEvent(e : Event) : void {
			_middleMouseDown = 1;
			_middleMouseUp   = 0;
			_middleMouseHit  = _currFrame + 1;
		}
		
		private static function middleMouseUpEvent(e : Event) : void {
			_middleMouseDown = 0;
			_middleMouseUp   = _currFrame + 1;
			_middleMouseHit  = 0;
		}
		
		private static function mouseDoubleClickEvent(e : MouseEvent) : void {
			_mouseDoubleClick = _currFrame + 1;
		}
		
		public static function get keyCode() : int {
			return _keyCode;
		}
		
		public static function keyDown(keyCode : int) : Boolean {
			return _downs[keyCode];
		}
		
		public static function keyHit(keyCode : int) : Boolean {
			return _hits[keyCode] == _currFrame ? true : false;
		}
		
		public static function keyUp(keyCode : int) : Boolean {
			return _ups[keyCode] == _currFrame ? true : false;
		}
		
		public static function get mouseDoubleClick() : Boolean {
			return _mouseDoubleClick == _currFrame ? true : false;
		}
		
		public static function get delta() : int {
			return _deltaMove == _currFrame ? _delta : 0;
		}
		
		public static function set delta(value : int) : void {
			_delta = value;
		}
		
		public static function get mouseYSpeed() : Number {
			return _mouseYSpeed;
		}
		
		public static function get mouseHit() : Boolean {
			return _mouseHit == _currFrame ? true : false;
		}
		
		public static function get mouseUp() : Boolean {
			return _mouseUp == _currFrame ? true : false;
		}
		
		public static function get mouseDown() : Boolean {
			return _mouseDown;
		}
		
		public static function get rightMouseHit() : Boolean {
			return _rightMouseHit == _currFrame ? true : false;
		}
		
		public static function get rightMouseUp() : Boolean {
			return _rightMouseUp == _currFrame ? true : false;
		}
		
		public static function get rightMouseDown() : Boolean {
			return _rightMouseDown;
		}
		
		public static function get middleMouseHit() : Boolean {
			return _middleMouseHit == _currFrame ? true : false;
		}
		
		public static function get middleMouseUp() : Boolean {
			return _middleMouseUp == _currFrame ? true : false;
		}
		
		public static function get middleMouseDown() : Boolean {
			return _middleMouseDown;
		}
		
		public static function get mouseXSpeed() : Number {
			return _mouseXSpeed;
		}
		
		public static function get mouseY() : Number {
			return _mouseY;
		}
		
		public static function set mouseY(value : Number) : void {
			_mouseY = value;
		}
		
		public static function get mouseX() : Number {
			return _mouseX;
		}
		
		public static function set mouseX(value : Number) : void {
			_mouseX = value;
		}
		
		public static function get movementX() : Number {
			return _movementX;
		}
		
		public static function get movementY() : Number {
			return _movementY;
		}
		
		public static function get mouseMoved() : Number {
			return Math.abs(_mouseXSpeed + _mouseYSpeed);
		}
		
		public static function get doubleClickEnabled() : Boolean {
			return _doubleClickEnabled;
		}
		
		public static function set doubleClickEnabled(value : Boolean) : void {
			_doubleClickEnabled = value;
			_stage.doubleClickEnabled = value;
			if (value) {
				_stage.addEventListener(MouseEvent.DOUBLE_CLICK, mouseDoubleClickEvent, false, 0, true);
			} else {
				_stage.removeEventListener(MouseEvent.DOUBLE_CLICK, mouseDoubleClickEvent);
			}
		}
		
		public static function get rightClickEnabled() : Boolean {
			return _doubleClickEnabled;
		}
		
		public static function set rightClickEnabled(value : Boolean) : void {
			_rightClickEnabled = value;
			if (value) {
				_stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightMouseDownEvent, false, 0, true);
				_stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpEvent, false, 0, true);
			} else {
				_stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightMouseDownEvent);
				_stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, rightMouseUpEvent);
			}
		}
		
		public static function get downs() : Array {
			return _downs;
		}
		
		public static function get hits() : Array {
			return _hits;
		}
		
	}
}
