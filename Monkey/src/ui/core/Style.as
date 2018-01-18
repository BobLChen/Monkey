package ui.core {

	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.text.TextFormat;
	import ui.core.controls.BitmapFont;

	/**
	 * 样式
	 * @author neil
	 *
	 */
	public class Style {
		public static var focusFilter 		: Array = [new GlowFilter(0xFFFFFF, 1, 2, 2, 2, 4)];
		public static var innerFocusFilter 	: Array = [focusFilter[0], new GlowFilter(0xFFFFFF, 1, 2, 2, 2, 4, true)];
		public static var backgroundColor 	: int = 0x404040;
		public static var backgroundColor2 	: int = 0x202020;
		public static var selectionColor 	: int = 0x292929;
		public static var borderColor 		: int = 0x151515;
		public static var borderColor2 		: int = 0x606060;
		public static var borderColor3 		: int = 0x505050;
		public static var labelsColor 		: int = 0x9F9F9F;
		public static var labelsColor2 		: int = 8421631;
		public static var defaultFormat 	: TextFormat = new TextFormat(null, 12, labelsColor);
		public static var defaultFont 		: BitmapFont = new BitmapFont(defaultFormat);
		public static var colorTransform 	: ColorTransform = new ColorTransform(-1, -1, -1, 1, 0xFF, 0xFF, 0xFF);
	}
}
