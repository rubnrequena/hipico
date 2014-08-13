package UI.Reporte.pago
{
	import Clases.Banca.VOBanca;
	import Clases.Ganador.Ganador;
	
	import Page.MultiPage;
	import Page.com.PrintGridColumns;
	
	import UI.Reporte.IReporteBancaDetalle;
	import UI.Reporte.ReporteDetalle;
	import UI.Reporte.ReporteEstadisticasModal;
	import UI.Reporte.ReporteFechaModal;
	import UI.shared.ModalOK;
	
	import events.CloseEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.globalization.DateTimeStyle;
	import flash.printing.PrintJob;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import spark.formatters.DateTimeFormatter;
	import spark.formatters.NumberFormatter;
	
	import sr.modulo.Modulo;
	

	public class ReportePago extends ReportePagoUI
	{
		private var modalBusq:ReporteFechaModal;

		private var reporte:Array;
		private var modalEstadistica:ReporteEstadisticasModal;
		public function ReportePago() {
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE,onComplete);
		}
		
		
		protected function onComplete(event:FlexEvent):void {
			removeEventListener(FlexEvent.CREATION_COMPLETE,onComplete);
			
			btnBuscar.addEventListener(MouseEvent.CLICK,buscarClick);
			btnCerrar.addEventListener(MouseEvent.CLICK,cerrarClick);
			btnEstadisticas.addEventListener(MouseEvent.CLICK,estadisticasClick);
			btnImprimir.addEventListener(MouseEvent.CLICK,imprimirClick);
			
			modalBusq =  new ReporteFechaModal;
			modalBusq.addCloseEvent(buscarModal_close,0);
			listReporte.addEventListener(MouseEvent.CLICK,listReporte_click);
		}
		
		protected function listReporte_click(event:MouseEvent):void {
			if (event.target is IReporteBancaDetalle && event.target.data.BancaID) {
				var rd:ReporteDetalle = new ReporteDetalle;
				rd.title = Global.banca.bancas.bancaByID(event.target.data.BancaID).Nombre+" | "+event.target.data.Reporte;
				var m:Modulo; var cols:String;
				var fechas:String = '(Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")';
				switch(event.target.data.Tipo) {
					case "Ganador": { m = Global.ganador; cols = "BancaID, SUM(Monto) MontoJugado"; break; }
					case "Tablas": { m = Global.tablas; cols = "BancaID, SUM(Monto*Cantidad) MontoJugado"; break; }
					case "Remate": { m = Global.remate; break; }
					case "Macuare": { return; }
				}
			}
			var ventas:Array;
			var premios:Array;
			if (modalBusq.desde.fechaSelecionada==modalBusq.hasta.fechaSelecionada) {
				ventas = m.sql('SELECT '+cols+', Carrera desc FROM Ventas WHERE '+fechas+' AND eliminado = false AND Devuelto = false AND BancaID = '+event.target.data.BancaID+' GROUP BY Carrera').data;
				premios = m.sql('SELECT BancaID, SUM(Premio) Premios, Carrera desc FROM Premiados WHERE '+fechas+' AND pago = true AND BancaID = '+event.target.data.BancaID+' GROUP BY Carrera').data;
				rd.title += " - "+modalBusq.desde.fechaSelecionada;
			} else {
				ventas = m.sql('SELECT '+cols+', Fecha desc FROM Ventas WHERE '+fechas+' AND eliminado = false AND Devuelto = false AND BancaID = '+event.target.data.BancaID+' GROUP BY Fecha').data;
				premios = m.sql('SELECT BancaID, SUM(Premio) Premios, Fecha desc FROM Premiados WHERE '+fechas+' AND pago = true AND BancaID = '+event.target.data.BancaID+' GROUP BY Fecha').data;
				rd.title += " - "+modalBusq.desde.fechaSelecionada+" / "+modalBusq.hasta.fechaSelecionada; 
			}
			//Validar
			if (premios==null) premios = [];
			if (ventas==null) ventas = [];
			//Procesar
			var i:int; var len:int = ventas.length;
			var _reportes:Array = new Array(len);
			for (i = 0; i < len; i++) {
				_reportes[i]= getReporteCampo(event.target.data.BancaID,ventas,premios,ventas[i].desc);
			}
			
			this.addElement(rd);
			rd.reporte = _reportes;
		}
		private function getReporteCampo (banca:int,ventas:Array,premios:Array,campo:*):Object {
			var item:Object; var r:Object = {BancaID:banca,jugado:0,premios:0,desc:campo};
			var i:int; var len:int;
			len = ventas?ventas.length:0;
			for (i = 0; i < len; i++) {
				item = ventas[i];
				if (item.BancaID==banca && item.desc==campo) {
					r.jugado = item.MontoJugado;
				}
			}
			len = premios?premios.length:0;
			for (i = 0; i < len; i++) {
				item = premios[i];
				if (item.BancaID==banca && item.desc==campo) {
					r.premios = item.Premios;
				}
			}
			return r;
		}
		private function buscarModal_close(e:CloseEvent):void {
			reporte = [];
			var cols:String; var fechas:String;
			var ventasGanador:Array; var premiosGanador:Array;
			var ventasTabla:Array; var premiosTabla:Array;
			
			cols = "BancaID, SUM(Monto) MontoJugado";
			fechas = '(Fecha BETWEEN "'+modalBusq.desde.fechaSelecionada+'" AND "'+modalBusq.hasta.fechaSelecionada+'")';
			//ganador
			ventasGanador = Global.ganador.sql('SELECT "Ganador" Reporte, '+cols+' FROM Ventas WHERE '+fechas+' AND eliminado = false AND Devuelto = false GROUP BY BancaID').data;
			if (ventasGanador==null) ventasGanador = [];
			cols = "BancaID, SUM(Premio) Premios";
			premiosGanador = Global.ganador.sql('SELECT "Ganador" Reporte, '+cols+' FROM Premiados WHERE '+fechas+' AND pago = true GROUP BY BancaID').data;
			if (premiosGanador==null) premiosGanador = [];
			//tabla
			cols = "BancaID, SUM(Monto*Cantidad) MontoJugado";
			ventasTabla = Global.tablas.sql('SELECT "Tablas" Reporte, '+cols+' FROM Ventas WHERE '+fechas+' AND eliminado = false AND Devuelto = false GROUP BY BancaID').data;
			if (ventasTabla==null) ventasTabla = [];
			cols = "BancaID, SUM(Premio) Premios";
			premiosTabla = Global.tablas.sql('SELECT "Tablas" Reporte, '+cols+' FROM Premiados WHERE '+fechas+' AND pago = true GROUP BY BancaID').data;
			if (premiosTabla==null) premiosTabla = [];
			
			var bl:int = Global.banca.bancas.bancas.length;
			var bc:VOBanca; 
			var _reportes:Array;
			var banca:Object; var r:Object;
			var i:int;
			for (i = 0; i < bl; i++) {
				bc = Global.banca.bancas.bancas[i];
				_reportes = [];
				banca = bc.toObject;
				_reportes.push(getReporte(bc,ventasGanador,premiosGanador,"Ganador"));
				_reportes.push(getReporte(bc,ventasTabla,premiosTabla,"Tablas"));
				banca.reportes = _reportes;
				reporte.push(banca);
			}
			bl = reporte.length-1;
			_reportes = []; var j:int; var mj:Number;
			for (i = bl; i > -1; i--) {
				_reportes = reporte[i].reportes;
				mj=0;
				for (j=_reportes.length-1;j>-1;j--) {
					mj += _reportes[j].MontoJugado;
				}
				if (mj==0) {
					reporte.splice(i,1);
				}
			}
			
			listReporte.dataProvider = new ArrayList(reporte);
		}
		private function getReporte (banca:VOBanca,ventas:Array,premios:Array,tipo:String):Object {
			var item:Object; var r:Object = {BancaID:banca.ID,Reporte:tipo,Tipo:tipo,MontoJugado:0,Premios:0};
			var i:int; var len:int;
			len = ventas?ventas.length:0;
			for (i = 0; i < len; i++) {
				item = ventas[i];
				if (item.BancaID==banca.ID) {
					r.MontoJugado = item.MontoJugado;
				}
			}
			len = premios?premios.length:0;
			for (i = 0; i < len; i++) {
				item = premios[i];
				if (item.BancaID==banca.ID) {
					r.Premios = item.Premios;
				}
			}
			return r;
		}
		protected function estadisticasClick(event:MouseEvent):void {
			if (modalEstadistica)
				vista.modalPopUp(modalEstadistica);
			else
				ModalOK.show("No hay reporte para visualizar, necesita realizar una busqueda",vista);
		}
		
		protected function imprimirClick(event:MouseEvent):void {
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
				pr.pushLine("REPORTE DE PAGOS",TextAlign.CENTER,new TextFormat("Verdana",26,null,null,null,null,null,null,"center"));
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
		
		protected function cerrarClick(event:MouseEvent):void {
			popBack();
		}
		
		protected function buscarClick(event:MouseEvent):void {
			vista.modalPopUp(modalBusq);
		}
		
		override protected function onRemoved(event:Event):void {
			btnBuscar.removeEventListener(MouseEvent.CLICK,buscarClick);
			btnCerrar.removeEventListener(MouseEvent.CLICK,cerrarClick);
			btnEstadisticas.removeEventListener(MouseEvent.CLICK,estadisticasClick);
			btnImprimir.removeEventListener(MouseEvent.CLICK,imprimirClick);
			super.onRemoved(event);
		}
	}
}