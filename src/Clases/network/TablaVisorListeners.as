package Clases.network
{
	import Cliente.CSocket;
	
	import Events.SocketDataEvent;
	
	import Server.SSocket;
	
	import Sockets.HipicoSocketListener;
	
	import sr.modulo.Modulo;

	public class TablaVisorListeners
	{
		private var _socket:SSocket;
		public function TablaVisorListeners(ssocket:SSocket) { _socket = ssocket; }
		
		public function setListeners (socket:CSocket):void {
			socket.addEventListener(HipicoSocketListener.LEER_CARRERA,leer_carrera);
		}
		public function tablasNuevas(carrera:Object,bancaID:int):void {
			_socket.enviarACampos(HipicoSocketListener.TABLAS_NUEVAS,carrera,{tipo:"TablaVisor",banca:bancaID});
		}
		protected function leer_carrera(event:SocketDataEvent):void {
			var tablas_padre:Array = Global.tablas.tablas_padre.leer(event.data.Fecha,event.data.Hipodromo,event.data.Carrera,event.socket.data.banca);
			if (tablas_padre && tablas_padre.length>0) {
				var tablas:Array = Global.tablas.tablas.leer({FHC:Modulo.fhc(event.data.Fecha,event.data.Hipodromo,event.data.Carrera),BancaID:event.socket.data.banca},"*",null,"Numero ASC");
				
				var data:Object = new Object;
				data.paga = tablas_padre[0].Paga;
				data.abierta = tablas_padre[0].Abierta;
				data.porcentaje = tablas_padre[0].Porcentaje;
				data.tablas = tablas;
				data.carrera = event.data;
				
				event.socket.enviarDatos(HipicoSocketListener.LEER_CARRERA,data);
				tablas=null; tablas_padre=null; data=null;
			} else {
				event.socket.enviarDatos(HipicoSocketListener.SIN_CARRERA,event.data);
			}
		}
	}
}