import Clases.Banca.VOBanca;

import Common.Misc;

import Events.SocketEvent;

import UI.VerJugadas.comps.CarreraStatusEvent;

import flash.events.MouseEvent;

import mx.events.CloseEvent;

private function set noticiaSistema (noticia:String):void {
	_noticiaSistema.text = Common.Misc.formatFecha(null,"LL:NN:SS AA")+": "+noticia.split("C.H. ");
	_noticiasSistemaADM.push(_noticiaSistema.text);
}
private function set noticiaVentas (noticia:String):void {
	_noticiaVentas.text = Common.Misc.formatFecha(null,"LL:NN:SS AA")+": "+noticia.split("C.H. ");
	_noticiasVentasADM.push(_noticiaVentas.text);
}
private function contadorConexiones_setUp():void {	
	cn_bancaTotal.text = Global.banca.bancas.numBancas.toString();
	onClientesChange(new SocketEvent("",null));
	
	Global.net.addEventListener(SocketEvent.CONECTADO,onClientesChange);
	Global.net.addEventListener(SocketEvent.DESCONECTADO,onClientesChange);
}
protected function onClientesChange(event:SocketEvent):void {
	var c:int=0; var b:VOBanca;
	for (var i:int = 0; i < Global.banca.bancas.numBancas; i++) {
		b = Global.banca.bancas.bancas[i];
		if (b.numTaquillas>0) c++;
	}
	cn_bancaConectadas.text = c.toString();
}

protected function monitorTaquillas():void {
	var status:Array;
	var a:int; var b:int; var i:int; var len:int; var c:int;
	//Ganadores
	a=0;b=0;len=0;
	status = Global.ganador.carreras_padre.leer(carreraActual.fecha(),carreraActual.Hipodromo,carreraActual.Carrera);
	if (status) len=status.length;
	for (i = 0; i < len; i++) {
		if (status[i].Abierta==true)
			a++;
		else
			b++;
	}
	c += a;
	cn_ganadoresAbiertas.text = a.toString();
	cn_ganadoresCerradas.text = b.toString();
	//Tablas
	a=0;b=0;len=0;
	status = Global.tablas.tablas_padre.leer(carreraActual.fecha(),carreraActual.Hipodromo,carreraActual.Carrera);
	if (status) len=status.length;
	for (i = 0; i < len; i++) {
		if (status[i].Abierta==true)
			a++;
		else
			b++;
	}
	c += a;
	cn_tablasAbiertas.text = a.toString();
	cn_tablasCerradas.text = b.toString();
	
	adm_tqv.status(c);
}
protected function monitorTaquillas_handler(event:CarreraStatusEvent):void { monitorTaquillas(); }
protected function noticiaSistema_clickHandler(event:MouseEvent):void {
	_noticiasSistemaADM.right = 0;
	_noticiasSistemaADM.top = 42;
	this.addElement(_noticiasSistemaADM);	
}
protected function noticiaVentas_clickHandler(event:MouseEvent):void {
	_noticiasVentasADM.right = 0;
	_noticiasVentasADM.top = 42;
	this.addElement(_noticiasVentasADM);
}
protected function monitorVentas_closeHandler(event:CloseEvent):void {
	shorcuts=true;
	this.setFocus();
}