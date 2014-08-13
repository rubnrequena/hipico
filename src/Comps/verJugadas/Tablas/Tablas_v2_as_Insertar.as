import Common.Misc;

import Comps.verJugadas.Tablas.bancaTabla;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.setTimeout;

import mx.collections.ArrayList;
import mx.events.FlexEvent;

import spark.events.GridItemEditorEvent;
import spark.events.GridSelectionEvent;

private var pagareal:int;
protected function datagrid1_gridItemEditorSessionSaveHandler(event:GridItemEditorEvent):void {
	var total:Number=0;
	for (var i:int = 0; i < _ejemplares.length; i++) {
		total += Number(_ejemplares[i].Monto);
	}
	lbl_total.text = "Total: "+total.toFixed(0);
	lbl_Paga.text = "Paga: "+(total-(total*(Global.banca.config.tablaPorcentaje/100))).toFixed(0);
	pagareal = total-(total*(Global.banca.config.tablaPorcentaje/100))
}
protected function grp_insertar_creationCompleteHandler(event:FlexEvent):void
{
	if (_ejemplares) {
		dg_insertar.dataProvider = new ArrayList(_ejemplares);
		if (_ejemplares[0].Monto==null) {
			for (var i:int = 0; i < _ejemplares.length; i++) { _ejemplares[i].Monto = 0; }
		}
	}
	dg_insertar.startItemEditorSession(0,2);
}
private var dgIndice:int=1;
protected function dg_insertar_keyUpHandler(event:KeyboardEvent):void {
	if (event.keyCode==Keyboard.ENTER) {
		dg_insertar.startItemEditorSession(dgIndice++,2)
		if (dgIndice>dg_insertar.dataProviderLength) {dgIndice=0;  }
		dg_insertar.selectedIndex=-1;
	}
}
protected function dg_insertar_selectionChangeHandler(event:GridSelectionEvent):void {
	dgIndice = dg_insertar.selectedIndex+1;
}
protected function btnConfirmar_insertar(event:MouseEvent):void {
	var i:int; var bt:bancaTabla;
	for (i = 0; i < grp_bancas.numElements; i++) {
		bt = grp_bancas.getElementAt(i) as bancaTabla;
		if (bt.selected) {
			bt.tablas = new ArrayList(Misc.clonarObjeto(_ejemplares));
			bt.enabled=true;
			autoPaga(bt.tablas,bt.labanca.tablas_multiplo);
			if (Global.tablas.rangos.activo) bt.tablas = Global.tablas.rangos.aplicar(bt.tablas);
		}
	}
	this.currentState = 'tablaGuardada';
	
	locked.visible=false;
	if (Global.banca.config.publicarTablas) {
		Global.net.tabla.publicarTablas(carrera.toDB,_ejemplares,pagareal);
	}
	setTimeout(goHome,2000);
	Global.registros.add("Banca -> Asignando tablas");
}
protected function autoPaga (tablas:ArrayList,multiplo:Number):void {
	var tlen:int = tablas?tablas.length:0; var i:int;
	for (i = 0; i < tlen; i++) {
		tablas.getItemAt(i).Monto = Number(tablas.getItemAt(i).Monto)*multiplo;
	}
}
private function goHome():void { this.currentState="State1"; }
public function webload():void { this.currentState = 'insertarTablas'; }