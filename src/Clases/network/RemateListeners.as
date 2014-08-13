package Clases.network
{
	import Cliente.CSocket;
	
	import Events.SocketDataEvent;
	
	import sr.modulo.Modulo;
	
	import Server.SSocket;
	
	import Sockets.HipicoSocketListener;
	
	import events.Evento;
	
	import flash.data.SQLResult;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	
	[Event(name="statusCarrera", type="Clases.network.events.ConexionEvent")]
	[Event(name="clientesChange", type="Events.SocketEvent")]
	[Event(name="remateLeerCarrera", type="Events.SocketDataEvent")]
	public class RemateListeners extends EventDispatcher {	
		private var _socket:SSocket;
		public function RemateListeners(socket:SSocket) {
			_socket = socket;
		}
		public function statusCarreras(carrera:Object, status:Boolean,bancaID:int=-1):void {
			var o:Object = new Object;
			o.carrera = carrera;
			o.abierta = status;
			if (bancaID>-1) {
				_socket.enviarACampos(HipicoSocketListener.STATUS_CARRERA,o,{banca:bancaID,tipo:"Remate"});
			} else {
				_socket.enviarACampos(HipicoSocketListener.STATUS_CARRERA,o,{tipo:"Remate"});
			}
		}
		public function reiniciarPremios(carrera:Object,bancaID:int):void {
			var o:Object = new Object;
			o.carrera = carrera;
			if (bancaID>-1) {
				_socket.enviarACampos(HipicoSocketListener.PREMIOS_REINICIADO,o,{banca:bancaID,tipo:"Remate"});
			} else {
				_socket.enviarACampos(HipicoSocketListener.PREMIOS_REINICIADO,o,{tipo:"Remate"});
			}
		}
		public function premios_enviar(carrera:Object,ejemplaresGanadores:Array,bancaID:int):void {
			var o:Object = new Object;
			o.fhc = Modulo.fhc(carrera.Fecha,carrera.Hipodromo,carrera.Carrera);
			o.eg = ejemplaresGanadores;
			_socket.enviarACampos(HipicoSocketListener.PREMIOS,o,{tipo:"Remate",banca:bancaID,taquilla:"REMATE"});
		}
		public function setListeners(socket:CSocket):void {
			socket.addEventListener(HipicoSocketListener.LEER_CARRERA,remate_leerCarrera);
			socket.addEventListener(HipicoSocketListener.REPORTE_DIARIO,remate_reporteDiario);
			socket.addEventListener(HipicoSocketListener.PREMIOS,remate_premios);
			socket.addEventListener("remateLeerCarrera",remate_bancaLeerRemate);
			socket.addEventListener("cambioRemate",remate_cambioRemate);
			socket.addEventListener("cambioAdicional",remate_cambioAdicional);
			socket.addEventListener(HipicoSocketListener.RETIRAR_EJEMPLAR,remate_retirarEjemplar);
		}
		
		protected function remate_cambioAdicional(event:SocketDataEvent):void {
			dispatchEvent(new SocketDataEvent("cambioAdicional",event.socket,event.data));
		}
		
		protected function remate_retirarEjemplar(event:SocketDataEvent):void {
			dispatchEvent(new SocketDataEvent(HipicoSocketListener.RETIRAR_EJEMPLAR,event.socket,event.data));
		}
		
		protected function remate_cambioRemate(event:SocketDataEvent):void {
			dispatchEvent(new SocketDataEvent("cambioRemate",event.socket,event.data));
		}
		
		protected function remate_bancaLeerRemate(event:SocketDataEvent):void {
			dispatchEvent(new SocketDataEvent("remateLeerCarrera",event.socket,event.data));
		}
		
		protected function remate_premios(event:SocketDataEvent):void {
			Global.remate.premios.insertarPremio(event.data);
		}
		
		protected function remate_reporteDiario(event:SocketDataEvent):void {
			var reporte:Array = Global.ganador.premios.leerFH(event.data.fecha,event.data.hipodromo,
																	event.socket.data.banca,event.socket.data.taquilla,null,
																	"Carrera, MontoJugado Jugado,Premios, MontoJugado-Premios Balance");
			event.socket.enviarDatos(HipicoSocketListener.REPORTE_DIARIO,reporte);
		}
		protected function remate_leerCarrera(event:SocketDataEvent):void {
			var carrera:Array;
			carrera = Global.remate.carreras.leer2({FHC:Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),BancaID:event.socket.data.banca},"FHC,Numero,Nombre,Retirado,Bloqueado,BancaID");
			if (carrera) {
				var isAbierta:Boolean = carrera[0].Abierta;
				var premios:Array = Global.remate.premios.leer({Fecha:event.data.Fecha,Hipodromo:event.data.Hipodromo,Carrera:event.data.Carrera,BancaID:event.socket.data.banca,Taquilla:event.socket.data.taquilla});
				var data:Object = new Object;
				data.FHC = Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera);
				data.ejemplares = carrera;
				data.premios = premios;
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,data);
			} else {
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,null);
			}
			premios=null;data=null;
		}
		public function leerCarrera_remota(FHC:String,bancaID:int):void {
			_socket.enviarACampos("remateLeerCarrera",{fhc:FHC},{banca:bancaID,tipo:"Remate"});
		}
		public function bloquearEjemplar(ejemplar:Object,fhc:String,bancaId:int):void {
			var o:Object = new Object;
			o.ejemplar = {Numero:ejemplar.Numero,Bloqueado:ejemplar.Bloqueado};
			o.fhc = fhc;
			_socket.enviarACampos(HipicoSocketListener.BLOQUEAR_EJEMPLAR,o,{tipo:"Remate",banca:bancaId});
			o=null;
		}
	}
}