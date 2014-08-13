import Clases.network.HipicoActividad;
import Clases.network.netManager;

import Cliente.CSocket;

import Comps.Login;
import Comps.Macuare.MacuarePremiarModal;
import Comps.confirmarEliminarTicket;
import Comps.verJugadas.admTaquillas;

import Events.SocketDataEvent;

import Sockets.HipicoSocketListener;

import UI.Main.AvisoPago;
import UI.Main.CargarCarrerasModal;
import UI.Main.Conexiones.Conexiones;
import UI.Main.EliminarTicket;
import UI.Main.MacuareModal;
import UI.Main.MacuareMonitorModal;
import UI.Main.MainView;
import UI.Main.PanelAcercaDe;
import UI.Main.PanelHipodromos;
import UI.Main.Setup;
import UI.Main.TopesModal;
import UI.Main.bancoDatos.BancoDatosModal;
import UI.Main.taquillas.TaquillasView;
import UI.Reporte.ReporteTickets;
import UI.Reporte.ReporteTipo;
import UI.Reporte.pago.ReportePago;
import UI.shared.ModalYesNo;

import Ventanas.Bancas.BancasModal;
import Ventanas.ConfigModal;
import Ventanas.Reporte.Reporte_v3;
import Ventanas.Tareas;

import activarApp.Activar;

import appkit.responders.NResponder;

import as3.SWFValidateFlex;

import com.demonsters.debugger.MonsterDebugger;

import core.Navegador;
import core.Registros;

import events.CloseEvent;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.UncaughtErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.SharedObject;
import flash.system.System;

import mx.controls.Alert;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import vistas.VistaUI;

protected var so:SharedObject = SharedObject.getLocal("Hipico");
//UI
private var nav:Navegador;
private var mainView:MainView;
private var settingUp:Setup;
public static var swfvalid:SWFValidateFlex;
public static var flags:Object = {};

protected function setUp(opt:int=-1):void {
	if (so.data.setUp==null || opt==0) {
		settingUp.currentState = "inicio";
		this.addElement(settingUp);
		return;
	}
	if (so.data.carpetaBD==null || opt==1) {
		settingUp.currentState = "basedatos";
		this.addElement(settingUp);
		return;
	}
	settingUp.onComplete.dispatch(null);
}
protected function windowedapplication1_initializeHandler(event:FlexEvent):void {
	MonsterDebugger.initialize(this);
	Alert.yesLabel = "Si";
	this.nativeWindow.x = 0;
	this.nativeWindow.y = 0;
	
	iniciarErrorLogs();
	
	this.addEventListener(Event.CLOSING,function (e:Event):void {
		e.preventDefault();
		var cerrarModal:ModalYesNo = new ModalYesNo("¿Seguro desea salir del sistema?",cerrarHipico);
		nav.modalPopUp(cerrarModal);
	});
	
	var xml : XML = NativeApplication.nativeApplication.applicationDescriptor;
	var ns : Namespace = xml.namespace();
	var version : String = xml.ns::versionNumber;
	flags.version = version;
	System.disposeXML(xml);
	
	var ff:File = File.applicationStorageDirectory.resolvePath("key.sr");
	if (ff.exists) {
		var f:FileStream = new FileStream;
		f.open(ff,FileMode.READ);
		var o:Object = f.readObject();
		f.close();
		flags.appid = o.appid;
	} else {
		flags.appid = "na";
	}
	ff=null; f =null;
}
protected function cerrarHipico(event:CloseEvent):void {
	if (event.detalle==Alert.YES) {
		Global.net.close();
		errorLogFile.close();
		this.nativeApplication.exit();
	}
}
protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void {
	var activar:Activar = new Activar("",0,"banca");
	if (!activar.validar()) {
		activar.addEventListener("activar",activar_onActivar,false,0,true);
		activar.activarBanca(this);
	} else {
		setUpHipico();
	}
}
protected function activar_onActivar(event:Event):void {
	event.target.cerrar();
	setUpHipico();
}
private function setUpHipico():void {
	settingUp = new Setup;
	settingUp.onComplete.add(setUpComplete);
	setUp();
}

protected function socket_eliminarTicketTabla(event:SocketDataEvent):void {
	var confTicket:confirmarEliminarTicket = new confirmarEliminarTicket;
	confTicket.data = event.data;
	confTicket.socket = event.socket;
	confTicket.click.addOnce(socket_eliminarTicketTabla_handler);
	PopUpManager.addPopUp(confTicket,this,true);
	PopUpManager.centerPopUp(confTicket);
}

private function socket_eliminarTicketTabla_handler(permiso:Boolean,data:Object,socket:CSocket):void {
	Global.registros.add("Tablas -> Eliminando ticket: "+permiso.toString(),File.lineEnding,JSON.stringify(data,null,3));
	
	if (permiso) Global.tablas.ventas.eliminarTickets(data.tickets,true);
	var _data:Object = {};
	_data.permiso = permiso;
	_data.ticket = data.tickets[0];
	socket.enviarDatos(HipicoSocketListener.ELIMINAR_TICKET,_data);
}
protected function socket_eliminarTicketGanador(event:SocketDataEvent):void {
	var confTicket:confirmarEliminarTicket = new confirmarEliminarTicket;
	confTicket.data = event.data;
	confTicket.socket = event.socket;
	confTicket.click.addOnce(socket_eliminarTicket_handler);
	
	PopUpManager.addPopUp(confTicket,this,false);
	PopUpManager.centerPopUp(confTicket);
}
protected function socket_eliminarTicket_handler(permiso:Boolean,data:*,socket:CSocket):void {
	Global.registros.add("Ganador -> Eliminando ticket: "+permiso.toString(),File.lineEnding,JSON.stringify(data,null,3));
	
	if (permiso) Global.ganador.ventas.eliminarTickets(data.tickets,true); 
	var _data:Object = new Object;
	_data.ventaID = data.ventaID;
	_data.permiso = permiso;
	_data.tickets = data.tickets;
	socket.enviarDatos(HipicoSocketListener.ELIMINAR_TICKET,_data);
}
protected function setUpComplete(ip:String):void {
	Global.iniciarModulos();
	Global.registros = new Registros(Global.banca.config.webID);
	if (ip) Global.banca.config.setConfig("servidorLocal",ip);
	
	inicializarSocket();
	
	nav = new Navegador;
	nav.percentHeight = nav.percentWidth = 100;
	nav.addEventListener(FlexEvent.CREATION_COMPLETE,cpanel_onComplete,false,0,true);
	this.addElement(nav);
	
	//trace("MEM in MB:\n"+ String(Math.round(1000*System.totalMemory/1048576)/1000));
}
protected function inicializarSocket():void {
	try {
		Global.net = new netManager();
		Global.net.ganador.addEventListener("ganadorTicketEliminado",socket_eliminarTicketGanador);
		Global.net.tabla.addEventListener("tablaTicketEliminado",socket_eliminarTicketTabla);
	} catch (e:Error) {
		Global.registros.add("Error "+e.errorID+": No fue posible iniciar la conexión");
		Alert.show("No fue posible iniciar la conexión","Error de conexion: "+e.errorID);
		return;
	}
}
private function setupComplete_servidorLocal(ip:String):void {
	if (ip) Global.banca.config.setConfig("servidorLocal",ip);
	inicializarSocket();
}
private function cpanel_onComplete(event:FlexEvent):void {
	nav.removeEventListener(FlexEvent.CREATION_COMPLETE,cpanel_onComplete);
	mainView = new MainView;
	nav.pushVista(mainView);  
	mainView.addEventListener(FlexEvent.CREATION_COMPLETE,mainView_onComplete);
	NResponder.add("global_"+HipicoSocketListener.ELIMINAR_TICKET,socket_macuareEliminarTicket);
}

protected function btnBancoDatos_clickHandler(event:MouseEvent):void {
	mainView.vista.modalPopUp(new BancoDatosModal);
}

private function socket_macuareEliminarTicket(ticket:Object,socket:CSocket,tipo:String):void {
	var wticket:EliminarTicket = new EliminarTicket(ticket,socket,tipo);
	NResponder.addNative(wticket,EliminarTicket.ON_CLOSE,socket_macuareEliminarTicket_handler,1);
	PopUpManager.addPopUp(wticket,this);
	PopUpManager.centerPopUp(wticket);
}

private function socket_macuareEliminarTicket_handler(permiso:Boolean,ventaId:String,socket:CSocket):void {
	Global.registros.add("Macuare -> Eliminando ticket: "+permiso.toString(),File.lineEnding,JSON.stringify(ventaId,null,3));
	
	if (permiso) Global.macuare.ventas.eliminar(int(ventaId));
	var _data:Object = new Object;
	_data.permiso = permiso;
	_data.ticket = ventaId;
	socket.enviarDatos(HipicoSocketListener.ELIMINAR_TICKET,_data);
	NResponder.dispatch("global_macuareEliminarTicket_handler",[permiso,ventaId]);
}

protected function btnConexiones_clickHandler(event:MouseEvent):void {
	nav.pushVista(new Conexiones);
}

private function mainView_onComplete (event:FlexEvent):void {
	mainView.removeEventListener(FlexEvent.CREATION_COMPLETE,mainView_onComplete);
	mainView.btnAcerca.addEventListener(MouseEvent.CLICK,acercaBtn);
	mainView.btCarrera.addEventListener(MouseEvent.CLICK,btCarrera_clickHandler);
	mainView.verJugadas.addEventListener(MouseEvent.CLICK,verJugadas_clickHandler);
	mainView.btnTopes.addEventListener(MouseEvent.CLICK,btnTopes_clickHandler);
	mainView.btnHipodromos.addEventListener(MouseEvent.CLICK,btnHipodromos_clickHandler);
	mainView.btnConfig.addEventListener(MouseEvent.CLICK,btnConfig_clickHandler);
	mainView.btnReporte.addEventListener(MouseEvent.CLICK,btnReporte_clickHandler);
	mainView.btnMacurare.addEventListener(MouseEvent.CLICK,btnMacuare_clickHandler);
	mainView.btnChat.addEventListener(MouseEvent.CLICK,btnChat_clickHandler);
	mainView.btnBancas.addEventListener(MouseEvent.CLICK,btnBancas_clickHandler);
	mainView.btnConexiones.addEventListener(MouseEvent.CLICK,btnConexiones_clickHandler);
	mainView.btnBancoDatos.addEventListener(MouseEvent.CLICK,btnBancoDatos_clickHandler);
	mainView.btnTaquillas.addEventListener(MouseEvent.CLICK,btnTaquillas_clickHandler);
	tareasIniciar();
}

protected function btnTaquillas_clickHandler(event:MouseEvent):void {
	nav.pushVista(new TaquillasView);
}
private var task:Tareas;
private function tareasIniciar():void {
	task = new Tareas;
	task.addEventListener("validarLicenciaLocal",task_validarLicenciaLocal);
	task.addCloseEvent(tareas_closeHandler);
	mainView.vista.modalPopUp(task);
}
protected function task_validarLicenciaLocal(event:Event):void {
	swfvalid = new SWFValidateFlex;
	swfvalid.validate();
}
private function tareas_closeHandler(event:CloseEvent):void {
	switch(event.detalle) {
		case 2: {}
		case -1: { loginInicia(); break; }
		case 0: {
			if ((new Date).date>24)
				AvisoPago.popUp("advertencia",avisoPago_closeHandler);
			else
				loginInicia();
			break;
		}
		case 1: {
			AvisoPago.popUp(AvisoPago.PAGO,avisoPago_closeHandler) ;
			break;
		}
	}
}
protected function avisoPago_closeHandler (e:CloseEvent):void { 
	loginInicia();
}

//region Menu
protected function acercaBtn (event:MouseEvent):void {
	mainView.vista.modalPopUp(new PanelAcercaDe);
}
protected function btnHipodromos_clickHandler(event:MouseEvent):void {
	mainView.vista.modalPopUp(new PanelHipodromos);
}
protected function btnTopes_clickHandler(event:MouseEvent):void {
	mainView.vista.modalPopUp(new TopesModal);
}
protected function btCarrera_clickHandler(event:MouseEvent):void {
	mainView.vista.modalPopUp(new CargarCarrerasModal);
}
protected function btnChat_clickHandler(event:MouseEvent):void {
	
}
//endregion
// Ventana - Ver Jugadas
public var admTq:admTaquillas;
protected function verJugadas_clickHandler(event:MouseEvent):void {
	if (admTq) {
		admTq.maximize();
	} else {
		Global.net.ganador.removeEventListener("ganadorTicketEliminado",socket_eliminarTicketGanador);
		Global.net.tabla.removeEventListener("tablaTicketEliminado",socket_eliminarTicketTabla);
		
		admTq = new admTaquillas;
		admTq.addEventListener(Event.CLOSE, admTq_cerrar);
		admTq.open(true);
	}
}

protected function admTq_cerrar(event:Event):void {	
	Global.net.ganador.addEventListener("ganadorTicketEliminado",socket_eliminarTicketGanador);
	Global.net.tabla.addEventListener("tablaTicketEliminado",socket_eliminarTicketTabla);
	admTq = null;
}
protected function btnReporte_clickHandler(event:MouseEvent):void {
	var rt:ReporteTipo = new ReporteTipo;
	mainView.vista.modalPopUp(rt);
	rt.addCloseEvent(reporteTipo_onClose);
}
protected function reporteTipo_onClose (event:CloseEvent):void {
	var rep:VistaUI;
	switch(event.detalle) {
		case ReporteTipo.VENTAS: {
			rep = new Reporte_v3;
			rep.left = rep.bottom = rep.right = rep.top = 0;
			break;
		}
		case ReporteTipo.TICKETS: {
			rep = new ReporteTickets;
			break;
		}
		case ReporteTipo.PAGOS: {
			rep = new ReportePago();
			break;
		}
		default: {
			return;
		}
	}
	nav.pushVista(rep);
	
	
}
//region Macuare
protected function btnMacuare_clickHandler (event:MouseEvent):void {
	mainView.vista.modalPopUp(new MacuareModal(macuareModal_close));
}
protected function macuareModal_close (e:CloseEvent):void {
	if (e.detalle==Alert.YES) {
		if (e.data=="premios") {
			mainView.vista.modalPopUp(new MacuarePremiarModal);
		}
		if (e.data=="monitor") {
			mainView.vista.modalPopUp(new MacuareMonitorModal);
		}
	}
}
//endregion
protected function btnConfig_clickHandler(event:MouseEvent):void {
	mainView.vista.modalPopUp(new ConfigModal);
}
protected function btnBancas_clickHandler (event:MouseEvent):void {
	mainView.vista.modalPopUp(new BancasModal);
}
protected function loginInicia():void {
	var login:Login = new Login;
	login.addCloseEvent(login_closeHandler);
	nav.modalPopUp(login);
}

private function login_closeHandler(event:CloseEvent):void {
	if (event.detalle==1) {
		Global.registros.add("Se inició sesión como Administrador");
		this.title += " | Administrador";
		netManager.ACTIVIDAD.send(HIPICO.flags.appid,5,"",HipicoActividad.NET_LOGINADMIN,"",HIPICO.flags.version);
	} else {
		Global.registros.add("Se inició sesión como usuario");
		netManager.ACTIVIDAD.send(HIPICO.flags.appid,5,"",HipicoActividad.NET_LOGIN,"",HIPICO.flags.version);
	}
}
public static var errorLogFile:FileStream;
private function iniciarErrorLogs():void {
	
	errorLogFile = new FileStream;
	var f:File = File.applicationStorageDirectory.resolvePath("errorLog.txt");
	errorLogFile.openAsync(f,FileMode.APPEND);
}

protected function onError (e:UncaughtErrorEvent):void {
	var date:Date = new Date;
	errorLogFile.writeMultiByte(date.toString()+": "+e.error.text+File.lineEnding,File.systemCharset);
}
// banco de datos
private function bancoDatos_btnCerrar_click(e:MouseEvent):void {
	mainView.currentState = "State1";
}
