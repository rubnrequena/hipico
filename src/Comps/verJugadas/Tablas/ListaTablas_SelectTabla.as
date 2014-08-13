package Comps.verJugadas.Tablas
{
	import flash.events.Event;
	
	public class ListaTablas_SelectTabla extends Event
	{
		public static const SELECT_TABLA:String = "SELECT_TABLA";
		public var tablas:Array;
		public var banca:String;
		public function ListaTablas_SelectTabla(type:String,tablas:Array,banca:String)
		{
			super(type, bubbles, cancelable);
			this.tablas = tablas;
			this.banca = banca;
		}
	}
}