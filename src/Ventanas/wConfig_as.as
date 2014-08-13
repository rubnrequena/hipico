import Clases.Tabla.VOTablas_Rango;

import UI.AutoFormItemEvent;
import UI.Main.config.DividendosConfig;

import Validacion.cValidar;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;

import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.FlexEvent;

import spark.components.CheckBox;
import spark.components.gridClasses.GridColumn;
import spark.events.IndexChangeEvent;

protected function titlewindow1_creationCompleteHandler(event:FlexEvent):void {
	agruparBalance.selectedIndex = Global.banca.config.agruparBalance;
	if (Global.isAdmin) {
        btnAdmin.addEventListener(MouseEvent.CLICK,btnAdmin_click,false,0,true);
    }
	btnAdmin.visible=Global.isAdmin;
	
    if (Global.extOptions.dividendo) {
        configAccordion.addElement(new DividendosConfig());
    }
}
protected function btnAdmin_click(event:MouseEvent):void {
	this.currentState = this.currentState=="general"?"admin":"general";
}
protected function inicioTaquillas_changeHandler(event:Event):void {
	var chk:CheckBox = event.target as CheckBox;
	Global.banca.config.setConfig(chk.name,chk.selected);
}
protected function ns_changeHandler(event:Event):void {
	Global.banca.config.setConfig(event.currentTarget.id,event.currentTarget.value);
}
protected function dgRangos_funcionTipo(item:Object, column:GridColumn):String {
	return item.tipo == 0?"fijo":"suma";
}

[Bindable]private var tablas_rangos:ArrayList;
protected function tablas_addRango_clickHandler(event:MouseEvent):void {
	if (cValidar.ValidarNumero([pMinimo,pMaximo,cantTablas])) {
		if (validarRangos) {
			var rango:VOTablas_Rango  = new VOTablas_Rango;
			rango.Minimo = int(pMinimo.text);
			rango.Maximo = int(pMaximo.text);
			rango.Tablas = int(cantTablas.text);
			tablas_rangos.addItem(rango);
			Global.tablas.rangos.insertar(int(pMinimo.text),int(pMaximo.text),int(cantTablas.text));
			pMinimo.text = "";
			pMaximo.text = "";
			cantTablas.text = "";
		} else {
			Global.noticia.mostrarNoticiaRapida("Error: Colisión de rangos",this);
		}
	}
}
public function tablas_delRango_clickHandler():void {
	Global.tablas.rangos.remover(dgTablas_rangos.selectedItem.RangoID);
	tablas_rangos.removeItemAt(dgTablas_rangos.selectedIndex);
}
private function get validarRangos():Boolean {
	var i:int; var min:int=int(pMinimo.text); var max:int = int(pMaximo.text);
	for (i = 0; i < tablas_rangos.length; i++) {
		if (min>=tablas_rangos.getItemAt(i).Minimo && min <= tablas_rangos.getItemAt(i).Maximo) {
			dgTablas_rangos.selectedIndex = i;
			return false;
		}
		if (max>=tablas_rangos.getItemAt(i).Minimo && max <= tablas_rangos.getItemAt(i).Maximo) {
			dgTablas_rangos.selectedIndex = i;
			return false;
		}
	}
	return true;
}
protected function tablasPan_creationCompleteHandler(event:FlexEvent):void {
	tablas_rangos = new ArrayList(Global.tablas.rangos.rangos);
	publicar.selected = Global.banca.config.publicarTablas;
	doble.selected = Global.banca.config.enviarDoble;
}

protected function agruparBalance_changeHandler(event:IndexChangeEvent):void {
	Global.banca.config.setConfig("agruparBalance",agruparBalance.selectedIndex);
}

protected function bancasPan_creationCompleteHandler(event:FlexEvent):void {
	dgBancas.dataProvider = new ArrayList(Global.banca.bancas.bancas);
}

protected function btnAddBanca_clickHandler(event:MouseEvent):void {
	Global.banca.bancas.insertar(bancaNombre.text,bancaRIF.text);
	dgBancas.dataProvider = new ArrayList(Global.banca.bancas.bancas);
	bancaNombre.text = "";
	bancaRIF.text ="";
}

public function removerBanca ():void {
	Global.banca.bancas.remover(dgBancas.selectedItem.ID);
	dgBancas.dataProvider = new ArrayList(Global.banca.bancas.bancas);
}
public function formAdmin_guardar(event:AutoFormItemEvent):void {
	Global.banca.config.setConfig(event.campo,event.valor);
}
protected function taquillasPan_onComplete (event:FlexEvent):void {
	inicioTaquillas.selected = Global.banca.config.inicioTaquillas;
	dividendoGanador.value = Global.banca.config.dividendoGanador;
}
protected function calDividendos_change (e:Event):void {
    Global.extOptions.dividendo = calcDividendo.selected;
    Global.extOptions.save();
}
protected function randomID_change (e:Event):void {
	Global.extOptions.randomID = randomID.selected;
	Global.extOptions.save();
}
protected function randomSeed_change (e:Event):void {
	Global.extOptions.randomSeed = randomSeed.value;
	Global.extOptions.save();
}
protected function adminForm_complete (e:FlexEvent):void {
    calcDividendo.selected = Global.extOptions.dividendo;
	randomID.selected = Global.extOptions.randomID;
	randomSeed.value = Global.extOptions.randomSeed;
	
	btnReiniciarDatos.addEventListener(MouseEvent.CLICK,btnReinicarDatos_click);
}
protected function btnReinicarDatos_click(event:MouseEvent):void {
	Alert.show("¿Seguro desea reiniciar datos?","Reiniciar Datos",1|2,null,function (e:CloseEvent):void {
		if (e.detail==Alert.YES) {
			if (HIPICO.swfvalid) HIPICO.swfvalid.dispose();
			HIPICO.errorLogFile.close();
			Global.registros.close();
			File.applicationStorageDirectory.deleteDirectory(true);
			Alert.show("Datos reiniciados, se recomienda reiniciar el sistema.");
		}
	});
}
