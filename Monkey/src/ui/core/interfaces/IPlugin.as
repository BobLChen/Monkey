package ui.core.interfaces {

	import ide.App;

	public interface IPlugin {
		function init(app : App) : void;
		function start() : void;
	}
}
