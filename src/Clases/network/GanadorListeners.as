package Clases.network
{
	import Cliente.CSocket;
	
	import Events.SocketDataEvent;
	
	import Server.SSocket;
	
	import Sockets.HipicoSocketListener;
	
	import events.Evento;
	
	import flash.data.SQLResult;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import sr.modulo.Modulo;
	
	[Event(name="ventaTickets", type="events.Evento")]
	[Event(name="statusCarrera", type="Clases.network.events.ConexionEvent")]
	[Event(name="ganadorTicketEliminado", type="Events.SocketDataEvent")]
	[Event(name="clientesChange", type="Events.SocketEvent")]
	public class GanadorListeners extends EventDispatcher
	{
		private var _socket:SSocket;
		public function GanadorListeners(socket:SSocket) {
			_socket = socket;
		}
		private var clientes:Array = [];
		public function registrarCliente(appName:String):void {
			clientes.push(appName);
		}
		public function statusCarreras(carrera:Object, status:Boolean,bancaID:int=-1):void {
			var o:Object = new Object;
			o.carrera = carrera;
			o.abierta = status;
			if (bancaID>-1) {
				_socket.enviarACampos(HipicoSocketListener.STATUS_CARRERA,o,{banca:bancaID,tipo:"Ganador"});
			} else {
				_socket.enviarACampos(HipicoSocketListener.STATUS_CARRERA,o,{tipo:"Ganador"});
			}
		}
		public function bloquearEjemplar(fhc:String,ejemplar:Object):void {
			_socket.enviarACampos(HipicoSocketListener.BLOQUEAR_EJEMPLAR,ejemplar,{tipo:"Ganador",banca:ejemplar.BancaID});
			Global.registros.add("Ganador -> Bloquenado ejemplar "+ejemplar.Nombre+"Global.banca.bancas.bancaByID(ejemplar.BancaID).Nombre");
		}
		public function reiniciarPremios(carrera:Object,bancaID:int):void {
			var o:Object = new Object;
			o.carrera = carrera;
			if (bancaID>-1) {
				_socket.enviarACampos(HipicoSocketListener.PREMIOS_REINICIADO,o,{banca:bancaID,tipo:"Ganador"});
			} else {
				_socket.enviarACampos(HipicoSocketListener.PREMIOS_REINICIADO,o,{tipo:"Ganador"});
			}
			Global.registros.add("Ganador -> Reiniciando premios en "+Global.banca.bancas.bancaByID(bancaID).Nombre);
		}
		public function premios_enviar(carrera:Object,ejemplaresGanadores:Array,ticketsGanadores:Array,bancaID:int,Taquilla:String,jugado:Number,premios:Number):void {
			var o:Object = new Object;
			o.carrera = carrera;
			o.eg = ejemplaresGanadores;
			o.tg = ticketsGanadores;
			o.jugado = jugado;
			o.premios = premios;
			_socket.enviarACampos(HipicoSocketListener.PREMIOS,o,{tipo:"Ganador",banca:bancaID,taquilla:Taquilla});
		}
		public function setListeners(socket:CSocket):void {
			socket.addEventListener(HipicoSocketListener.LEER_CARRERA,ganador_leerCarrera);
			socket.addEventListener(HipicoSocketListener.VENTA_TICKETS,ganador_ventaTickets);
			socket.addEventListener(HipicoSocketListener.ELIMINAR_TICKET,ganador_eliminarTicket);
			socket.addEventListener(HipicoSocketListener.REPORTE_DIARIO,ganador_reporteDiario);
			socket.addEventListener("ticketPagado",ganador_ticketPagado);
			socket.addEventListener("leerTicket",ganador_leerTicket);
			socket.addEventListener("reporteTickets",ganador_reporteTickets);
			
			socket.addListener("retirarTicket",ganador_retirarTicket);
		}
		
		protected function ganador_retirarTicket(e:String,data:Object,socket:CSocket):void {			
			Global.ganador.sql('UPDATE Ventas SET Devuelto = true WHERE VentaID = '+data.ventaID+' AND Numero = '+data.ejemplar);
		}
		
		protected function ganador_leerTicket(event:SocketDataEvent):void {
			var ticket:Array;
			ticket = Global.ganador.premios.ticketsPremiados({VentaID:event.data,BancaID:event.socket.data.banca,Taquilla:event.socket.data.taquilla});
			var paga:Number; 
			if (ticket) {
				paga = Global.ganador.ganadores.leer({FHC:ticket[0].FHC,BancaID:ticket[0].BancaID,Numero:ticket[0].Numero},null,"Paga")[0].Paga;
				ticket[0].Paga = paga;
                ticket[0].Premio = (Number(ticket[0].Monto)/Global.banca.hipodromos.ganador(ticket[0].Hipodromo))*paga;
				event.socket.enviarDatos("leerTicket",ticket[0]);
			} else {
				event.socket.enviarDatos("leerTicket",null);
			}
		}
		protected function ganador_reporteTickets (event:SocketDataEvent):void {
			var o:Object = event.data;
			o.FHC = Modulo.fhc(o.fecha,o.hipodromo,o.carrera);
			var premios:Array = Global.ganador.premios.premiados(o.FHC,event.socket.data.banca,event.socket.data.taquilla);
			var tpagado:int; var tnopago:int;
			var montoPagado:Number=0; var montoNoPagado:Number=0;
			if (premios) {
				var i:int;
				for (i = 0; i < premios.length; i++) {
					o=premios[i];
					if (o.pago) { 
						tpagado++;
						montoPagado += o.Premio;
					} else { 
						tnopago++; 
						montoNoPagado += o.Premio;
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
		protected function ganador_ticketPagado(event:SocketDataEvent):void {
			Global.registros.add(event.type,event.data);
			Global.ganador.premios.marcarPagado(event.data);
		}
		
		protected function ganador_reporteDiario(event:SocketDataEvent):void {
			Global.registros.add(event.type,event.data);
			var reporte:Array = Global.ganador.premios.leerFH(event.data.fecha,event.data.hipodromo,
																	event.socket.data.banca,event.socket.data.taquilla,null,
																	"Carrera, MontoJugado Jugado,Premios, MontoJugado-Premios Balance");
			var o:Object = {};
			o.reporte = reporte;
			o.carrera = {fecha:event.data.fecha,hipodromo:event.data.hipodromo};
			event.socket.enviarDatos(HipicoSocketListener.REPORTE_DIARIO,o);
			o=null;
		}
		
		protected function ganador_eliminarTicket(event:SocketDataEvent):void {
			Global.registros.add(event.type,event.data);
			dispatchEvent(new SocketDataEvent("ganadorTicketEliminado",event.socket,event.data));
		}
		private var n:int=1;	
		protected function ganador_ventaTickets(event:SocketDataEvent):void {			
			var t:int = getTimer();
			Global.registros.add("Ganador -> Banca recibe venta de ganador: "+JSON.stringify(event.data));
			var ventas:Array = event.data.tickets;
			var causas:Array = [];
			var carrera:Object = event.data.carrera;
			carrera.BancaID = event.socket.data.banca;
			
			if (Global.ganador.carreras_padre.isCarreraAbierta(carrera,event.socket.data.banca)) {
				var ventaValida:Boolean=true;
				var topes:SQLResult = Global.ganador.sql('SELECT * FROM Topes WHERE banca = '+event.socket.data.banca+' AND Hipodromo = "'+carrera.Hipodromo+'" AND activo = true');
				if (topes.data && topes.data[0].activo==true) {
					var i:int; var _ventas:Array; var totalVenta:Number;
					for (i = 0; i < ventas.length; i++) {
						totalVenta = ventas[i].Monto;
						_ventas = Global.ganador.ventas.leer({FHC:event.data.carrera.FHC,BancaID:event.socket.data.banca,Numero:ventas[i].Numero,Eliminado:false},"SUM (Monto) Monto","BancaID");
						if (_ventas) totalVenta = _ventas[0].Monto+ventas[i].Monto;
						if (topes.data[0].tope<totalVenta) {
							ventaValida = false;
							causas.push("Ejemplar "+ventas[i].Nombre+" exede el limite de tope");
						}
					}
				}
				if (ventaValida) {
					Global.ganador.ventas.insertar(ventas);
					event.socket.enviarDatos(HipicoSocketListener.VENTA_TICKETS,[ventas,true]);
					var data:Object = event.data;
					data.banca = event.socket.data.banca;
					data.taquilla = event.socket.data.taquilla;
					dispatchEvent(new Evento(HipicoSocketListener.VENTA_TICKETS,data));
					Global.registros.add("Ganador -> Venta concedida "+JSON.stringify(ventas));
				} else {
					causas.push("<br>Tope maximo permitido: <b>"+topes.data[0].tope+'</b>');
					event.socket.enviarDatos(HipicoSocketListener.VENTA_TICKETS,[causas,false]);
					Global.registros.add("Ganador -> Venta rechazada, exede limite de tope");
				}
				ventas=null;carrera=null;causas=null;topes=null;_ventas=null;
			} else {
				causas.push("La carrera actual se encuentra cerrada.. <b>Venta Rechazada</b>");
				event.socket.enviarDatos(HipicoSocketListener.VENTA_TICKETS,[causas,false]);
				Global.registros.add("Ganador -> Venta rechazada, carrera cerrada");
			}
		}
		protected function ganador_leerCarrera(event:SocketDataEvent):void {
			Global.registros.add("Ganador -> Cliente "+event.socket.data.taquilla+" intenta cargar carrera "+JSON.stringify(event.data));
			var carrera:Array = Global.ganador.carreras_padre.leer(event.data.Fecha,event.data.Hipodromo,event.data.Carrera,event.socket.data.banca);
			if (carrera) {
				var isAbierta:Boolean = carrera[0].Abierta;
				carrera = Global.ganador.carreras.leer({FHC:Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),BancaID:event.socket.data.banca},"*",null,"Numero ASC");
				var tickets:Array = Global.ganador.ventas.leerVentasTaquilla(event.data.Fecha,event.data.Hipodromo,event.data.Carrera,event.socket.data.banca,event.socket.data.taquilla);
				var premios:Array = Global.ganador.premios.premiados(Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),event.socket.data.banca,event.socket.data.taquilla); 
				var ganadores:Array = Global.ganador.ganadores.leer({FHC:Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),BancaID:event.socket.data.banca});
				var data:Object = new Object;
				data.abierta = isAbierta;
				data.ejemplares = carrera;
				for (var i:int = 0; i < data.ejemplares.length; i++) {
					data.ejemplares[i].Monto = 0;
				}
				data.tickets = tickets;
				data.premios = premios;
				data.ganadores = ganadores;
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,data);
				Global.registros.add("Ganador -> Banca envia carreras a "+JSON.stringify(event.socket.data));
			} else {
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,null);
			}
			tickets=null; premios=null;data=null;
		}
	}
}