package Clases.network
{
	import Cliente.CSocket;
	
	import Events.SocketDataEvent;
	
	import Server.SSocket;
	
	import Sockets.HipicoSocketListener;
	
	import appkit.responders.NResponder;

	[Event(name="ventaTickets", type="events.Evento")]
	[Event(name="statusCarrera", type="Clases.network.events.ConexionEvent")]
	[Event(name="ganadorTicketEliminado", type="Events.SocketDataEvent")]
	[Event(name="clientesChange", type="Events.SocketEvent")]
	public class MacuareListeners {
		private var _socket:SSocket;
		public function MacuareListeners(socket:SSocket) {
			_socket = socket;
		}
		public function setListeners(socket:CSocket):void {
			socket.addEventListener(HipicoSocketListener.LEER_CARRERA,socket_leerCarrera);
			socket.addEventListener(HipicoSocketListener.VENTA_TICKETS,socket_ventaTickets);
			socket.addEventListener(HipicoSocketListener.ELIMINAR_TICKET,socket_eliminarTicket);
			socket.addEventListener(HipicoSocketListener.REPORTE_DIARIO,socket_reporteDiario);
			socket.addEventListener("ticketPagado",socket_ticketPagado);
		}
		
		protected function socket_ticketPagado(event:SocketDataEvent):void {
			
		}
		protected function socket_reporteDiario(event:SocketDataEvent):void {
			
		}
		protected function socket_eliminarTicket(event:SocketDataEvent):void {
			var ticket:Object = Global.macuare.ventas.leer({VentaId:event.data})[0];
			NResponder.dispatch("global_"+HipicoSocketListener.ELIMINAR_TICKET,[ticket,event.socket,"Macuare"]);
		}
		protected function socket_ventaTickets(event:SocketDataEvent):void {
			var o:Object = event.data.carrera;
			o.ejemplares = event.data.ticket.ejemplares;
			var tope:Number = Global.banca.bancas.bancaByID(event.socket.data.banca).macuare_tope;
			var combinacion:Array = Global.macuare.ventas.leer(o,"SUM(monto) monto","ejemplares");
			var valido:int;
			if (!combinacion) { combinacion = [{monto:0}]; }
			valido = combinacion[0].monto+event.data.ticket.monto;
			if (valido<=tope) {
				Global.macuare.ventas.insertar(event.data);
				event.socket.enviarDatos(HipicoSocketListener.VENTA_TICKETS,event.data);
				NResponder.dispatch("global_macuareVentaTicket",[event.data]);
			} else {
				event.socket.enviarDatos(HipicoSocketListener.VENTA_CANCELADA,"Venta rechazada, exede tope limite por jugada de "+tope+", jugada valida restante: "+(tope-combinacion[0].monto));
			}
			
		}
		protected function socket_leerCarrera(event:SocketDataEvent):void {
			var c:Object = {};
			c.Fecha = event.data.fecha;
			c.Hipodromo = event.data.hipodromo;
			
			var carrera:Array = Global.banca.carreras.leer(c,"Numero,Nombre,Carrera",null,"Carrera,Numero");
			if (carrera) {
				c.bancaID = event.socket.data.banca;
				c.taquilla = event.socket.data.taquilla;
				var macuares:Array = Global.macuare.macuares.leerMacuare(c.Fecha,c.Hipodromo);
				var tickets:Array = Global.macuare.ventas.leer(c);
				var premios:Array = Global.macuare.sql('SELECT Premios.mDatoId,jugado,premio,bancaId,fecha,hipodromo,taquilla,descripcion FROM Premios JOIN Carreras ON Carreras.mDatoId = Premios.mDatoId WHERE fecha = "'+c.Fecha+'" AND hipodromo = "'+c.Hipodromo+'" AND taquilla = "'+c.taquilla+'" AND bancaID = '+c.bancaID).data;
				var premiados:Array = Global.macuare.premios.premiados(c);
				
				var data:Object = {};
				data.ejemplares = carrera;
				data.macuares = macuares;
				data.tickets = tickets;
				data.premios = premios;
				data.premiados = premiados;
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,data);
			} else {
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,null);
			}
			c=null;carrera=null;macuares=null;tickets=null;premios=null;premiados=null;data=null;
		}
		public function premios_enviar(carrera:Object,premio:Object,ticketsGanadores:Array,bancaID:int,Taquilla:String):void {
			var o:Object = new Object;
			o.carrera = carrera;
			o.premios = premio;
			o.premiados = ticketsGanadores;
			_socket.enviarACampos(HipicoSocketListener.PREMIOS,o,{tipo:"Macuare",banca:bancaID,taquilla:Taquilla});
		}
		public function carrera_status (fecha:String,hipodromo:String,macuare:int,status:Boolean):void {
			var o:Object = {};
			o.fecha = fecha;
			o.hipodromo = hipodromo;
			o.status = status;
			o.macuare = macuare;
			_socket.enviarACampos(HipicoSocketListener.STATUS_CARRERA,o,{tipo:"Macuare"});
			o=null;
		}
	}
}