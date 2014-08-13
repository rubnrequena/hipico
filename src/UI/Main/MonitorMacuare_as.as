import Clases.Eventos.TicketEvent;
import Clases.Macuare;

import Sockets.HipicoSocketListener;

import appkit.responders.NResponder;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.FlexEvent;

import spark.components.Button;

private var monitoreando:Boolean=false;
private var m1:Boolean=false;
private var m2:Boolean=false;

protected function colapsablegroup1_creationCompleteHandler(event:FlexEvent):void {
	fecha.addEventListener(CalendarLayoutChangeEvent.CHANGE,fecha_Change,false,0,true);
	fecha.selectedDate = new Date;
	bancas.dataProvider = new ArrayList(Global.banca.bancas.bancas);
	hipodromo.dataProvider = new ArrayList(Global.macuare.macuares.leer({Fecha:fecha.fechaSelecionada}));
	
	macuare.enabled = macuarito.enabled=false;
}

protected function fecha_Change(event:CalendarLayoutChangeEvent):void {
	hipodromo.dataProvider = new ArrayList(Global.macuare.macuares.leer({Fecha:fecha.fechaSelecionada}));
}

protected function btnMonitor_clickHandler(event:MouseEvent):void {
	if (hipodromo.selectedIndex==-1) return;
	
	monitoreando = !monitoreando;
	hipodromo.enabled = !monitoreando;
	bancas.enabled = !monitoreando;
	fecha.enabled = !monitoreando;
	if (monitoreando) {
		actualizarVentas();
		btnMonitor.label = "Detener";
		
		var mid:int = hipodromo.selectedItem.macuareId;
		var m:Array = Global.macuare.carreras.leer({macuareId:mid});
		m1 = macuareStatus(macuare,m);
		m2 = macuareStatus(macuarito,m);
		NResponder.add("global_macuareVentaTicket",ventaRecibida);
		NResponder.add("global_macuareEliminarTicket_handler",ventaTicketEliminado);
	} else {
		btnMonitor.label = "Iniciar";
		dg.dataProvider = null;
		lblTotal.text= "0.00";
		
		macuare.enabled=false;
		macuarito.enabled=false;
		
		NResponder.remove("global_macuareVentaTicket",ventaRecibida);
		NResponder.remove("global_macuareEliminarTicket_handler",ventaTicketEliminado);
	}
}

private function ventaTicketEliminado(permiso:Boolean,ventaId:int):void {
	if (permiso) {
		for (var i:int = 0; i < dg.dataProviderLength; i++) {
			if (dg.dataProvider.getItemAt(i).VentaId==ventaId) dg.dataProvider.removeItemAt(i);	
		}
		calcularTotal();
	}
}

private function ventaRecibida(venta:Object):void {
	if (venta.ticket.bancaID==bancas.selectedItem.ID) {
		if (venta.carrera.fecha==fecha.fechaSelecionada && venta.carrera.hipodromo==hipodromo.selectedItem.hipodromo) {
			dg.dataProvider.addItem(venta.ticket);
			calcularTotal();
		}
	}
}
protected function macuareStatus(btn:Button,m:Array):Boolean {
	var b:Boolean=false;
	for (var i:int = 0; i < m.length; i++) {
		if (m[i].descripcion==btn.label) {
			b = Boolean(m[i].abierta);
			btnMacuareStatus(btn,b);
			btn.name = m[i].mDatoId;
			btn.enabled=true;
			return b;
		}
	}
	return false;
}
private function actualizarVentas():void {
	var ventas:Array = Global.macuare.ventas.leer({Fecha:fecha.fechaSelecionada,Hipodromo:hipodromo.selectedItem.hipodromo,bancaID:bancas.selectedItem.ID});
	dg.dataProvider = new ArrayList(ventas);
	calcularTotal();
}
private function calcularTotal():void {
	var total:Number=0;
	for (var i:int = 0; i < dg.dataProviderLength; i++) {
		total += Number(dg.dataProvider.getItemAt(i).monto);
	}
	lblTotal.text = total.toFixed(2);
}
protected function labelBanca(item:Object):String {
	var b:String = item.Nombre;
	b = b.toUpperCase();
	if (b.indexOf("CENTRO HIPICO")>-1) {
		return b.substr(13);
	} else if (b.indexOf("PEÑA")>-1) {
		return b.substr(5);
	}
	return b;
}

protected function cerrarMacuare(event:MouseEvent):void {
	var btn:Button = event.target as Button;
	if (btn.label=="Macuare") {
		m1 = !m1;
		btnMacuareStatus(btn,m1);
		Global.macuare.carreras.status(int(btn.name),m1);
		Global.net.macuare.carrera_status(fecha.fechaSelecionada,hipodromo.selectedItem.hipodromo,int(btn.name),m1);
	} else {
		m2 = !m2;
		btnMacuareStatus(btn,m2);
		Global.macuare.carreras.status(int(btn.name),m2);
		Global.net.macuare.carrera_status(fecha.fechaSelecionada,hipodromo.selectedItem.hipodromo,int(btn.name),m2);
	}
}

protected function btnMacuareStatus(btn:Button,abierta:Boolean):void {
	if (abierta) {
		btn.setStyle("icon","images/unlock32.png");
	} else {
		btn.setStyle("icon","images/lock32.png");
	}
}