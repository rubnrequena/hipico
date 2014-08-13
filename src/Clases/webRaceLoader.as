package Clases
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import org.osflash.signals.Signal;

	public class webRaceLoader
	{
		private var _onError:Signal;
		private var _url:String;
		private var _banca:String;
		public function webRaceLoader(url:String,banca:String,onError:Function) { _url = url; _banca = banca; _onError = new Signal; _onError.addOnce(onError); }
		
		public function cargar(fecha:String,hipodromo:String,callback:Function):void {
			var loader:URLLoader = new URLLoader;
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			var req:URLRequest = new URLRequest(_url);
			req.method = "GET";
			loader.addEventListener(IOErrorEvent.IO_ERROR,function (event:IOErrorEvent):void { 
				_onError.dispatch("#"+event.errorID+": Carreras no cargadas");
			});
			var vars:URLVariables = new URLVariables;
			vars.fecha = fecha;
			vars.banca = Global.banca.config.webID;
			if (hipodromo) vars.hipodromo = hipodromo;
			vars.banca = _banca;
			req.data = vars;
			
			loader.addEventListener(Event.COMPLETE,function(event:Event):void {
				try {
					var obj:Array = JSON.parse(event.currentTarget.data) as Array;
					callback(obj);
				} catch (e:Error) {
					_onError.dispatch(e.message);
				}
			},false,0,true);
			loader.load(req);
		}
	}
}