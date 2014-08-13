package Clases.network
{
	import Clases.Banca.VOBanca;
	import Clases.MD5;
	
	import Cliente.CSocket;
	
	import Events.SocketDataEvent;
	import Events.SocketDataProgress;
	import Events.SocketEvent;
	
	import Server.SSocket;
	
	import Sockets.HipicoSocketListener;
	
	import VOs.VOTaquilla;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	
	[Event(name="conectado", type="Events.SocketEvent")]
	[Event(name="desconectado", type="Events.SocketEvent")]
	[Event(name="dataComplete", type="Events.SocketDataProgress")]
	[Event(name="dataSend", type="Events.SocketDataProgress")]
	public class netManager extends EventDispatcher
	{
		private var socket:SSocket;
		public var tabla:TablaListeners;
		public var ganador:GanadorListeners;
		public var remate:RemateListeners;
		public var tablavisor:TablaVisorListeners;
		public var macuare:MacuareListeners;
		
		public static var ACTIVIDAD:HipicoActividad;
		
		private var _taquilla:VOTaquilla;

		private var _numTaquillas:int;
		public function get numTaquillas():int { return _numTaquillas; }

		private var _taquillas:Vector.<VOTaquilla>;
		public function get taquillas():Vector.<VOTaquilla> { return _taquillas; }
		
		public function conectarTaquilla (taquilla:VOTaquilla):Boolean {
			var i:int;
			for (i = 0; i < _numTaquillas; i++) {
				if (_taquillas[i].contrasena==taquilla.contrasena) return false;
			}
			_taquillas.push(taquilla); _numTaquillas++;
			return true;
		}
		public function desconectarTaquilla (contrasena:String):void {
			var i:int;
			contrasena = MD5.hash(contrasena);
			for (i = 0; i < _numTaquillas; i++) {
				if (_taquillas[i].contrasena==contrasena) {
					_taquillas.splice(i,1); _numTaquillas--;	
				}
			}
		}
		public function netManager() {
			_taquillas = new <VOTaquilla>[];
			socket = new SSocket;
			socket.addEventListener(SocketEvent.CONECTADO,onClienteConectado);
			socket.addEventListener(SocketDataProgress.DATA_COMPLETE,onDataComplete);
			socket.addEventListener(SocketDataProgress.DATA_SEND,onDataSend);
			
			//socket.bind(7090,Global.banca.config.servidorLocal);
			socket.bind(7090,"0.0.0.0");
			
			socket.escuchar();
			tabla = new TablaListeners(socket);
			ganador = new GanadorListeners(socket);
			remate = new RemateListeners(socket);
			tablavisor = new TablaVisorListeners(socket);
			macuare = new MacuareListeners(socket);
			_clientes = [];
			
			Global.registros.add("Escuchando conexiones en 0.0.0.0:7090");
			
			ACTIVIDAD = new HipicoActividad("http://sistemasrequena.com/apps/hipico/actividad.php");
			ACTIVIDAD.setData("banca",Global.banca.config.webID);
		}
		public function close():void {
			socket.close();
		}
		protected function onDataSend(event:SocketDataProgress):void {
			dispatchEvent(event.clone());
		}
		protected function onDataComplete(event:SocketDataProgress):void {
			dispatchEvent(event.clone());
		}
		public function get bytesReport():String {
			return Global.nf.format(bytesRecibidos/1000)+" kb recibidos / "+Global.nf.format(bytesEnviados/1000)+" kb enviados"
		}
		public function get bytesRecibidos():uint { return socket.bytesRecibidos; }
		
		public function get bytesEnviados():uint { return socket.bytesEnviados; }
		
		private var _clientes:Array;
		public function get clientes():Array {
			return _clientes;
		}
		
		public function cliente (indice:int):CSocket {
			return socket.clientes[indice];
		}
		public function clientesByCampo(campos:Object):Vector.<int> {
			return socket.getClientesCampos(campos);
		}
		
		protected function onClienteConectado(event:SocketEvent):void {
			event.socket.addEventListener(SocketEvent.DATA_CHANGE,clienteSocket_dataChange,false,3);
			event.socket.addEventListener(SocketEvent.DESCONECTADO,clienteSocket_desconectado,false,3);
			event.socket.addEventListener(HipicoSocketListener.HIPODROMOS_CARRERA,clienteSocket_hipodromosCarrera);
		}
			
		protected function activacion_complete(event:Event):void {
			Global.registros.add("activacion completa",File.lineEnding,JSON.stringify((event.target as URLLoader).data,null,3));
		}
		
		protected function clienteSocket_hipodromosCarrera(event:SocketDataEvent):void {
			var hipodromos:Array = Global.banca.carreras.leerFHC(event.data,"",0,"Hipodromo","Hipodromo");
			if (hipodromos)
				event.socket.enviarDatos(HipicoSocketListener.HIPODROMOS_CARRERA,hipodromos);
			else
				event.socket.enviarDatos(HipicoSocketListener.HIPODROMOS_CARRERA,new Array);
		}
		
		protected function clienteSocket_desconectado(event:SocketEvent):void {
			if (event.socket.data && event.socket.data.banca>0) {
				desconectarTaquilla(event.socket.data.pass);
				var b:VOBanca = Global.banca.bancas.bancaByID(event.socket.data.banca);
				if (b && event.socket.data.estado==VOTaquilla.CONECTADO) {
					switch(event.socket.data.tipo) {
						case "Tabla": {
							b.numTablas--;
							break;
						}
						case "Ganador": { 
							b.numGanadores--;
							break;
						}
						case "Macuare": {
							b.numMacuares--;
							break;
						}
						case "Remate": {
							b.numRemates--;
							break;
						}
					}
					var i:int;
					for (i = 0; i < _clientes.length; i++) {
						if (_clientes[i].data.usuario==event.socket.data.usuario) {
							_clientes.splice(i,1); break;
						}
					}
				}
				dispatchEvent(new SocketEvent(SocketEvent.DESCONECTADO,event.socket));
				Global.registros.add("Cerrando conexion de "+event.socket.ip+": "+JSON.stringify(event.socket.data));
				ACTIVIDAD.send(_taquilla.taquillaID,_taquilla.tipo,b.Nombre,HipicoActividad.NET_LOGOUT,_taquilla.nombre,event.socket.data.version);
			}
		}
		protected function clienteSocket_dataChange(event:SocketEvent):void {
			event.socket.data.conectadoDesde = new Date;
			event.socket.data.estado = VOTaquilla.CONECTANDO;
			_taquilla = Global.banca.taquillas.buscar(event.socket.data.pass);
			var t:String = (event.socket.data.tipo as String).toUpperCase();
			if (_taquilla && _taquilla.tipoString == t) {
				if (!conectarTaquilla(_taquilla)) {
					event.socket.enviarDatos("CONEXION_RECHAZADA","USUARIO YA ESTA CONECTADO");
					return;
				}
				var data:Object = { Contrasena:Global.banca.config.contrasena};
				var banca:VOBanca = Global.banca.bancas.bancaByID(_taquilla.banca);
				if (banca) {
					event.socket.data.banca = _taquilla.banca;
					event.socket.data.taquilla = _taquilla.nombre;
					event.socket.data.appid = _taquilla.taquillaID;
					data.Nombre = banca.Nombre;
					data.RIF = banca.RIF;
					data.Taquilla = _taquilla.nombre;
					data.Activo = _taquilla.activa;
					data.banca = banca.ID;
					if (_taquilla.activa) {
						switch(event.socket.data.tipo) {
							case "Tabla": {
								banca.numTablas++;
								tabla.setListeners(event.socket);
								break;
							}
							case "Ganador": { 
								banca.numGanadores++;
								ganador.setListeners(event.socket);
								break;
							}
							case "Remate": {
								banca.numRemates++;
								remate.setListeners(event.socket);
								data.Porcentaje = banca.remate_porcentaje;
								break;
							}
							case "TablaVisor": {
								tablavisor.setListeners(event.socket);
								break;
							}
							case "Macuare": {
								banca.numMacuares++;
								macuare.setListeners(event.socket);
								break;
							}
						}
						_clientes.push(event.socket);
						event.socket.enviarDatos(HipicoSocketListener.CONFIGURACION,data);
						dispatchEvent(new SocketEvent(SocketEvent.CONECTADO,event.socket));
						Global.registros.add("Conexion entrante desde "+event.socket.ip+": "+JSON.stringify(event.socket.data));
						event.socket.data.estado = VOTaquilla.CONECTADO;
						ACTIVIDAD.send(_taquilla.taquillaID,_taquilla.tipo,banca.Nombre,HipicoActividad.NET_LOGIN,_taquilla.nombre,event.socket.data.version);
					} else {
						event.socket.enviarDatos("CONEXION_RECHAZADA","USUARIO INACTIVO");
						event.socket.data.estado = VOTaquilla.USUARIO_INACTIVO;
					}
				} else {
					data.bancas = Global.banca.bancas.bancas;
					event.socket.enviarDatos(HipicoSocketListener.BANCA_INVALIDA,data);
					Global.registros.add("Conexion entrante desconocida desde "+event.socket.ip+": "+event.socket.ip);
				}
				data=null;	
			} else {
				event.socket.enviarDatos("CONEXION_RECHAZADA","USUARIO INVALIDO");
				event.socket.data.estado = VOTaquilla.USUARIO_INVALIDO;
				ACTIVIDAD.send("",HipicoActividad.clienteTipo(event.socket.data.tipo),"",HipicoActividad.NET_LOGREJECTED,event.socket.data.pass,event.socket.data.version);
			}
		}
		private function updateApp(socket:CSocket):void {
			socket.enviarDatos("updateApp",null);
		}
		public function ejemplarRetirar(ejemplar:Object,carrera:Object):void {
			var e:Object = new Object;
			e.Nombre = ejemplar.Nombre;
			e.Numero = ejemplar.Numero;
			e.Retirado = ejemplar.Retirado;
			
			var o:Object = new Object;
			o.carrera = carrera;
			o.ejemplar = e;
			socket.enviarTodos(HipicoSocketListener.RETIRAR_EJEMPLAR,o);
			o=null;e=null;
		}
	}
}