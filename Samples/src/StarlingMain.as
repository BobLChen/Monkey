package {

	import monkey.core.scene.Scene3D;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class StarlingMain extends Sprite {
		[Embed(source = "atlas.png")]
		private var AtlasTexture : Class;

		[Embed(source = "atlas.xml", mimeType = "application/octet-stream")]
		private var AtlasXml : Class;

		[Embed(source = "button_square.png")]
		private var ButtonTexture : Class;

		private var _sprite : MovieClip;
		private var _textureAtlas : TextureAtlas

		private var _leftButton : Button;
		private var _rightButton : Button;

		private var _scene : Scene3D;

		public function StarlingMain() {
			// load textures and sprite information for Starling, we also create
			// two buttons to interact with Flare3D content
			var texture : Texture = Texture.fromBitmap(new ButtonTexture());

			_leftButton = new Button(texture, "<-");
			_leftButton.addEventListener(Event.TRIGGERED, buttonEvent);
			_leftButton.useHandCursor = true;

			_leftButton.x = 200;
			_leftButton.y = 200;

			_rightButton = new Button(texture, "->");
			_rightButton.addEventListener(Event.TRIGGERED, buttonEvent2);
			_rightButton.useHandCursor = true;

			_rightButton.x = 550;
			_rightButton.y = 200;

			var xml : XML = XML(new AtlasXml);
			var textureSprite : Texture = Texture.fromBitmap(new AtlasTexture);
			_textureAtlas = new TextureAtlas(textureSprite, xml);

			addBirds();

			addChild(_leftButton);
			addChild(_rightButton);
		}

		private function addBirds() : void {
			// create and add a few Starling sprites, we update them each frame
			// to reset their position when needed
			for (var i : int = 0; i < 3; i++) {
				var mc : MovieClip = new MovieClip(_textureAtlas.getTextures("flight"));
				addChild(mc);
				Starling.juggler.add(mc);

				mc.x = 100 + (mc.width * i);
				mc.y = 150;
				mc.addEventListener(Event.ENTER_FRAME, frameEvent);
			}
		}

		private function frameEvent(e : Event) : void {
			var mc : MovieClip = e.target as MovieClip;
			mc.x++;

			if (mc.x > (800 + mc.width))
				mc.x = -mc.width;
		}

		public function get scene() : Scene3D {
			return _scene;
		}

		public function set scene(value : Scene3D) : void {
			_scene = value;
		}

		// we dispatch these events to notify Flare3D that we should rotate the model
		// this is to avoid having a Viewer3D reference in this class,
		// but that's also an option
		private function buttonEvent(e : Event) : void {
			dispatchEvent(new Event("leftButtonEvent"));
		}

		private function buttonEvent2(e : Event) : void {
			dispatchEvent(new Event("rightButtonEvent"));
		}
	}
}
