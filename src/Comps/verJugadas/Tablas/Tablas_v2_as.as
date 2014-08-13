import Comps.verJugadas.Tablas.bancaTabla;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import libVOs.infoCarrera;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.collections.IList;
import mx.core.IVisualElement;
import mx.events.FlexEvent;

import sr.modulo.Modulo;

private var _ejemplares:Array;

public var carrera:infoCarrera;
private var _tablas_padre:Array;
//private var _tablas:Array; 0001

public function set ejemplares(e:ArrayCollection):void { _ejemplares = e.toArray(); }
protected function titlewindow1_creationCompleteHandler(event:FlexEvent):void {
	var t:int = getTimer();
	var i:int; var _bt:bancaTabla;
	_tablas_padre = Global.tablas.tablas_padre.leer(carrera.fecha(),carrera.Hipodromo,carrera.Carrera);
	//_tablas = Global.tablas.tablas.leer({FHC:carrera.FHC},"*",null,"BancaID, Numero ASC"); 0001
	var tablasCoord:Point; 
	for (i = 0; i < Global.banca.bancas.numBancas; i++) {
		_bt = new bancaTabla;
		grp_bancas.addElement(_bt);
		_bt.labanca = Global.banca.bancas.bancaByID(i+1);
		_bt.tablas = new ArrayList(Global.tablas.tablas.leer({FHC:carrera.FHC,BancaID:_bt.labanca.ID},"*",null,"Numero ASC"));
		/* experimental 0001
		if (_tablas) {
			tablasCoord = extraerTablasBanca(_bt.labanca.ID);
			_bt.tablas = new ArrayList(_tablas.slice(tablasCoord.x,tablasCoord.y+1));
		}*/
		_bt.tablaPadre = tablaPadreBanca(i+1);
		_bt.btnVer.addEventListener(MouseEvent.CLICK,bt_onClick);
	}
	this.stage.addEventListener(KeyboardEvent.KEY_UP,this_keyUp);
	eliminarTablas.addEventListener(MouseEvent.CLICK,eliminarTablas_click);
}

protected function eliminarTablas_click(event:MouseEvent):void {
	Global.tablas.eliminar("Tablas",{FHC:carrera.FHC});
	Global.tablas.eliminar("Tablas_Padre",{FHC:carrera.FHC});
	var i:int; var bt:bancaTabla;
	for (i = 0; i < grp_bancas.numElements; i++) {
		bt = grp_bancas.getElementAt(i) as bancaTabla;
		Global.net.tabla.tablasNuevas(carrera.toDB,bt.labanca.ID);
	}
}
/*
experimental 0001
protected function extraerTablasBanca (banca:int):Point {
	var p:Point = new Point(-1,-1);
	for (var i:int = 0; i < _tablas.length; i++)  {
		if (_tablas[i].BancaID==banca) p.x=i;
		if (p.x>-1) { if (_tablas[i].BancaID!=banca) { p.y = i-i; return p;}; }
	}
	return p;
}*/
protected function onRemovedFromStage(event:Event):void {
	this.stage.removeEventListener(KeyboardEvent.KEY_UP,this_keyUp);
}
protected function tablaPadreBanca(banca:int):Object {
	var len:int = _tablas_padre?_tablas_padre.length:0;
	for (var i:int = 0; i < len; i++) {
		if (_tablas_padre[i].BancaID==banca) return _tablas_padre[i];
	}
	return null;
}
protected function this_keyUp(event:KeyboardEvent):void {
	if (Keyboard.F1 == event.keyCode)
		this.currentState = "insertarTablas"; 
	if (Keyboard.F2 == event.keyCode)
		if (!locked.visible) btnGuardar_clickHandler();
}

protected function bt_onClick(event:MouseEvent):void {
	var bt:bancaTabla = event.target.parent as bancaTabla;
	dg_tablas_banca.dataProvider = bt.tablas;
	lblBanca_mod.text = bt.labanca.Nombre;
	var i:int;
	for (i = 0; i < grp_bancas.numElements; i++) { (grp_bancas.getElementAt(i) as bancaTabla).viendo=false; }
	bt.viendo=true;
}

protected function btnGuardar_clickHandler():void {
	var i:int; var enviarTablas:Vector.<int> = new Vector.<int>;
	var tablasPadre:Array = new Array;
	var tablaPadre:Object;
	var tablas:Array = new Array;
	var bt:bancaTabla; var del:Vector.<int> = new Vector.<int>;
	for (i = 0; i < grp_bancas.numElements; i++) {
		bt = grp_bancas.getElementAt(i) as bancaTabla;
		if (bt.selected) {
			tablaPadre = carrera.toDB;
			tablaPadre.FHC = Modulo.fhc(carrera.fecha(),carrera.Hipodromo,carrera.Carrera);
			tablaPadre.Abierta = true;
			tablaPadre.Paga = bt.tabla_paga;
			
			tablaPadre.Porcentaje = Global.banca.config.tablaPorcentaje;
			tablaPadre.BancaID = bt.labanca.ID;
			tablasPadre.push(tablaPadre);
			tablas = tablas.concat(bt.tablas.toArray());
			del.push(bt.labanca.ID);
		}
	}
	Global.tablas.reiniciarTablas(del,carrera.FHC);
	Global.tablas.guardarTablas(tablasPadre,tablas);
	for (i = 0; i < grp_bancas.numElements; i++) {
		bt = grp_bancas.getElementAt(i) as bancaTabla;
		if (bt.selected) {
			bt.guardado();
			Global.net.tabla.tablasNuevas(carrera.toDB,bt.labanca.ID);
			Global.net.tablavisor.tablasNuevas(carrera.toDB,bt.labanca.ID);
			Global.registros.add("Banca -> Enviando tablas a ",bt.labanca.Nombre);
		}
	}
	this.dispatchEvent(new Event("tablaGuardada"));
}
protected function spinner_clickHandler (event:MouseEvent):void {
	var dp:IList = dg_tablas_banca.dataProvider;
	var mult:Number = spinner.value==1?.5:2;
	var len:int = dp?dp.length:0;
	for (var i:int = 0; i < len; i++) {
		dp.getItemAt(i).Monto = uint(dp.getItemAt(i).Monto*mult);
		dp.itemUpdated(dp.getItemAt(i),"Monto");
	}
}
protected function select_clickHandler (event:MouseEvent):void {
	var bt:bancaTabla;
	for (var i:int = 0; i < grp_bancas.numElements; i++) {
		bt = grp_bancas.getElementAt(i) as bancaTabla;
		bt.selected = select.selected;
	}
	
}