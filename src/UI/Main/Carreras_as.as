import Clases.Banca.Carreras;
import Clases.Ganador.Carrera;
import Clases.Ganador.Carreras_Padre;
import Clases.Remate.Carrera;

import Common.Misc;

import UI.Noticia;

import flash.desktop.Clipboard;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.SharedObject;

import libVOs.infoCarrera;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.collections.GroupingField;
import mx.controls.Alert;
import mx.events.CalendarLayoutChangeEvent;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.utils.ObjectUtil;

import org.osflash.signals.natives.NativeSignal;

import spark.events.IndexChangeEvent;

[Bindable] private var Carrera:ArrayCollection;
[Bindable] private var ejemplares:ArrayList;
public var enviarCarrera_Click:NativeSignal;

private var so:SharedObject;
public function onBWDone():void {}
protected function titlewindow1_creationCompleteHandler(event:FlexEvent):void
{
	noticia = new Noticia(this);
	enviarCarrera_Click = new NativeSignal(btnEnviarCarreras,MouseEvent.CLICK,MouseEvent)
	enviarCarrera_Click.addOnce(enviarCarreras_clickHandler);
	cHipo.dataProvider = new ArrayList(Global.banca.hipodromos.datos);
	ejemplares = new ArrayList(Global.banca.ejemplares.datos);
}
public function Eliminar():void {
	var e:int = ejemplarIndex(dgCarrera.selectedItem.Nombre);
	if (e>=0) {
		ejemplares.addItem({Nombres:dgCarrera.selectedItem.Nombre});
		Carrera.removeItemAt(e);
	}
}
public function ejemplarIndex(caballo:String):int {
	for (var i:int=0;i<Carrera.length;i++) {
		if (Carrera.getItemAt(i).Nombre==caballo) {
			return i;
		}
	}
	return -1;
}
protected function cFecha_changeHandler(event:CalendarLayoutChangeEvent):void {
	
	if (cFecha.selectedDate) {
		info = new infoCarrera({Fecha:cFecha.selectedDate,Hipodromo:cHipo.selectedItem.Hipodromo,Carrera:cCarrera.value});
		Cargar();
	} else {
		Carrera.removeAll();
		g2.refresh();
	}
}
protected function hipodromos_changeHandler(event:IndexChangeEvent):void {
	
	if (cFecha.selectedDate) {
		info = new infoCarrera({Fecha:cFecha.selectedDate,Hipodromo:cHipo.dataProvider.getItemAt(event.newIndex).Hipodromo,Carrera:cCarrera.value});
		Cargar();
	}
}
private var info:infoCarrera;
protected function Cargar():Boolean{
	Carrera = new ArrayCollection(Global.banca.carreras.leer({Fecha:info.fecha(),Hipodromo:info.Hipodromo},"*",null,"Carrera ASC"));
	//Carrera = Global.db.Leer_Multi("Carreras", [{Fecha:info.fecha(),Hipodromo:info.Hipodromo}],"AND","*",null,"Carrera ASC");
	if (Carrera.length>0) {
		/*for each (var caballo:Object in Carrera) {
			caballo.Carrera = Misc.fillZeros(caballo.Carrera,2);
		}*/
		g2.refresh();
		return true;
	} else {
		g2.refresh();
		return false;
	}
}

protected function cCarrera_changeHandler(event:Event):void {
	if (cFecha.selectedDate) {
		cNumero.value = 1
		info = new infoCarrera({Fecha:cFecha.selectedDate,Hipodromo:cHipo.selectedItem.Hipodromo,Carrera:cCarrera.value});
	}
}
protected function combobox1_pasteHandler(event:Event):void {
	var pst:String = String(Clipboard.generalClipboard.getData(Clipboard.generalClipboard.formats[0])); 
	addCaballo(pst);
	busq.textInput.text = "";
}
protected function add_clickHandler(event:MouseEvent):void	{
	if (busq.textInput.text.length>0) { //Comprobar campo vacio
		for (var i:int=0;i<Carrera.length;i++) { //Comprobar duplicados
			if (Carrera.getItemAt(i).Nombre == busq.textInput.text && Carrera.getItemAt(i).Carrera == cCarrera.value) return; //si existe se cancela
		}
		addCaballo(busq.textInput.text);
		busq.setFocus();
		busq.textInput.selectAll();
	}
}
protected function caballoExiste(nombre:String):Boolean {
	for each (var item:Object in ejemplares) {
		if (item.Nombres==nombre) { return true; }
	}
	return false;
}
protected function ejemplarNumeroExiste(numero:int):Boolean {
	for each (var item:Object in ejemplares) {
		if (item.Numero==numero && item.Carrera==Misc.fillZeros(info.Carrera,2)) return true;
	}
	return false;
}
protected function addCaballo(Caballo:String):void {
	Caballo = Caballo.toUpperCase();
	if (cFecha.text.length>0) {
		//Comprobar si existe
		Global.banca.ejemplares.insertar(Caballo)
		//Guardar en la carrera
		/*if (!Carrera.getItemAt(cCarrera.value-1)) {
			Carrera.setItemAt(new Array,cCarrera.value-1);
		}*/
		var caballo:Object = info.toDB;
		caballo.FHC = info.FHC;
		caballo.Numero = cNumero.value;
		caballo.Nombre = Caballo;
		caballo.Retirado = false;
		Carrera.addItem(caballo);
		cNumero.value += int(auto.selected);
	} else {
		Alert.show("Campo de fecha obligatorio");
	}
}
/*protected function indexCaballo(caballo:String):int {
	for (var i:int=0;i<ejemplares.length;i++) {
		if (ejemplares[i].Nombres == caballo) return i;
	}
	return -1;
}*/
protected function titlewindow1_closeHandler(event:CloseEvent):void {
	if (so) so.close();
	this.parent.removeChild(this);
}
protected function enviarCarreras():void {
	var c:Array = Carrera.source;
	var j:int; var i:int;
	for (i = 0; i < c.length; i++) { delete c[i]["mx_internal_uid"]; }
	Global.banca.insertarUnion(Clases.Banca.Carreras.CARRERAS,c); // Guardar en banca
	var cp:Array = new Array; var cl:Array = Misc.agruparArray(c,"Carrera");
	var cc:Object; 
	for (i = 0; i < Global.banca.bancas.numBancas; i++) {
		for (j = 0; j < cl.length; j++)  {
			cc = new Object;
			cc.Fecha = cl[j].Fecha;
			cc.Hipodromo = cl[j].Hipodromo;
			cc.Carrera = cl[j].Carrera;
			cc.FHC = cl[j].FHC;
			cc.Abierta = true;
			cc.BancaID = Global.banca.bancas.bancas[i].ID;
			cp.push(cc);
		}
	}
	Global.ganador.insertarUnion(Carreras_Padre.CARRERAS_PADRE,cp);
	cp = new Array;
	for (i = 0; i < Global.banca.bancas.numBancas; i++) {
		for (j = 0; j < c.length; j++) {
			cc = ObjectUtil.copy(c[j]);
			cc.Bloqueado = false;
			cc.BancaID = Global.banca.bancas.bancas[i].ID;
			cp.push(cc);
		}
	}
	Global.ganador.insertarUnion(Clases.Ganador.Carrera.CARRERA,cp);
	Global.remate.insertarUnion(Clases.Remate.Carrera.CARRERA,cp);
		
	cc=null;
	enviarCarrera_Click.addOnce(enviarCarreras_clickHandler);
	
	btnEnviarCarreras.enabled=false;
}
protected function enviarCarreras_clickHandler(event:MouseEvent):void {
	enviarCarreras();
}
private function funcionGrupo(item:Object, field:GroupingField):String {
	return "Carrera "+Misc.fillZeros(item[field.name],2);
}
protected function btnBorrarCarrera_clickHandler(event:MouseEvent):void
{
	Alert.show("¿Seguro desea eliminar los datos de la carrera?","Eliminar carrera",1|2,null,function (close:CloseEvent):void {
		if (close.detail==Alert.YES) {
			Global.banca.carreras.eliminar({Fecha:cFecha.fechaSelecionada});
			
			Global.ganador.carreras.eliminar({Fecha:cFecha.fechaSelecionada});
			Global.ganador.carreras_padre.eliminar({Fecha:cFecha.fechaSelecionada});
			
			Global.remate.carreras.eliminar({Fecha:cFecha.fechaSelecionada});
			
			Alert.show("Datos de carrera eliminados");
			/* Carrera.removeAll();
			g2.refresh(); */
		}
	});
}