import Page.MultiPage;
import Page.com.PrintGridColumns;

import UI.Reporte.IReporteBancaDetalle;
import UI.Reporte.ReporteDetalle;
import UI.Reporte.ReporteEstadisticasModal;
import UI.Reporte.ReporteFechaModal;
import UI.shared.ModalOK;

import events.CloseEvent;

import flash.data.SQLResult;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.globalization.DateTimeStyle;
import flash.printing.PrintJob;
import flash.text.TextFormat;

import flashx.textLayout.formats.TextAlign;

import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.FlexEvent;

import spark.formatters.DateTimeFormatter;
import spark.formatters.NumberFormatter;

import sr.modulo.Modulo;

private var nf:NumberFormatter;

private var modalEstadistica:ReporteEstadisticasModal;
private var modalBusq:ReporteFechaModal;
private var reporte:Array;
protected function onCreateComplete (event:FlexEvent):void {
	nf = new NumberFormatter;
	nf.fractionalDigits = 2;
	this.addEventListener(MouseEvent.CLICK,listReporte_onClick);
	btnImprimir.addEventListener(MouseEvent.CLICK,btnImprimir_click,false,0,true);
	btnBuscar.addEventListener(MouseEvent.CLICK,btnBuscar_click);
	btnEstadisticas.addEventListener(MouseEvent.CLICK,btnEstadisticas_click);
	btnCerrar.addEventListener(MouseEvent.CLICK,btnCerrar_click);
	modalBusq = new ReporteFechaModal();
	modalBusq.addCloseEvent(panelBusq_close,0);
}

protected function btnCerrar_click(event:MouseEvent):void {
	this.popBack();
}

protected function btnEstadisticas_click(event:MouseEvent):void {
	if (modalEstadistica)
		this.vista.modalPopUp(modalEstadistica);
	else
		ModalOK.show("No hay reporte para visualizar, necesita realizar una busqueda",this.vista);
}

protected function btnBuscar_click(event:MouseEvent):void {
	this.vista.modalPopUp(modalBusq);
}
protected function listReporte_onClick(event:MouseEvent):void {
	if (event.target is IReporteBancaDetalle) {
		var r:SQLResult;
		var rd:ReporteDetalle = new ReporteDetalle;
		rd.title = Global.banca.bancas.bancaByID(event.target.data.BancaID).Nombre+" | "+event.target.data.Reporte;
		var m:Modulo;
		switch(event.target.data.Tipo)
		{
			case "Ganador": { m = Global.ganador; break; }
			case "Tablas": { m = Global.tablas; break; }
			case "Remate": { m = Global.remate; break; }
			case "Macuare": { return; }
		}
		
		if (modalBusq.desde.fechaSelecionada==modalBusq.hasta.fechaSelecionada) {
			if (modalBusq.chk_taquillas.selected) {
				r = m.sql('SELECT Carrera desc, SUM(Premios) premios, SUM(MontoJugado) jugado FROM Premios WHERE Fecha = "'+modalBusq.desde.fechaSelecionada+'" AND BancaID = '+event.target.data.BancaID+' AND Taquilla = "'+event.target.data.Reporte+'" GROUP BY Carrera');
			} else {
				r = m.sql('SELECT Carrera desc, SUM(Premios) premios, SUM(MontoJugado) jugado FROM Premios WHERE Fecha = "'+modalBusq.desde.fechaSelecionada+'" AND BancaID = '+event.target.data.BancaID+' GROUP BY Carrera');
			}
			rd.title += " - "+modalBusq.desde.fechaSelecionada;
		} else {
			if (modalBusq.chk_taquillas.selected) {
				r = m.sql('SELECT Fecha desc, SUM(Premios) premios, SUM(MontoJugado) jugado FROM Premios WHERE (Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'") AND BancaID = '+event.target.data.BancaID+' AND Taquilla = "'+event.target.data.Reporte+'" GROUP BY Fecha');
			} else {
				r = m.sql('SELECT Fecha desc, SUM(Premios) premios, SUM(MontoJugado) jugado FROM Premios WHERE (Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'") AND BancaID = '+event.target.data.BancaID+' GROUP BY Fecha');
			}
			rd.title += " - "+modalBusq.desde.fechaSelecionada+" / "+modalBusq.hasta.fechaSelecionada; 
		}
		this.addElement(rd);
		rd.reporte = r.data;
		
	}
}
protected function btnImprimir_click(event:MouseEvent):void {
	var df:DateTimeFormatter = new DateTimeFormatter;
	df.setStyle("locale","es_VE");
	df.dateStyle = DateTimeStyle.LONG;
	df.timeStyle = DateTimeStyle.LONG;
	
	var nf:NumberFormatter = new NumberFormatter;
	nf.fractionalDigits = 2;
	
	var pj:PrintJob = new PrintJob;
	var tf:TextFormat = new TextFormat("Courier New",20,null,true);
	if (pj.start()) {
		var pr:MultiPage = new MultiPage(pj.printableArea);
		pr.pushLine("REPORTE DE VENTAS",TextAlign.CENTER,new TextFormat("Verdana",26,null,null,null,null,null,null,"center"));
		pr.pushLine(df.format(new Date).toUpperCase(),TextAlign.CENTER);
		pr.pushLine(modalBusq.desde.fechaSelecionada+" - "+modalBusq.hasta.fechaSelecionada,TextAlign.CENTER);
		pr.pushLine(" ");
		var r:Array = reporte.concat();
		var jugado:Number=0; var premios:Number=0; var chnombre:String;
		var i:int; var j:int;
		var datos:Array; var rlen:int = r.length; var dlen:int;
		for (j = 0; j < rlen; j++) {
			datos = r[j].reportes.concat();
			dlen = datos.length;
			for (i = 0; i < dlen; i++) {
				jugado += Number(datos[i].MontoJugado);
				premios += Number(datos[i].Premios);
				datos[i].Balance = Number(datos[i].MontoJugado-datos[i].Premios).toFixed(2);
				datos[i].MontoJugado = Number(datos[i].MontoJugado).toFixed(2);
				datos[i].Premios = Number(datos[i].Premios).toFixed(2);
			}
			datos.push({Reporte:"TOTAL",MontoJugado:nf.format(jugado),Premios:nf.format(premios),Balance:nf.format(jugado-premios)});
			
			chnombre = r[j].Nombre;
			chnombre = chnombre.split("CENTRO HIPICO").join("C.H.");
			var columnas:Vector.<PrintGridColumns> = new Vector.<PrintGridColumns>;
			columnas.push(new PrintGridColumns("Reporte",chnombre,-100));
			columnas.push(new PrintGridColumns("MontoJugado","Jugado",120,TextAlign.RIGHT));
			columnas.push(new PrintGridColumns("Premios","Premios",120,TextAlign.RIGHT));
			columnas.push(new PrintGridColumns("Balance","Balance",120,TextAlign.RIGHT));
			pr.pushGrid(datos,columnas,pr.defaultFormat);
		}
		pr.sendPages(pj);
		datos=null;r=null;nf=null;df=null;pr=null;columnas=null;chnombre=null;
	}
}
protected function panelBusq_close(e:CloseEvent):void {
	if (e.detalle==Alert.NO) {
		return;
	}
	var cmd:String;
	var hipodromoCond:String="";
	if (modalBusq.hipo.selectedIndex>-1) {
		hipodromoCond = " AND Hipodromo = '"+modalBusq.hipo.selectedItem.Hipodromo+"'";
	}
	//Ganador
	var premiosGanador:Array;
	if (modalBusq.chk_taquillas.selected) {
		cmd = 'SELECT "Ganador" Tipo, Taquilla Reporte, BancaID, SUM(Premios) Premios, SUM(MontoJugado) MontoJugado FROM Premios WHERE (Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")'+hipodromoCond+" GROUP BY BancaID, Taquilla";
	} else {
		cmd = 'SELECT "Ganador" Tipo, "Ganador" Reporte, BancaID, SUM(Premios) Premios, SUM(MontoJugado) MontoJugado FROM Premios WHERE (Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")'+hipodromoCond+" GROUP BY BancaID";
	}
	premiosGanador = Global.ganador.sql(cmd).data;
	//tablas
	var premiosTablas:Array;
	if (modalBusq.chk_taquillas.selected) {
		cmd = 'SELECT "Tablas" Tipo, Taquilla Reporte, BancaID, SUM(Premios) Premios, SUM(MontoJugado) MontoJugado FROM Premios WHERE (Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")'+hipodromoCond+" GROUP BY BancaID, Taquilla";
	} else {
		cmd = 'SELECT "Tablas" Tipo, "Tablas" Reporte, BancaID, SUM(Premios) Premios, SUM(MontoJugado) MontoJugado FROM Premios WHERE (Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")'+hipodromoCond+" GROUP BY BancaID";
	}
	premiosTablas = Global.tablas.sql(cmd).data;
	//remate
	var premiosRemate:Array;
	cmd = 'SELECT "Remate" Tipo, "Remate" Reporte, BancaID, SUM(Premios) Premios, SUM(MontoJugado) MontoJugado FROM Premios WHERE (Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")'+hipodromoCond+" GROUP BY BancaID, Taquilla";
	premiosRemate = Global.remate.sql(cmd).data;
	
	//macuare
	var premiosMacuare:Array;
	if (modalBusq.chk_taquillas.selected) {
		cmd = 'SELECT "Macuare" Tipo, taquilla Reporte, bancaID BancaID, SUM(premio) Premios, SUM(jugado) MontoJugado FROM Premios WHERE (fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")'+hipodromoCond+" GROUP BY bancaID, taquilla";
	} else {
		cmd = 'SELECT "Macuare" Tipo, "Macuare" Reporte, bancaID BancaID, SUM(premio) Premios, SUM(jugado) MontoJugado FROM Premios WHERE (fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")'+hipodromoCond+" GROUP BY bancaID";
	}
	premiosMacuare = Global.macuare.sql(cmd).data;
	
	reporte = new Array; var b:Object; var r:Array; var a:int=0;
	var i:int;
	for (i = 1; i < Global.banca.bancas.numBancas+1; i++) {
		b = {ID:Global.banca.bancas.bancaByID(i).ID,Nombre:Global.banca.bancas.bancaByID(i).Nombre};
		b.reportes = new Array;
		
		r = filtrarReportes(premiosGanador,i);
		if (r) b.reportes = b.reportes.concat(r);
		
		r = filtrarReportes(premiosTablas,i);
		if (r) b.reportes = b.reportes.concat(r);
		
		r = filtrarReportes(premiosRemate,i);
		if (r) b.reportes = b.reportes.concat(r);
		
		r = filtrarReportes(premiosMacuare,i);
		if (r) b.reportes = b.reportes.concat(r);

		if (b.reportes.length>0) {
			reporte.push(b); a++;
		}
	}
	listReporte.dataProvider = new ArrayList(reporte);
	
	modalEstadistica = new ReporteEstadisticasModal;
	modalEstadistica.premiosGanador = premiosGanador;
	modalEstadistica.premiosTablas = premiosTablas;
	modalEstadistica.premiosRemate = premiosRemate;
	modalEstadistica.premiosMacuare = premiosMacuare;
	modalEstadistica.numReportes = a;
}
protected function filtrarReportes (array:Array,banca:int):Array {
	var o:Array = new Array;
	if (array) { 
		for (var i:int = 0; i < array.length; i++) {
			if (array[i].BancaID==banca) { o.push(array[i]); }
		}
	}
	return o.length>0?o:null;
}