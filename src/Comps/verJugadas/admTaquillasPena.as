import Clases.Banca.VOBanca;

import Cliente.CSocket;

import Common.Misc;

import Comps.confirmarEliminarTicket;
import Comps.verJugadas.UI.monitorVentas.ganador.MonitorVentaGanador;
import Comps.verJugadas.UI.monitorVentas.ganador.MonitorVentaGanadorTaquillas;

import Events.SocketDataEvent;

import Sockets.HipicoSocketListener;

import events.Evento;

import flash.events.MouseEvent;
import flash.utils.getTimer;

import mx.collections.ArrayList;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;

private var _ganadorAgrupado:Array;
private function updateGanador_handler():void
{
    var t:uint = getTimer();
	vGanador.removeAllElements();
	var bc:MonitorVentaGanador;

    var ventas:Array =  Global.ganador.ventas.leer({FHC:carreraActual.FHC,Eliminado:false,Retirado:false},"BancaID,Numero,Nombre,SUM(Monto) Monto","Numero,BancaID","BancaID,Numero");

	var i:int;
	for (i = 0; i < Global.banca.bancas.numBancas; i++) {
		bc = new MonitorVentaGanador;
		bc.addEventListener(MouseEvent.CLICK,bcGanador_onClick);
		bc.tipo = "Ganador";
        bc.banca = Global.banca.bancas.bancaByIndex(i);
        vGanador.addElement(bc);
        bc.tickets = getTickets(i+1,ventas);
    }
    updateTotal_Ganador();
    ganadorAgrupado_iniciar();
	trace("Creacion de ganadores:",getTimer()-t)
}
protected function bcGanador_onClick(event:MouseEvent):void {
	shorcuts=false;
	var mvgt:MonitorVentaGanadorTaquillas = new MonitorVentaGanadorTaquillas;
	mvgt.addEventListener(CloseEvent.CLOSE, monitorVentas_closeHandler);
	mvgt.banca = event.currentTarget.banca.ID;
	mvgt.fhc = carreraActual.FHC;
	this.addElement(mvgt);
}

private function ganadorAgrupado_iniciar():void {
	_ganadorAgrupado = Global.ganador.ventas.leerVentasCarrera(carreraActual.fecha(),carreraActual.Hipodromo,carreraActual.Carrera,"Nombre","Numero ASC",{Retirado:false,Eliminado:false},"Numero, Nombre, SUM(Monto) Monto");
	listGanadorAgrupado.dataProvider = new ArrayList(_ganadorAgrupado);
}
private function ganador_pushAgrupado(ticket:Object):void {
	if (_ganadorAgrupado) {
		for (var i:int = 0; i < _ganadorAgrupado.length; i++) {
			if (ticket.Numero == _ganadorAgrupado[i].Numero) {
				_ganadorAgrupado[i].Monto += ticket.Monto;
				listGanadorAgrupado.dataProvider = new ArrayList(_ganadorAgrupado);
				return;
			}
		}
	} else {
		_ganadorAgrupado = new Array;
	}
	_ganadorAgrupado.push(ticket);
	_ganadorAgrupado.sortOn("Numero",Array.NUMERIC);
	listGanadorAgrupado.dataProvider = new ArrayList(_ganadorAgrupado);
}
private function updateTotal_Ganador():void {
	var total:Number = 0; var i:int;
	for (i = 0; i < vGanador.numElements; i++) {
		total += (vGanador.getElementAt(i) as MonitorVentaGanador).total;
	}
	labelTotalGanador.text = total.toString();
}
/*private function getBanca(id:int):MonitorVentaGanador {
	var bc:MonitorVentaGanador;
	for (var  i:int = 0;  i < vGanador.numElements;  i++) {
		bc = vGanador.getElementAt(i) as MonitorVentaGanador;
		if (id == bc.banca.ID) break;
	}
	return bc;
}*/
protected function socket_eliminarTicketGanador_handler(event:SocketDataEvent):void {
	shorcuts=false;
	var confTicket:confirmarEliminarTicket = new confirmarEliminarTicket;
	
	confTicket.data = event.data;
	confTicket.socket = event.socket;
	
	confTicket.click.addOnce(socket_eliminarTicket_handler);
	PopUpManager.addPopUp(confTicket,this,false);
	PopUpManager.centerPopUp(confTicket);
}

private function socket_eliminarTicket_handler(permiso:Boolean,data:Object,socket:CSocket):void {
	if (permiso) {
		noticiaVentas = "Se concedió eliminación del ticket "+Misc.fillZeros(data.ventaID,9)+" a "+Global.banca.bancas.bancaByID(socket.data.banca).Nombre;
		var m:int;
		for (i = 0; i < data.tickets.length; i++) { m += data.tickets[i].Monto; }
		noticiaVentas = Global.banca.bancas.bancaByID(socket.data.banca).Nombre+" -"+m+" en ticket "+Misc.fillZeros(data.ventaID,9);
		Global.ganador.ventas.eliminarTickets(data.tickets,true);
		var i:int; var banca:MonitorVentaGanador;
		banca = vGanador.getElementAt(socket.data.banca-1) as MonitorVentaGanador;
		banca.removeTickets(data.tickets);
		updateTotal_Ganador();
		ganadorAgrupado_iniciar();
	} else {
		noticiaVentas = "Se rechazó eliminación del ticket "+Misc.fillZeros(data.ventaID,9)+" a "+Global.banca.bancas.bancaByID(socket.data.banca).Nombre;
	}
	var _data:Object = new Object;
	_data.ventaID = data.ventaID;
	_data.permiso = permiso;
	_data.tickets = data.tickets;
	socket.enviarDatos(HipicoSocketListener.ELIMINAR_TICKET,_data);
	shorcuts=true; _data=null;
	this.setFocus();
}
protected function socket_ganadorJugadaRecibida(event:Evento):void {
	if (carreraActual && carreraActual.FHC == event.data.carrera.FHC) {
		var i:int; var banca:MonitorVentaGanador;
		banca = vGanador.getElementAt(event.data.banca-1) as MonitorVentaGanador;
		banca.pushTickets(event.data.tickets);
		for (i = 0; i < event.data.tickets.length; i++) {
			noticiaVentas = Global.banca.bancas.bancaByID(event.data.tickets[i].BancaID).Nombre+" +"+event.data.tickets[i].Monto+" a "+event.data.tickets[i].Nombre;
			ganador_pushAgrupado(ObjectUtil.copy(event.data.tickets[i]));
		}
	}
	updateTotal_Ganador();
}
