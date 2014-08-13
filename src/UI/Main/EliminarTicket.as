package UI.Main
{
	import Cliente.CSocket;
	
	import appkit.responders.NResponder;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;

	public class EliminarTicket extends EliminarTicketUI
	{
		static public const ON_CLOSE:String = "eliminarTicket_close";
		private var _ticket:Object;
		private var _socket:CSocket;
		private var _tipo:String;
		
		private var t:Timer;
		public function EliminarTicket(ticket:Object,socket:CSocket,tipo:String) {
			super();
			_ticket = ticket;
			_socket = socket;
			_tipo = tipo;
			NResponder.addNative(this,FlexEvent.CREATION_COMPLETE,onComplete,1);
		}
		
		private function onComplete(e:FlexEvent):void {
			NResponder.addNative(this,MouseEvent.CLICK,onClick);
			if (_tipo=="Macuare") {
				fecha.text = _ticket.fecha;
				hipodromo.text = _ticket.hipodromo;
				carrera.text = "NA";
				
				banca.text = Global.banca.bancas.bancaByID(_ticket.bancaID).Nombre;
				taquilla.text = _ticket.taquilla;
				monto.text = _ticket.monto;
				ticket.text = _ticket.VentaId;
			}
			
			t = new Timer(1000,300);
			NResponder.addNative(t,TimerEvent.TIMER,onTick);
			NResponder.addNative(t,TimerEvent.TIMER_COMPLETE,onTock);
			t.start();
		}
		
		private function onTock(e:TimerEvent):void {
			NResponder.dispatch(ON_CLOSE,[false,ticket.text,_socket],this);
			NResponder.remove(MouseEvent.CLICK,onClick,this);
			PopUpManager.removePopUp(this);
		}
		
		private function onTick(e:TimerEvent):void {
			title = "Eliminar Ticket - "+(t.repeatCount-t.currentCount);
		}
		private function close():void {
			t.stop();
			NResponder.remove(TimerEvent.TIMER,onTick,t);
			NResponder.remove(TimerEvent.TIMER_COMPLETE,onTock,t);
			t=null;
			PopUpManager.removePopUp(this);
		}
		private function onClick(e:MouseEvent):void {
			if (e.target.name=="btnOK") {
				NResponder.dispatch(ON_CLOSE,[true,ticket.text,_socket],this);
				NResponder.remove(MouseEvent.CLICK,onClick,this);
				close();
			}
			if (e.target.name=="btnCancel") {
				NResponder.dispatch(ON_CLOSE,[false,ticket.text,_socket],this);
				NResponder.remove(MouseEvent.CLICK,onClick,this);
				close();
			}
		}
	}
}