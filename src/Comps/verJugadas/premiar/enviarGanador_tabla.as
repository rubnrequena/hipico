import Clases.Ganador.Carrera;

import Comps.itemGanador;

import VOs.VOCarrera;
import VOs.VOEjemplar;

import flash.events.MouseEvent;
import flash.utils.getTimer;

import libVOs.Tablas;

import mx.controls.Alert;
import mx.core.IVisualElement;

protected function iniciarTabla():void {
	var gn:itemGanador; var g:Array;
	for (var i:int = 0; i < Global.banca.bancas.numBancas; i++) {
		gn = bancas.getElementAt(i) as itemGanador;
		g = Global.tablas.ganadores.leer({FHC:carrera.FHC,BancaID:gn.banca});
		gn.tieneGanadorTabla = g?true:false;
	}
	g = Global.tablas.ganadores.leer({FHC:carrera.FHC,BancaID:gn.banca});
	if (g) {
		if (g.length==1) {
			tablaEjemplares.selectedIndex = (g[0].Numero)-1;
			hayGanadorTabla=true;
		} else if (g.length==2) {
			empates++;
			tablaEjemplares.selectedIndex = (g[0].Numero)-1;
			tablaEjemplares2.selectedIndex = (g[1].Numero)-1;
			hayGanadorTabla=true;
		} else {
			hayGanadorTabla=false;
		}
	} else {
		hayGanadorTabla=false;
	}
}
protected function btnEnviarGanadorTablas_clickHandler(event:MouseEvent):void {
	if (tablaEjemplares.selectedIndex>-1) {
		if (chkEmpate.selected && tablaEjemplares2.selectedIndex==-1) {
			Alert.show("Seleccione el 2do ejemplar ganador de tabla","",4,this); return;
		}
	} else {
		Alert.show("Seleccione el ejemplar ganador de tabla","",4,this); return;
	}
	var _bancas:Vector.<int> = new Vector.<int>;
	var _carrera:VOCarrera = new VOCarrera;
	var _ganadores:Vector.<VOEjemplar> = new Vector.<VOEjemplar>;
	
	var bnc:itemGanador;
	var i:int;
	for (i = 0; i < bancas.numElements; i++) {
		bnc = bancas.getElementAt(i) as itemGanador;
		if (bnc.lblBanca.selected) {
			if (!bnc.tieneGanadorTabla) {
				_bancas.push(bnc.banca);
				bnc.tieneGanadorTabla=true;
			} else {
				bnc.tablaRepetida();
			}
		}
	}
	_carrera.fecha = carrera.fecha();
	_carrera.hipodromo = carrera.Hipodromo;
	_carrera.carrera = carrera.Carrera;
	
	var _ejemplar:VOEjemplar = new VOEjemplar;
	_ejemplar.nombre = tablaEjemplares.selectedItem.Nombre;
	_ejemplar.numero = tablaEjemplares.selectedItem.Numero;
	_ganadores.push(_ejemplar);
	
	if (chkEmpate.selected) {
		_ejemplar = new VOEjemplar;
		_ejemplar.nombre = tablaEjemplares2.selectedItem.Nombre;
		_ejemplar.numero = tablaEjemplares2.selectedItem.Numero;
		_ganadores.push(_ejemplar);
	}
	Global.tablas.premios.premiar(_bancas,_carrera,_ganadores);
	
	hayGanadorTabla=true;
	_bancas=null;_carrera=null;_ganadores=null; _ejemplar=null; bnc=null;
}
protected function set hayGanadorTabla(value:Boolean):void {
	var b:Boolean=true;
	if (value) {
		b = false;
	} else { 
		for (var i:int = 0; i < bancas.numElements; i++) { 
			if ((bancas.getElementAt(i) as itemGanador).tieneGanadorTabla) { b = false; } 
		}
	}
	tablaEjemplares.enabled=b; tablaEjemplares2.enabled=b;
}