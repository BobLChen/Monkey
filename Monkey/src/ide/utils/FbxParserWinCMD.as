package ide.utils
{
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

	public class FbxParserWinCMD extends EventDispatcher {
		
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
		public function FbxParserWinCMD(normal : Boolean, tangent : Boolean, uv0 : Boolean, uv1 : Boolean, anim : Boolean, geometry : Boolean, world : Boolean, quat : Boolean, quatBoneNum : int, m34BoneNum : int, mount : String, path : String) {
			
			this.fbxPath = path;
			
			if (!NativeProcess.isSupported) {
				App.core.dispatchEvent(new LogEvent("不支持Fbx插件"));
			}
			
			var info : NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.executable = new File("c:\\windows\\system32\\cmd.exe");
			
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, 	onOutput);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, 	onErrorData);
			process.addEventListener(NativeProcessExitEvent.EXIT, 			onExit);
			process.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError);
			process.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, 	onIOError);
			process.start(info);
			
			var url : String = File.applicationDirectory.nativePath;
			var dir : String = url.split(":")[0];
			
			process.standardInput.writeUTFBytes("" + dir + ":\n");
			process.standardInput.writeUTFBytes("cd " + url + "\n");  
			
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
			args.push("-path='" + path + "'");
			args.push("-mount='" + mount + "'");
			
			App.core.dispatchEvent(new LogEvent(info.executable.url + "-" + info.executable.exists));
			
			var cmd : String = args.join(" ");
			process.standardInput.writeUTFBytes("python FbxParser.py " + cmd + "\n");
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
		
		protected function onOutput(event:ProgressEvent):void {
			var msg : String = process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
			App.core.dispatchEvent(new LogEvent(msg));
			if (msg.indexOf("ʕ•̫͡•ʕ*̫͡*ʕ") != -1) {
				App.core.dispatchEvent(new LogEvent("解析完成:" + this.fbxPath));
				this.dispatchEvent(new Event(Event.COMPLETE));
				process.exit();
			}			
		}
	}
}