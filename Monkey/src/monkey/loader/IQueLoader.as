package monkey.loader {
	
	import flash.events.IEventDispatcher;
	
	/**
	 * 队列loader 
	 * @author Neil
	 * 
	 */	
	public interface IQueLoader extends IEventDispatcher {
		function load()  : void;
		function close() : void;
		function get bytesTotal()  	: uint;
		function get bytesLoaded() 	: uint;
		function get loaded() 		: Boolean;
	}
	
}
