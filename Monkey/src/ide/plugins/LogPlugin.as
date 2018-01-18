package ide.plugins {

	import flash.events.Event;
	import flash.text.TextFieldType;
	
	import ide.App;
	import ide.events.LogEvent;
	
	import ui.core.container.Panel;
	import ui.core.controls.InputText;
	import ui.core.interfaces.IPlugin;

	public class LogPlugin implements IPlugin {
		
		private var _app 	: App;				// app
		private var _panel 	: Panel;			// panel
		private var _output : InputText;		// output

		public function LogPlugin() {
			this._output = new InputText("Hi! ^_^", true);
		}
		
		public function init(app : App) : void {
			
			this._app = app;
			this._output.minHeight = 20;
			this._output.textField.type = TextFieldType.DYNAMIC;
			
			this._panel = new Panel("Console", 200, 100, false);
			this._panel.minHeight = -1;
			this._panel.margins = 5;
			this._panel.addControl(this._output);
			
			this._app.addEventListener(LogEvent.LOG, onLog);
			this._app.studio.output.addPanel(this._panel);
			this._app.studio.output.open();
			this._app.studio.output.addMenu("Clear", clearLog);
		}
		
		/**
		 * 日志 
		 * @param event
		 * 
		 */		
		private function onLog(event : LogEvent) : void {
			var date : Date  = new Date();
			var msg : String = "" + date.hours + ":" + date.minutes + ":" + date.seconds + ":";
			if (event.level == LogEvent.NORMAL) {
				msg += "<font color='#207020'>" + event.log + "</font> \n";
			} else if (event.level == LogEvent.ERROR) {
				msg += "<font color='#FF0000'>" + event.log + "</font> \n";
			} else {
				msg += "<font color='#907020'>" + event.log + "</font> \n";
			}
			this._output.textField.htmlText += msg;
			this._output.textField.scrollV = this._output.textField.maxScrollV;
		}

		private function clearLog(e : Event) : void {
			this._output.text = "";
		}
				
		public function start() : void {

		}
	}
}
