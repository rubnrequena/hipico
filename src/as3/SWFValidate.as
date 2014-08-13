package as3
{
	import Clases.MD5;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.OutputProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.sampler.NewObjectSample;
	import flash.utils.Timer;
	
	[Event(name="licenciaExpirada", type="flash.events.Event")]
	[Event(name="licenciaInvalida", type="flash.events.Event")]
	[Event(name="licenciaInsertada", type="flash.events.Event")]
	[Event(name="licenciaUpdate", type="flash.events.Event")]
	public class SWFValidate extends EventDispatcher
	{
		private var swfTime:Number;
		private var keyTime:Number=-1;
		private var timeLeft:Number;
		
		private var file:File;
		private var fs:FileStream;
		
		private var t:Timer;
		
		public static const SEGUNDO:int = 1000; // SEGUNDO
		public static const MINUTO:int = 60000; // MINUTO
		public static const HORA:int = 3600000 // HORA
		
		/**
		 * @param onState <code>function (state:String):void {}</code> 
		 */		
		
		public function SWFValidate() {
			super();
			fs = new FileStream;
			appName = MD5.hash(NativeApplication.nativeApplication.applicationID);
			file = File.applicationDirectory.resolvePath(NativeApplication.nativeApplication.applicationID+".swf");  
			swfTime = file.creationDate.time;
			
		}
		protected function tick(event:TimerEvent):void {
			updateTime(SEGUNDO);
		}
		public function validate():void {
			file = File.applicationStorageDirectory.resolvePath(appName);
			if (file.exists) {
				fs.open(file,FileMode.READ);
				keyTime = fs.readDouble();
				timeLeft = fs.readDouble();
				fs.close();
				dispatchEvent(new Event("licenciaUpdate"));
			} else {
				keyTime=-1;
			}
			
			t = new Timer(SEGUNDO);
			t.addEventListener(TimerEvent.TIMER,tick);
			if (keyTime>0) {
				if (!validateSWF||timeAvailable<0) {
					dispatchEvent(new Event("licenciaExpirada"));
					t.stop();
				} else {
					t.start();
				}
			} else {
				dispatchEvent(new Event("licenciaInvalida"));
			}
		}
		public function dispose():void {
			t.stop();
			t.removeEventListener(TimerEvent.TIMER,tick);
			t=null;
			fs = null;
			file=null;
			_timeAvailable=null;
		}
		public function get validateSWF():Boolean {
			return swfTime==keyTime;
		}
		public function get timeAvailable():Number {
			return timeLeft;
		}
		private var _timeAvailable:Date;

		private var appName:String;
		public function get timeAvailableDate():Date {
			_timeAvailable = new Date(null,null,null,null,null,null,timeLeft);
			return _timeAvailable;
		}
		public function create (key:String):void {
			key = int("0x"+key.toLowerCase()).toString();
			var a:int = 2000+int(key.substr(0,2));
			var m:int = int(key.substr(2,2))-1;
			var d:int = int(key.substr(4,2));
			var t:int = int(key.substr(6,key.length-6));
			var now:Date = new Date;
			if (now.fullYear==a && now.month==m && now.date==d) {
				keyTime=t*SEGUNDO*60*60;
				update(keyTime);
				fs.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS,licenciaCreated);
			} else {
				dispatchEvent(new Event("licenciaInvalida"));
			}
		}
		
		protected function licenciaCreated(event:OutputProgressEvent):void {
			fs.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS,licenciaCreated);
			dispatchEvent(new Event("licenciaInsertada"));
		}
		private  function update (time:int):void {
			timeLeft = time;
			fs.openAsync(file,FileMode.WRITE);
			fs.writeDouble(swfTime);
			fs.writeDouble(time);
			fs.close();
		}
		protected function updateTime (time:Number):void {
			timeLeft = timeLeft-time;
			dispatchEvent(new Event("licenciaUpdate"));
			if (validateSWF) {
				if (timeAvailable<=0) {
					dispatchEvent(new Event("licenciaExpirada"));
					t.stop(); t=null;
				} else {
					update(timeLeft);
				}
			} else {
				dispatchEvent(new Event("licenciaInvalida"));
			}
		}
	}
}