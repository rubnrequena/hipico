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
		private var swfTime:Number=0;
		private var keyTime:Number=-1;
		private var timeLeft:Number=0;
		private var keyCreatedTime:Number=0;
		
		private var file:File;
		private var fs:FileStream;
		
		private var t:Timer;
		
		public static const SEGUNDO:int = 1000; // SEGUNDO
		public static const MINUTO:int = 60000; // MINUTO
		public static const HORA:int = 3600000; // HORA
		public var verbose:Boolean=true;
			
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
			updateTime(MINUTO);
		}
		public function validate():void {
			_trace("validating");
			file = File.applicationStorageDirectory.resolvePath(appName);
			if (file.exists) {
				fs.open(file,FileMode.READ);
				keyTime = fs.readDouble();
				keyCreatedTime = fs.readDouble();
				timeLeft = fs.readDouble();
				fs.close();
				fs.open(file,FileMode.UPDATE);
				_trace("validating","licenciaUpdate");
				dispatchEvent(new Event("licenciaUpdate"));
			} else {
				fs.open(file,FileMode.UPDATE);
				keyTime=-1;
				keyCreatedTime=0;
			}
			
			t = new Timer(MINUTO);
			t.addEventListener(TimerEvent.TIMER,tick);
			if (keyTime>0) {
				if (validSWF&&validKey&&timeAvailable>=0) {
					t.start();
				} else {
					_trace("validating","licenciaExpirada");
					dispatchEvent(new Event("licenciaExpirada"));
					t.stop();
				}
			} else {
				dispatchEvent(new Event("licenciaInvalida"));
			}
		}
		
		private function _trace(...params):void {
			if (verbose) trace("SWFValidate:",params);
		}
		public function dispose():void {
			_trace("dispose");
			t.stop();
			t.removeEventListener(TimerEvent.TIMER,tick);
			t=null;
			fs.close();
			fs = null;
			file=null;
			_timeAvailable=null;
		}
		public function get validSWF():Boolean {
			return swfTime==keyTime;
		}
		public function get validKey():Boolean {
			return keyCreatedTime==file.creationDate.time;
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
			_trace("creandoLicencia",key,a,m,d,t);
			if (now.fullYear==a && now.month==m && now.date==d) {
				keyTime=t*HORA;
				//fs.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS,licenciaCreated);
				update(keyTime);
				_trace("licenciaInsertada");
				dispatchEvent(new Event("licenciaInsertada"));
				dispatchEvent(new Event("licenciaUpdate"));
			} else {
				_trace("creandoLicencia","licenciaInvalida");
				dispatchEvent(new Event("licenciaInvalida"));
			}
		}
		
		protected function licenciaCreated(event:OutputProgressEvent):void {
			fs.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS,licenciaCreated);
			_trace("licenciaInsertada");
			dispatchEvent(new Event("licenciaInsertada"));
		}
		private  function update (time:Number):void {
			timeLeft = time;
			if (keyCreatedTime==0) keyCreatedTime = file.creationDate.time;
			fs.position=0;
			fs.writeDouble(swfTime);
			fs.writeDouble(keyCreatedTime);
			fs.writeDouble(time);
		}
		protected function updateTime (time:Number):void {
			timeLeft = timeLeft-time;
			dispatchEvent(new Event("licenciaUpdate"));
			if (validSWF) {
				if (timeAvailable<=0) {
					_trace("licenciaUpdating","licenciaExpirada");
					dispatchEvent(new Event("licenciaExpirada"));
					t.stop(); t=null;
				} else {
					update(timeLeft);
				}
			} else {
				_trace("licenciaUpdating","licenciaInvalida");
				dispatchEvent(new Event("licenciaInvalida"));
			}
		}
	}
}