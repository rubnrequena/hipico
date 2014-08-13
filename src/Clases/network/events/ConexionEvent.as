package Clases.network.events
{
	import Cliente.CSocket;
	
	import Events.SocketDataEvent;
	
	import libVOs.infoCarrera;
	
	[Exclude(kind="property", name="data")]
	public class ConexionEvent extends SocketDataEvent
	{
		public var taquilla:String;
		public var banca:int;
		public var hipodromo:String;
		public var carrera:int;
		public var fecha:String;
		public var abierta:Boolean;
		public function ConexionEvent(type:String, socket:CSocket,taquilla:String,banca:int,hipodromo:String,carrera:int,fecha:String,abierta:Boolean)
		{
			this.taquilla = taquilla;
			this.banca = banca;
			this.hipodromo = hipodromo;
			this.carrera = carrera;
			this.fecha = fecha;
			this.abierta = abierta;
			super(type, socket, null, false,false);
		}
	}
}