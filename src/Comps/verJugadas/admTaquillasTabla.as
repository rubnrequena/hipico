import Clases.network.HipicoActividad;
import Clases.network.netManager;

import Cliente.CSocket;

import Common.Misc;

import Comps.confirmarEliminarTicket;
import Comps.verJugadas.Tablas.ListaTablas;
import Comps.verJugadas.Tablas.ListaTablas_SelectTabla;
import Comps.verJugadas.Tablas.Tablas_v2;
import Comps.verJugadas.UI.monitorVentas.tabla.MonitorVentaTabla;
import Comps.verJugadas.UI.monitorVentas.tabla.MonitorVentaTablasTaquillas;
import Comps.verJugadas.tablasBanca;

import Events.SocketDataEvent;

import Sockets.HipicoSocketListener;

import UI.shared.ModalOK;

import events.Evento;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import vistas.Modal;

private function updateTablas_handler():void {
    var t:uint = getTimer();
	vTablas.removeAllElements();
	var bc:MonitorVentaTabla;

    var ventas:Array = Global.tablas.ventas.leer({FHC:carreraActual.FHC,Eliminado:false,Retirado:false},"*,SUM(Cantidad) Cantidad","Numero,BancaID","BancaID,Numero");

	var i:int;
	for (i = 0; i < Global.banca.bancas.numBancas; i++) {
		bc = new MonitorVentaTabla;
		bc.tipo = "Tabla";
		bc.banca = Global.banca.bancas.bancaByIndex(i);
		bc.addEventListener(MouseEvent.CLICK,bcTablas_onClick);
		vTablas.addElement(bc);
		bc.lblBanca.text = (Global.banca.bancas.bancaByIndex(i).Nombre).split("CENTRO HIPICO").join("C.H.");
		//bc.tickets = Global.tablas.ventas.leerVentasBanca(carreraActual.fecha(),carreraActual.Hipodromo,carreraActual.Carrera,(i+1),"Numero",{Eliminado:false},"*, SUM(Cantidad) Cantidad");
        bc.tickets = getTickets(i+1,ventas);
	}
	updateTotal_Tablas();
	tablasAgrupadas_iniciar();
    trace("Creacion de tablas:",getTimer()-t)
}

protected function bcTablas_onClick(event:MouseEvent):void {
	shorcuts = false;
	var mvgt:MonitorVentaTablasTaquillas = new MonitorVentaTablasTaquillas;
	mvgt.addEventListener(CloseEvent.CLOSE,monitorVentas_closeHandler);
	mvgt.banca = event.currentTarget.banca.ID;
	mvgt.fhc = carreraActual.FHC;
	this.addElement(mvgt);
}

private function tablasAgrupadas_iniciar():void {
	_tablasAgrupado = Global.tablas.ventas.leerVentasCarreraAgrupada(carreraActual.FHC);
	listTablaAgrupado.dataProvider = new ArrayList(_tablasAgrupado);
}
private var _tablasAgrupado:Array;
private function tablas_pushAgrupado(ticket:Object):void {
	if (_tablasAgrupado) {
		for (var i:int = 0; i < _tablasAgrupado.length; i++) {
			if (ticket.Numero == _tablasAgrupado[i].Numero) {
				_tablasAgrupado[i].Monto += ticket.Monto*ticket.Cantidad;
				_tablasAgrupado[i].Cantidad += ticket.Cantidad;
				listTablaAgrupado.dataProvider = new ArrayList(_tablasAgrupado);
				return;
			}
		}
	} else {
		_tablasAgrupado = new Array;	
	}
	_tablasAgrupado.push(Misc.clonarObjeto(ticket));
	_tablasAgrupado[_tablasAgrupado.length-1].Monto = _tablasAgrupado[_tablasAgrupado.length-1].Monto*_tablasAgrupado[_tablasAgrupado.length-1].Cantidad;
	_tablasAgrupado.sortOn("Numero",Array.NUMERIC);
	listTablaAgrupado.dataProvider = new ArrayList(_tablasAgrupado);
}
private function updateTotal_Tablas():void {
	var total:int=0;
	for (var i:int = 0; i < vTablas.numElements; i++) {
		total += (vTablas.getElementAt(i) as MonitorVentaTabla).total;
	}
	labelTotalTablas.text = total.toString();
}
private function socket_tablaTicketRecibido(event:Evento):void {
	if (event.data.fhc==carreraActual.FHC) {
		noticiaVentas = Global.banca.bancas.bancaByID(event.data.ticket.BancaID).Nombre+" +"+event.data.ticket.Cantidad+" tablas de "+event.data.ticket.Nombre;
		(vTablas.getElementAt(event.data.ticket.BancaID-1) as MonitorVentaTabla).pushTickets([event.data.ticket]);
		tablas_pushAgrupado(event.data.ticket);
	}
	updateTotal_Tablas();
}
private function getBancaUpdateIndex (banca:int):int {
	var b:tablasBanca;
	for (var i:int = 0; i < vTablas.numElements; i++) {
		b = vTablas.getElementAt(i) as tablasBanca;
		if (b.banca==banca) return i;
	}
	return -1;
}
private function socket_eliminarTicketTabla(event:SocketDataEvent):void {
	var confTicket:confirmarEliminarTicket = new confirmarEliminarTicket;
	/*confTicket.taquilla = event.data.tickets[0].Taquilla;
	confTicket.ticket = event.data.tickets[0].Hora;
	confTicket.monto = (event.data.tickets[0].Monto*event.data.tickets[0].Cantidad);
	confTicket.fecha = event.data.tickets[0].Fecha;
	confTicket.hipodromo = event.data.tickets[0].Hipodromo;
	confTicket.carrera = event.data.tickets[0].Carrera;*/
	confTicket.data = event.data;
	confTicket.socket = event.socket;
	
	confTicket.click.addOnce(socket_eliminarTabla_handler);
	PopUpManager.addPopUp(confTicket,this,true);
	PopUpManager.centerPopUp(confTicket);
}
protected function socket_eliminarTabla_handler (permiso:Boolean,data:Object,socket:CSocket):void {
	if (permiso) {
		Global.tablas.ventas.eliminarTickets(data.tickets,true);
		noticiaVentas = "Se concedió eliminación del ticket "+Misc.fillZeros(data.tickets[0].VentaID,9)+" a "+Global.banca.bancas.bancaByID(data.tickets[0].BancaID).Nombre;
		noticiaVentas = Global.banca.bancas.bancaByID(data.tickets[0].BancaID).Nombre+" -"+data.tickets[0].Cantidad+" tablas de "+data.tickets[0].Nombre+" en ticket "+Misc.fillZeros(data.tickets[0].VentaID,9);
		
		(vTablas.getElementAt(data.tickets[0].BancaID-1) as MonitorVentaTabla).removerTickets(data.tickets);
		updateTotal_Tablas();
		tablasAgrupadas_iniciar();
	} else {
		noticiaVentas = "Se rechazó eliminación del ticket "+data.tickets[0].Hora+" a "+Global.banca.bancas.bancaByID(data.tickets[0].BancaID).Nombre;
	}
	var o:Object = {};
	o.permiso = permiso;
	o.ticket = data.tickets[0];
	socket.enviarDatos(HipicoSocketListener.ELIMINAR_TICKET,o);
}
private var web_timer:Timer;
private var webload:Boolean=false;
private function tablasMenu_btnTablas_webLoad (event:MouseEvent):void {
	if (webload) {
		webload=false;
		web_timer.reset();
		noticiaSistema = "Busqueda de tablas cancelada";
	} else {
		webload=true;
		noticiaSistema = "Buscando tablas en: "+web_timer.repeatCount;
		web_timer.reset();
		web_timer.start();
	}
}
protected function webload_tick(event:TimerEvent):void {
	noticiaSistema = "Buscando tablas en: "+ (web_timer.repeatCount - web_timer.currentCount);
}
protected function webload_complete(event:TimerEvent):void {
	tablasMenu.btnTablas_webLoad.enabled=false;
	noticiaSistema = "Buscando tablas";
	var loader:URLLoader = new URLLoader;
	loader.dataFormat = URLLoaderDataFormat.TEXT;
	var req:URLRequest = new URLRequest(Global.banca.config.servidorWeb+"/tablas/leer.php");
	req.method = "get";
	
	var vars:URLVariables = new URLVariables;
	vars.hipodromo = vCarrera.iCarrera.Hipodromo;
	vars.fecha = vCarrera.iCarrera.fecha();
	vars.carrera = vCarrera.iCarrera.Carrera;
	vars.bancalocal = Global.banca.config.webID;
	req.data = vars;
	
	loader.addEventListener(Event.COMPLETE,webload_load_complete,false,0,true);
	loader.addEventListener(IOErrorEvent.IO_ERROR,webload_ioerror,false,0,true);
	loader.load(req);
}

protected function webload_ioerror(event:IOErrorEvent):void {
	tablasMenu.btnTablas_webLoad.enabled=true;
	Alert.show("Imposible conectarse al servidor de tablas","Error de conexión",4,this);
	web_timer.reset();
	web_timer.start();
}
private var resultados:Array;
protected function webload_load_complete(event:Event):void {
	tablasMenu.btnTablas_webLoad.enabled=true;
	if (String(event.currentTarget.data)=="0001") {
		Alert.show("Las tablas no estan disponibles para esta banca, si desea suscribirse al servicio, por favor comuniquese con el desarrollador.","",4,this);
		return;
	}
	var data:String = event.currentTarget.data as String;
	if (data && data.length>0) {
		shorcuts = false;
		web_timer.reset();
		webload=false;
		var resultado:Array = JSON.parse(data) as Array;
		var lista:ListaTablas = new ListaTablas;
		lista.initialize();
		lista.tablasBancas = resultado;
		lista.ejemplares = ejemplares.toArray();
		PopUpManager.addPopUp(lista,this,true);
		PopUpManager.centerPopUp(lista);
		lista.addEventListener(ListaTablas_SelectTabla.SELECT_TABLA,webload_load_confirmado);
		lista.addEventListener(CloseEvent.CLOSE,tablas_cerrarHandler);
		noticiaSistema = "Tablas encontradas";
		netManager.ACTIVIDAD.send("",5,"",HipicoActividad.TBL_CARGAWEB);
	} else {
		web_timer.reset();
		web_timer.start();
	}
}
protected function webload_load_confirmado(event:ListaTablas_SelectTabla):void {
	Alert.yesLabel = "Si"; Alert.noLabel = "No";
	var tbls:Tablas_v2 = new Tablas_v2;
	tbls.carrera = vCarrera.iCarrera;
	tbls.addEventListener("tablaGuardada",tablas_tablasCreadasHandler);
	tbls.addEventListener(CloseEvent.CLOSE,tablas_cerrarHandler,false,0,true);
	tbls.ejemplares = new ArrayCollection(event.tablas);
	
	PopUpManager.addPopUp(tbls,this,true);
	PopUpManager.centerPopUp(tbls);
	tbls.webload();
	noticiaSistema = "Tablas seleccionadas";
	netManager.ACTIVIDAD.send("",5,"",HipicoActividad.TBL_SELECCIONADA,event.banca);
}
protected function tablasMenu_btnTablas_abrir(event:MouseEvent):void {
	shorcuts=false;
	var tblv2:Tablas_v2 = new Tablas_v2;
	tblv2.ejemplares = ejemplares;
	tblv2.carrera = vCarrera.iCarrera;
	tblv2.addEventListener("tablaGuardada",tablas_tablasCreadasHandler);
	PopUpManager.addPopUp(tblv2,this,false);
	PopUpManager.centerPopUp(tblv2);
	tblv2.addEventListener(CloseEvent.CLOSE,tablas_cerrarHandler,false,0,true);
}
protected function tablas_tablasCreadasHandler(event:Event):void {
	monitorTaquillas();
	(event.target as Tablas_v2).removeEventListener("tablaGuardada",tablas_tablasCreadasHandler);
}
protected function tablas_cerrarHandler(event:CloseEvent):void {
	shorcuts=true;
	this.setFocus();
}
