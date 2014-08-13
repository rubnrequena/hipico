include "admTaquillasService.as";
include "admTaquillasTabla.as";

import Clases.network.HipicoActividad;
import Clases.network.netManager;

import Comps.verJugadas.Remate.RemateView;
import Comps.verJugadas.UI.ADMBloqueo.ADMBloqueoEjemplar;
import Comps.verJugadas.UI.ADMTaquillasNoticia;
import Comps.verJugadas.UI.IMonitor;
import Comps.verJugadas.UI.ShortCutHelp;
import Comps.verJugadas.UI.monitorVentas.ganador.MonitorVentaGanador;
import Comps.verJugadas.UI.monitorVentas.tabla.MonitorVentaTabla;
import Comps.verJugadas.UI.noticias.cerrarCarrerasAdvertencia;
import Comps.verJugadas.UI.noticias.noticiaEventos;
import Comps.verJugadas.abrirCarrera;
import Comps.verJugadas.premiar.enviarGanador;

import Sockets.HipicoSocketListener;

import UI.VerJugadas.comps.ADMCarrera;
import UI.VerJugadas.comps.CarreraStatusEvent;

import VOs.*;

import Ventanas.Balance;

import events.Evento;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.ui.Keyboard;
import flash.utils.Timer;
import flash.utils.setTimeout;

import libVOs.infoCarrera;

import mx.collections.ArrayCollection;
import mx.core.IVisualElement;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

protected var vCarrera:abrirCarrera;
[Bindable]
private var ejemplares:ArrayCollection;
//</Carrera>
private var _noticiasSistemaADM:noticiaEventos;
private var _noticiasVentasADM:noticiaEventos;

protected function window1_creationCompleteHandler(event:FlexEvent):void {
	_noticiasSistemaADM = new noticiaEventos;
	_noticiasSistemaADM.label = "Noticias del Sistema";
	_noticiasVentasADM = new noticiaEventos;
	_noticiasVentasADM.label = "Noticias de las Ventas";
	
	_noticiaSistema.addEventListener(MouseEvent.CLICK,noticiaSistema_clickHandler);
	_noticiaVentas.addEventListener(MouseEvent.CLICK,noticiaVentas_clickHandler);
	
	vCarrera = new abrirCarrera;
	//Inicializar Handlers
	vCarrera.selCarrera.add(cargarCarrera);
	dgRetirados.addEventListener(HipicoSocketListener.RETIRAR_EJEMPLAR,dgRetirados_onEjemplarChange);
	dgRetirados.addEventListener(HipicoSocketListener.BLOQUEAR_EJEMPLAR,dgRetirados_onBloquearChange);
	//Menu
	tablasMenu.btnTablas_webLoad.addEventListener(MouseEvent.CLICK,tablasMenu_btnTablas_webLoad);
	tablasMenu.btnTablas_nvaTabla.addEventListener(MouseEvent.CLICK,tablasMenu_btnTablas_abrir);
	carreraMenu.ganadorButton.addEventListener(MouseEvent.CLICK,function ():void { carreraMenu_enviarGanador(); });
	carreraMenu.btnNuevaCarrera.addEventListener(MouseEvent.CLICK,carreraMenu_btnNuevaCarrera_clickHandler);
	carreraMenu.premiosBoton.addEventListener(MouseEvent.CLICK,carreraMenu_abrirBalance);
	taquillasMenu.btnAdminTaquillas.addEventListener(MouseEvent.CLICK,taquillasMenu_btnAdminTaquillas_clickHandler);
	taquillasMenu.btnAbreTaquillas.addEventListener(MouseEvent.CLICK,taquillasMenu_abreBancas_clickHandler);
	taquillasMenu.btnCierraTaquillas.addEventListener(MouseEvent.CLICK,taquillasMenu_cierraBancas_clickHandler);
	//Declarar Handlers Globales
	this.addEventListener(Event.CLOSE,windowClose_handler);
	
	Global.net.ganador.addEventListener("ganadorTicketEliminado",socket_eliminarTicketGanador_handler);
	Global.net.ganador.addEventListener(HipicoSocketListener.VENTA_TICKETS,socket_ganadorJugadaRecibida);
	Global.net.tabla.addEventListener("tablaTicketEliminado",socket_eliminarTicketTabla);
	Global.net.tabla.addEventListener(HipicoSocketListener.VENTA_TICKETS,socket_tablaTicketRecibido);
	
	nuevaCarrera();
	
	web_timer = new Timer(1000,10);
	web_timer.addEventListener(TimerEvent.TIMER, webload_tick);
	web_timer.addEventListener(TimerEvent.TIMER_COMPLETE, webload_complete);
	
	contadorConexiones_setUp();
	
	this.maximize();
}

protected function dgRetirados_onBloquearChange(event:Evento):void {
	shorcuts=false;
	var bloquearEjemplar:ADMBloqueoEjemplar = new ADMBloqueoEjemplar;
	bloquearEjemplar.ejemplar = event.data;
	bloquearEjemplar.carrera = carreraActual;
	bloquearEjemplar.addEventListener(CloseEvent.CLOSE,bloquearEjemplar_onClose);
	this.addElement(bloquearEjemplar);
}

protected function bloquearEjemplar_onClose(event:CloseEvent):void {
	this.removeElement(event.target as IVisualElement);
	shorcuts=true;
}

protected function dgRetirados_onEjemplarChange(event:Evento):void {
	Global.registros.add("Banca -> retirando ejemplar",JSON.stringify(event.data));
	Global.ganador.carreras.retirarEjemplar(carreraActual.FHC,event.data.Numero,event.data.Retirado);
	Global.ganador.ventas.retirarEjemplar(carreraActual.FHC,event.data.Numero,event.data.Retirado);
	
	Global.tablas.tablas.retirarEjemplar(carreraActual.FHC,event.data.Numero,event.data.Retirado);
	Global.tablas.ventas.retirarEjemplar(carreraActual.FHC,event.data.Numero,event.data.Retirado);
	
	Global.banca.carreras.retirarEjemplar(carreraActual.FHC,event.data.Numero,event.data.Retirado);
	Global.remate.carreras.retirarEjemplar(carreraActual.FHC,event.data.Numero,event.data.Retirado);
	
	Global.net.ejemplarRetirar(event.data,carreraActual.toDB);
	
	Global.tablas.tablas_padre.actualizarPorcentaje(carreraActual.FHC,dgRetirados.selectedItem.Retirado,dgRetirados.selectedIndex+1);

	var banca:IMonitor;
	for (var i:int = 0; i < Global.banca.bancas.numBancas; i++) {
		banca = vGanador.getElementAt(i) as MonitorVentaGanador;
		banca.ejemplarRetirado(event.data.Numero,event.data.Retirado);
		banca = vTablas.getElementAt(i) as MonitorVentaTabla;
		banca.ejemplarRetirado(event.data.Numero,event.data.Retirado);
	}
	if (event.data.Retirado==true)
		noticiaSistema = event.data.Numero+". "+event.data.Nombre+" RETIRADO";
	else
		noticiaSistema = event.data.Numero+". "+event.data.Nombre+" REINTEGRADO";
	
	updateTotal_Ganador();
	updateTotal_Tablas();
	tablasAgrupadas_iniciar();
	ganadorAgrupado_iniciar();
}
protected function taquillasMenu_cierraBancas_clickHandler(event:MouseEvent):void {
	Global.ganador.carreras_padre.carreras_ganadorTaquillas(carreraActual.FHC,false);
	Global.tablas.tablas_padre.carreras_taquillas(carreraActual.FHC,false);
	
	Global.net.ganador.statusCarreras(carreraActual.toDB,false);
	Global.net.tabla.statusCarreras(carreraActual.toDB,false);
	Global.net.remate.statusCarreras(carreraActual.toDB,false);
	monitorTaquillas();
	ADMTaquillasNoticia.popUp("cerradas",this);
	Global.registros.add("Banca -> cerrando carreras en todas las bancas");
	netManager.ACTIVIDAD.send(HIPICO.flags.appid,5,"",HipicoActividad.ACT_CARRERA_CIERRA,carreraActual.FHC,HIPICO.flags.version);
}

protected function taquillasMenu_abreBancas_clickHandler(event:MouseEvent):void {
	Global.ganador.carreras_padre.carreras_ganadorTaquillas(carreraActual.FHC,true);
	Global.tablas.tablas_padre.carreras_taquillas(carreraActual.FHC,true);
	
	Global.net.ganador.statusCarreras(carreraActual.toDB,true);
	Global.net.tabla.statusCarreras(carreraActual.toDB,true);
	Global.net.remate.statusCarreras(carreraActual.toDB,true);
	monitorTaquillas();
	ADMTaquillasNoticia.popUp("abiertas",this);
	Global.registros.add("Banca -> abriendo carreras en todas las bancas");
	netManager.ACTIVIDAD.send(HIPICO.flags.appid,5,"",HipicoActividad.ACT_CARRERA_ABRE,carreraActual.FHC,HIPICO.flags.version);
}
private var _shortcuts:Boolean=false;
protected function set shorcuts (activo:Boolean):void {
	if (_shortcuts!=activo) {
		_shortcuts=activo;
		if (activo) {
			this.nativeWindow.stage.addEventListener(KeyboardEvent.KEY_UP,nativeWindowStage_keyUp);
		} else {
			this.nativeWindow.stage.removeEventListener(KeyboardEvent.KEY_UP,nativeWindowStage_keyUp);
		}
	}
}
protected function nativeWindowStage_keyUp (event:KeyboardEvent):void {
	switch(event.keyCode) {
		case Keyboard.ESCAPE: { nuevaCarrera(); break; }
		case Keyboard.ENTER : { 
			if (this.adm_tqv.currentState=="open")
				taquillasMenu_cierraBancas_clickHandler(new MouseEvent(MouseEvent.CLICK));
			else
				taquillasMenu_abreBancas_clickHandler(new MouseEvent(MouseEvent.CLICK));
			break;
		}
		case Keyboard.B : {
			carreraMenu_abrirBalance(new MouseEvent(MouseEvent.CLICK)); break;
		}
		case Keyboard.T : {
			if (event.ctrlKey)
				tablasMenu_btnTablas_abrir(new MouseEvent(MouseEvent.CLICK));
			else
				tablasMenu_btnTablas_webLoad(new MouseEvent(MouseEvent.CLICK));
			break;
		}
		case Keyboard.R: {
			remateMenu_btnRemate_clickHandler(new MouseEvent(MouseEvent.CLICK));
			break;
		}
		case Keyboard.A: {
			taquillasMenu_btnAdminTaquillas_clickHandler(new MouseEvent(MouseEvent.CLICK));
			break;		
		}
		case Keyboard.P: { carreraMenu_enviarGanador(); break; }
		case Keyboard.F1: {
			if (ShortCutHelp.isPopUp) {
				ShortCutHelp.popOff();
			} else {
				ShortCutHelp.popUp(this);
			}
		}
	}
}
private var carreraActual:infoCarrera;
protected function cargarCarrera(carrera:infoCarrera):void {
	carreraActual = carrera;
	lblFecha.text = carrera.fecha("DD/MM/YYYY");
	lblHipo.text = carrera.Hipodromo;
	lblCarrera.text = carrera.Carrera.toString();
	//Info Carrera
	var _carrera:Array = Global.banca.carreras.leerFHC(carrera.fecha(),carrera.Hipodromo,carrera.Carrera);
	if (_carrera) {
		//Jugadas Previas
		updateGanador_handler();
		updateTablas_handler();
		
		ejemplares = new ArrayCollection(_carrera);
		monitorTaquillas();
		
		cpanel.enabled=true;
		this.removeElement(vCarrera);
		this.setFocus();
		setTimeout(function():void { shorcuts=true; },500);
	} else {
		noticiaSistema = "No se han asignado ejemplares para esta carrera";
	}
}
private function nuevaCarrera():void {
	shorcuts=false;
	if (web_timer) web_timer.reset();
	webload=false;
	_noticiaSistema.text = "";
	_noticiaVentas.text = "";
	
	cpanel.enabled=false;
	this.addElement(vCarrera);
}
protected function carreraMenu_btnNuevaCarrera_clickHandler(event:MouseEvent):void { nuevaCarrera(); }
protected function carreraMenu_enviarGanador():void {
	if (cn_tablasAbiertas.text == "0" && cn_ganadoresAbiertas.text == "0") {
		shorcuts=false;
		var gp:enviarGanador = new enviarGanador;
		gp.ejemplares = ejemplares;
		gp.carrera = vCarrera.iCarrera;
		this.addElement(gp);
		gp.addEventListener(CloseEvent.CLOSE,enviarGanador_closeHandler,false,0,true);
	} else {
		var cca:cerrarCarrerasAdvertencia = new cerrarCarrerasAdvertencia;
		cca.addEventListener(CloseEvent.CLOSE,cerrarCarrera);
		this.addElement(cca);
		shorcuts=false;
	}
}

protected function cerrarCarrera(event:CloseEvent):void {
	if (event.detail==1) {
		taquillasMenu_cierraBancas_clickHandler(new MouseEvent(MouseEvent.CLICK));
		carreraMenu_enviarGanador();
	}
	this.removeElement(event.target as IVisualElement);
	shorcuts=true;
}
protected function enviarGanador_closeHandler (event:CloseEvent):void {
	shorcuts=true;
	this.removeElement(event.target as IVisualElement);
	this.setFocus();
}
protected function windowClose_handler(e:Event):void {
	Global.net.ganador.removeEventListener("ganadorTicketEliminado",socket_eliminarTicketGanador_handler);
	Global.net.ganador.removeEventListener(HipicoSocketListener.VENTA_TICKETS,socket_ganadorJugadaRecibida);
	Global.net.tabla.removeEventListener("tablaTicketEliminado",socket_eliminarTicketTabla);
	Global.net.tabla.removeEventListener(HipicoSocketListener.VENTA_TICKETS,socket_tablaTicketRecibido);
}
private var balance:Balance;
protected function carreraMenu_abrirBalance(e:MouseEvent):void {
	balance = new Balance;
	balance.iCarrera = carreraActual;
	PopUpManager.addPopUp(balance,this,true);
	PopUpManager.centerPopUp(balance);
	balance.premioRecibido.add(balance.creationCompleteHandler);
	balance.addEventListener(CloseEvent.CLOSE,balanceClose);
}

protected function balanceClose(event:CloseEvent):void {
	PopUpManager.removePopUp(balance); balance = null;
}

protected function remateMenu_btnRemate_clickHandler(event:MouseEvent):void {
	var remateVista:RemateView;
	remateVista = new RemateView;
	remateVista.carrera = vCarrera.iCarrera;
	remateVista.open(true);
	remateVista.addEventListener(Event.CLOSE,function (e:Event):void { remateVista=null; });
}
protected function taquillasMenu_btnAdminTaquillas_clickHandler (event:MouseEvent):void {
	shorcuts=false;
	var acPanel2:ADMCarrera = new ADMCarrera;
	acPanel2.carrera = carreraActual;
	acPanel2.addEventListener(CloseEvent.CLOSE,admCarreraPanel_close);
	acPanel2.addEventListener(CarreraStatusEvent.STATUS_CHANGE,monitorTaquillas_handler);
	this.addElement(acPanel2);
}

protected function admCarreraPanel_close(event:CloseEvent):void {
	event.target.dispose();
	event.target.removeEventListener(CloseEvent.CLOSE,admCarreraPanel_close);
	event.target.removeEventListener(CarreraStatusEvent.STATUS_CHANGE,monitorTaquillas_handler);
	this.removeElement(event.target as IVisualElement);
	shorcuts=true;
	this.setFocus();
}
//Panel agrupar ejemplares
protected function mostrarEjemplares(event:MouseEvent):void {
	btnMostrar_Ejemplares.enabled=false;
	btnMostrar_GanadorAgrupado.enabled=true;
	btnMostrar_TablasAgrupado.enabled=true;
	panel_izq.removeElement(dgRetirados);
	panel_izq.addElement(dgRetirados);
}
protected function mostrarGanadorAgrupado(event:MouseEvent):void {
	btnMostrar_Ejemplares.enabled=true;
	btnMostrar_GanadorAgrupado.enabled=false;
	btnMostrar_TablasAgrupado.enabled=true;
	panel_izq.removeElement(listGanadorAgrupado);
	panel_izq.addElement(listGanadorAgrupado);
}
protected function mostrarTablasAgrupado(event:MouseEvent):void {
	btnMostrar_Ejemplares.enabled=true;
	btnMostrar_GanadorAgrupado.enabled=true;
	btnMostrar_TablasAgrupado.enabled=false;
	panel_izq.removeElement(listTablaAgrupado);
	panel_izq.addElement(listTablaAgrupado);
}
protected function getTickets (banca:int,ventas:Array):Array {
    var v:Array = []; var i:int; var len:int = ventas?ventas.length-1:-1;
    for (i=len;i>-1;i--) {
        if (ventas[i].BancaID==banca) v.push(ventas[i]);
    }
    return v;
}