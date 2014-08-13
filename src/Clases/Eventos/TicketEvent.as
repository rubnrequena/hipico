package Clases.Eventos
{
	import flash.events.Event;
	
	public class TicketEvent extends Event
	{
		public static const TICKET_MACUARE_RECIBIDO:String = "ticketMacuareRecibido";
		
		public var valido:Boolean;
		public var ticket:Object;
		public var eliminado:Boolean;
		public function TicketEvent(type:String, ticket:Object, valido:Boolean, eliminado:Boolean=false, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.valido = valido;
			this.ticket = ticket;
			this.eliminado = eliminado;
		}
	}
}