package Clases.network
{
	import Clases.Tabla.Tablas_Padre;
	import Clases.network.events.ConexionEvent;
	
	import Cliente.CSocket;
	
	import Events.SocketDataEvent;
	import Events.SocketEvent;
	
	import Server.SSocket;
	
	import Sockets.HipicoSocketListener;
	
	import events.Evento;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import sr.modulo.Modulo;

	[Event(name="ventaTickets", type="flash.events.Event")]
	[Event(name="statusCarrera", type="Clases.network.events.ConexionEvent")]
	[Event(name="tablaTicketEliminado", type="Events.SocketDataEvent")]
	[Event(name="clientesChange", type="Events.SocketEvent")]
	public final class TablaListeners extends EventDispatcher
	{
		public static const STATUS_CARRERA:String = "statusCarrera";
		
		private var _socket:SSocket;
		
		private var _clientes:uint;
		public function TablaListeners (socket:SSocket) { _socket = socket; }
		public function get clientes():uint { return _clientes; }	
		
		public function setListeners(socket:CSocket):void {
			_clientes++;
			dispatchEvent(new SocketEvent("clientesChange",socket));
			
			socket.addEventListener(SocketEvent.DESCONECTADO,socket_desconectado);
			socket.addEventListener(HipicoSocketListener.LEER_CARRERA,socket_leerCarrera);
			socket.addEventListener(HipicoSocketListener.VENTA_TICKETS,socket_ventaTickets);
			socket.addEventListener(HipicoSocketListener.ELIMINAR_TICKET,socket_eliminarTicket);
			socket.addEventListener(HipicoSocketListener.REPORTE_DIARIO,socket_reporteDiario);
			socket.addEventListener("ticketPagado",socket_ticketPagado);
			socket.addEventListener("leerTicket",socket_leerTicket);
			socket.addEventListener("reporteTickets",socket_reporteTickets);
		}
		
		protected function socket_leerTicket(event:SocketDataEvent):void {
			var ticket:Array = Global.tablas.sql('SELECT Premiados.FHC, Premiados.Fecha,Premiados.Hipodromo,Premiados.Carrera,Numero,Nombre,Monto,Cantidad,VentaID,Hora,pago,Paga,(Paga*Cantidad) Premio FROM Premiados' +
				' JOIN Tablas_Padre ON Premiados.FHC = Tablas_Padre.FHC AND Premiados.BancaID = Tablas_Padre.BancaID' +
				' WHERE Premiados.VentaID = '+event.data+' AND Premiados.Taquilla = "'+event.socket.data.taquilla+'" AND Premiados.BancaID = '+event.socket.data.banca).data;
			if (ticket) {
				var g:Array = Global.tablas.ganadores.leer({FHC:ticket[0].FHC,BancaID:event.socket.data.banca});
				if (g.length>1) {
					ticket[0].Premio = Number(ticket[0].Premio)/2;
				}
				event.socket.enviarDatos("leerTicket",ticket[0]);
				g=null;
			} else {
				event.socket.enviarDatos("leerTicket",null);
			}
			ticket=null;
		}
		
		protected function socket_ticketPagado(event:SocketDataEvent):void {
			Global.tablas.premios.marcarPagado(event.data);
		}
		
		protected function socket_eliminarTicket(event:SocketDataEvent):void {
			dispatchEvent(new SocketDataEvent("tablaTicketEliminado",event.socket,event.data));
		}
		
		protected function socket_reporteDiario(event:SocketDataEvent):void {
			var reporte:Array = Global.tablas.premios.leerFH(event.data.fecha,event.data.hipodromo,
				event.socket.data.banca,event.socket.data.taquilla,null,
				"Carrera, MontoJugado Jugado,Premios, MontoJugado-Premios Balance");
			var o:Object = {};
			o.reporte = reporte;
			o.carrera = {fecha:event.data.fecha,hipodromo:event.data.hipodromo};
			event.socket.enviarDatos(HipicoSocketListener.REPORTE_DIARIO,o);
			o=null;
		}
		protected function socket_reporteTickets (event:SocketDataEvent):void {
			var o:Object = event.data;
			o.FHC = Modulo.fhc(o.fecha,o.hipodromo,o.carrera);
			var premios:Array = Global.tablas.premios.premiados(o.FHC,event.socket.data.banca,event.socket.data.taquilla);
			var tpagado:int; var tnopago:int;
			var montoPagado:Number=0; var montoNoPagado:Number=0;
			if (premios) {
				var g:Array = Global.tablas.ganadores.leer({FHC:o.FHC,BancaID:event.socket.data.banca});
				var empate:Number = g.length==1?1:0.5;
				var i:int;
				for (i = 0; i < premios.length; i++) {
					o=premios[i];
					if (o.pago) { 
						tpagado++;
						montoPagado += Number(o.Premio)*empate;
					} else { 
						tnopago++; 
						montoNoPagado += Number(o.Premio)*empate;
					}
				}
			}
			o = event.data;
			o.pagados = tpagado;
			o.pendientes = tnopago;
			o.montoPago = montoPagado;
			o.montoPendiente = montoNoPagado;
			event.socket.enviarDatos("reporteTickets",o);
			o=null; premios=null;
		}
		protected function socket_ventaTickets(event:SocketDataEvent):void {
			Global.registros.add("Tablas -> Banca recibe venta de tabla: "+JSON.stringify(event.data));
			if (Global.tablas.tablas_padre.isCarreraAbierta(event.data.fhc,event.socket.data.banca)) {
				var ventaValida:Boolean=true;
				var topesTablas:Array = Global.tablas.tablas.leer({FHC:event.data.fhc,BancaID:event.socket.data.banca,Numero:event.data.ticket.Numero},"Numero, Nombre, Tablas");
				var ventas:Array = Global.tablas.ventas.leer({FHC:event.data.fhc,BancaID:event.socket.data.banca,Numero:event.data.ticket.Numero,Eliminado:false},"Numero, SUM(Cantidad) Cantidad");
				
				if (topesTablas && ventas)
					ventaValida = topesTablas[0].Tablas>=(ventas[0].Cantidad+event.data.ticket.Cantidad)?true:false;
				
				if (ventaValida) {
					Global.tablas.ventas.insertar([event.data.ticket]);
					dispatchEvent(new Evento(HipicoSocketListener.VENTA_TICKETS,event.data));
					event.socket.enviarDatos(HipicoSocketListener.VENTA_TICKETS,event.data.ticket);
					var o:Object = new Object;
					o.fhc = event.data.fhc;
					o.Cantidad = event.data.ticket.Cantidad;
					o.Taquilla = event.data.ticket.Taquilla;
					o.Numero = event.data.ticket.Numero;
					o.Banca = event.data.ticket.BancaID;
					_socket.enviarACampos("tablaVendida",o,{tipo:"Tabla",banca:event.socket.data.banca});
					Global.registros.add("Tablas -> Venta concedida "+JSON.stringify(event.data.ticket));
				} else {
					event.socket.enviarDatos(HipicoSocketListener.VENTA_TICKETS,"Ticket rechazado, exede limite de tablas disponibles");
					Global.registros.add("Tablas -> Venta rechazada en "+event.socket.data.taquilla+", exede limite de tablas disponibles");
				}
				topesTablas=null; ventas=null; o=null;
			} else {
				event.socket.enviarDatos(HipicoSocketListener.VENTA_CANCELADA,"Carrera cerrada, Venta Rechazada");
				Global.registros.add("Tablas -> Venta rechazada en "+event.socket.data.taquilla+", Carrera cerrada");
			}
		}
		protected function socket_desconectado(event:SocketEvent):void {
			_clientes--;
			dispatchEvent(new SocketEvent("clientesChange",event.socket));
			Global.registros.add("Tablas -> Cliente "+event.socket.data.taquilla+" desconectado");
		}
		
		protected function socket_leerCarrera(event:SocketDataEvent):void {
			Global.registros.add("Tablas -> Cliente "+event.socket.data.taquilla+" intenta cargar carrera "+JSON.stringify(event.data));
			var tablas_padre:Array = Global.tablas.tablas_padre.leer(event.data.Fecha,event.data.Hipodromo,event.data.Carrera,event.data.BancaID);
			if (tablas_padre && tablas_padre.length>0) {
				var tablas:Array = Global.tablas.tablas.leer({FHC:Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),BancaID:event.data.BancaID},"*",null,"Numero ASC");
				var tickets:Array = Global.tablas.ventas.leerVentasTaquilla(event.data.Fecha,event.data.Hipodromo,event.data.Carrera,event.data.BancaID,event.socket.data.taquilla);
				var premios:Array = Global.tablas.premios.premiados(Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),event.socket.data.banca,event.socket.data.taquilla);
				var ganadores:Array = Global.tablas.ganadores.leer({FHC:Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),BancaID:event.socket.data.banca});
				var data:Object = new Object;
				data.paga = tablas_padre[0].Paga;
				data.abierta = tablas_padre[0].Abierta;
				data.porcentaje = tablas_padre[0].Porcentaje;
				tickets_to_tablas(tablas,Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),event.socket.data.banca);
				data.tablas = tablas;
				data.tickets = tickets;
				data.premios = premios;
				data.ganadores = ganadores;
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,data);
				tablas_padre=null; tablas=null; tickets=null; data=null; premios = null; ganadores=null;
			} else {
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,null);
			}
		}
		private function tickets_to_tablas(tablas:Array,fhc:String,banca:int):void {
			var t:Array = Global.tablas.ventas.leer({FHC:fhc,BancaID:banca,Eliminado:false},"Numero, SUM(Cantidad) Cantidad","Numero","Numero ASC");
			var len:int = t?t.length:0;
			for (var i:int = 0; i < len; i++) {
				tablas[t[i].Numero-1].Tablas -= t[i].Cantidad;
			}
		}
		public function statusCarreras(carrera:Object, status:Boolean,bancaID:int=-1):void {
			var o:Object = new Object;
			o.carrera = carrera;
			o.abierta = status;
			
			if (bancaID>-1) {
				_socket.enviarACampos(STATUS_CARRERA,o,{banca:bancaID,tipo:"Tabla"});
			} else {
				_socket.enviarACampos(STATUS_CARRERA,o,{tipo:"Tabla"});
			}
		}
		public function premios_enviar(carrera:Object,ganadores:Array,premios:Array,balance:Object,BancaID:int,nombre_taquilla:String):void {
			var o:Object = new Object;
			o.banca = BancaID;
			o.carrera = carrera;
			o.ganadores = ganadores;
			o.premios = premios;
			o.balance = balance;
			_socket.enviarACampos(HipicoSocketListener.PREMIOS,o,{taquilla:nombre_taquilla,tipo:"Tabla",banca:BancaID});
			o=null;
		}
		public function reiniciarPremios (carrera:Object,BancaID:int):void {
			var o:Object = new Object;
			o.carrera = carrera;
			o.banca = BancaID;
			_socket.enviarACampos(HipicoSocketListener.PREMIOS_REINICIADO,o,{tipo:"Tabla",banca:BancaID});
			Global.registros.add("Tablas -> Reiniciando premios de tablas en "+Global.banca.bancas.bancaByID(BancaID).Nombre);
		}
		public function tablasNuevas(carrera:Object,bancaID:int):void {
			carrera.BancaID = bancaID;
			_socket.enviarACampos(HipicoSocketListener.TABLAS_NUEVAS,carrera,{tipo:"Tabla",banca:bancaID});
		}
		public function bloquearEjemplar(fhc:String,ejemplar:Object):void {
			_socket.enviarACampos(HipicoSocketListener.BLOQUEAR_EJEMPLAR,ejemplar,{tipo:"Tabla",banca:ejemplar.BancaID});
			Global.registros.add("Tablas -> Bloquenado ejemplar "+ejemplar.Nombre+"Global.banca.bancas.bancaByID(ejemplar.BancaID).Nombre");
		}
		public function publicarTablas(carrera:Object,tablas:Array,paga:int):void {
			Global.registros.add("Banca -> Publicando tablas...");
			var data:Object = new URLVariables;
			data.fecha = carrera.Fecha;
			data.hipodromo = carrera.Hipodromo;
			data.carrera = carrera.Carrera;
			data.paga1 = paga>200?260:130;
			data.tablas1 = JSON.stringify(tablas);
			var md:Number = paga>200?0.5:2;
			for (var i:int = 0; i < tablas.length; i++) {
				tablas[i].Monto = Math.floor(int(tablas[i].Monto)*md);
			}
			data.paga2 = data.paga1*md;
			data.tablas2 = JSON.stringify(tablas);
			data.banca = Global.banca.config.webID;
			var loader:URLLoader = new URLLoader;
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			var req:URLRequest = new URLRequest(Global.banca.config.servidorWeb+"/tablas/guardar.php");
			req.method = "post";
			req.data = data;
			
			loader.addEventListener(Event.COMPLETE,loader_onComplete);
			loader.load(req);
		}
		
		protected function loader_onComplete(event:Event):void {
			Global.registros.add("Banca -> Tablas publicadas");
		}
	}
}