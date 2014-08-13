package Clases.network
{
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.sendToURL;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class HipicoActividad extends EventDispatcher
	{
		public static const NET_LOGIN:int = 0;
		public static const NET_LOGOUT:int = 1;
		public static const NET_LOGREJECTED:int = 2;
		public static const NET_LOGINADMIN:int = 3;
		
		public static const TAQ_REGISTRO:int=10;
		public static const TAQ_REMOVER:int=11;
		public static const TAQ_CAMBIO_BANCA:int=12;
		
		public static const ACT_CARRERA_ABRE:int=20;
		public static const ACT_CARRERA_CIERRA:int=21;
		
		public static const TBL_CARGAWEB:int=30;
		public static const TBL_SELECCIONADA:int=31;
		
		private var _req:URLRequest;
		private var _vars:URLVariables;
		private var _load:URLLoader;
				
		public function HipicoActividad(url:String) {
			super();
			_load = new URLLoader;
			_load.addEventListener(IOErrorEvent.IO_ERROR,onError);
			_req = new URLRequest(url);
			_req.method = URLRequestMethod.GET;
			_vars = new URLVariables;
			
		}
		public function setData (key:String,value:*):void {
			_vars[key] = value;
		}
		public function send (appid:String,tipo:int,nombre:String,actividad:int,desc:String="",version:String=""):void {
			if (appid=="") {
				appid = HIPICO.flags.appid;
				version = HIPICO.flags.version;
			}
			_vars.appid = appid;
			_vars.actividad = actividad;
			_vars.descripcion = desc;
			_vars.cliente = tipo;
			_vars.nombre = nombre;
			_vars.version = version;
			
			_req.data = _vars;
			_load.load(_req);
		}
		
		protected function onError(event:IOErrorEvent):void {
			MonsterDebugger.trace(this,event,"HipicoActividad.as",event.type,0xff0000);
		}
		public static function clienteTipo (s:String):int {
			switch(s.toUpperCase()) {
				case "GANADOR": { return 0; break; }
				case "TABLA": { return 1; break; }
				case "REMATE": { return 2; break; }
				case "MACUARE": { return 3; break; }
				case "GANADOR": { return 4; break; }
				default: { return -1; break; }
			}
		}
	}
}