package ide.utils {

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	import ide.App;
	import ide.events.LogEvent;
	
	/**
	 * 
	 * @author Neil
	 * 
	 */	
	public class FbxParserMacCMD extends EventDispatcher {

		private var fbxPath : String;
		private var process : NativeProcess;
		
		/**
		 * 就是要这么多参数，任性。 
		 * @param normal			解析法线
		 * @param tangent			解析切线
		 * @param uv0				解析uv0
		 * @param uv1				解析uv1
		 * @param anim				解析动画
		 * @param geometry			geometry矩阵
		 * @param world				world矩阵
		 * @param quat				使用四元数
		 * @param quatBoneNum		四元数最大骨骼数
		 * @param m34BoneNum		m34矩阵最大骨骼数
		 * @param mount				挂节点
		 * @param path				fbx文件路径
		 * 
		 */		
		public function FbxParserMacCMD(normal : Boolean, tangent : Boolean, uv0 : Boolean, uv1 : Boolean, anim : Boolean, geometry : Boolean, world : Boolean, quat : Boolean, quatBoneNum : int, m34BoneNum : int, mount : String, path : String) {
			
			this.fbxPath = path;
			
			var nativeProcessStartupInfo : NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var file : File = File.applicationDirectory.resolvePath("FbxParser.py");
			nativeProcessStartupInfo.executable = file;

			var args : Vector.<String> = new Vector.<String>();
			if (normal) {
				args.push("-normal");				
			}
			if (tangent) {
				args.push("-tangent");
			}
			if (uv0) {
				args.push("-uv0");
			}
			if (uv1) {
				args.push("-uv1");
			}
			if (anim) {
				args.push("-anim");
			}
			if (geometry) {
				args.push("-geometry");
			}
			if (world) {
				args.push("-world");
			}
			if (quat) {
				args.push("-quat");
			}
			args.push("-max_quat=" + quatBoneNum);
			args.push("-max_m34=" + m34BoneNum);
			args.push("-path=" + path);
			args.push("-mount=" + mount);
			
			nativeProcessStartupInfo.arguments = args;
			process = new NativeProcess();
			process.start(nativeProcessStartupInfo);
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, 	onOutputData);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, 	onErrorData);
			process.addEventListener(NativeProcessExitEvent.EXIT, 			onExit);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, 	onIOError);
		}
		
		public function onOutputData(event : ProgressEvent) : void {
			var msg : String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
			App.core.dispatchEvent(new LogEvent(msg));
			if (msg.indexOf("ʕ•̫͡•ʕ*̫͡*ʕ") != -1) {
				App.core.dispatchEvent(new LogEvent("解析完成:" + this.fbxPath));
				this.dispatchEvent(new Event(Event.COMPLETE));
				process.exit();
			}
		}
		
		public function onErrorData(event : ProgressEvent) : void {
			App.core.dispatchEvent(new LogEvent(process.standardError.readUTFBytes(process.standardError.bytesAvailable)));
		}
		
		public function onExit(event : NativeProcessExitEvent) : void {
			App.core.dispatchEvent(new LogEvent("" + event.exitCode));
		}
		
		public function onIOError(event : IOErrorEvent) : void {
			App.core.dispatchEvent(new LogEvent(event.toString()));
		}
		
	}
}
