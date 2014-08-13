package Clases.Ganador
{
	import VOs.VOCarrera;
	import VOs.VOEjemplar;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import sr.modulo.Modulo;

	public class Premios
	{
		public static const PREMIOS:String = "Premios";
		public static const PREMIADOS:String = "Premiados";

		private var s:String;
		
		public function Premios() { }
		
		public function premiados (fhc:String,banca:int,taquilla:String=null,r:String='"Ganador" Tipo,'):Array {
			taquilla = taquilla?' AND Premiados.Taquilla = "'+taquilla+'"':'';
			var h:String = fhc.substring(8,fhc.length-2);
			var div:int = Global.banca.hipodromos.ganador(h);
			return Global.ganador.sql('SELECT '+r+' Premiados.Taquilla, Premiados.VentaID, Premiados.Hora, Premiados.FHC,Premiados.Nombre, Premiados.Numero, Premiados.Monto, (Premiados.Monto/'+div+' * Ganadores.Paga) Premio, Premiados.pago FROM Premiados JOIN Ganadores ON Ganadores.FHC = Premiados.FHC AND Ganadores.Numero = Premiados.Numero WHERE Premiados.FHC = "'+fhc+'" AND Premiados.BancaID = '+banca+taquilla+'  AND Ganadores.BancaID = '+banca).data;
		}
		public function ticketsPremiados (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.ganador.sql(Modulo.buildSelect(PREMIADOS,columnas,campos,agrupar,ordenar)).data;
		}
		public function marcarPagado (ventaID:int):void {
			Global.ganador.actualizar(PREMIADOS,{pago:true},{VentaID:ventaID});
		}
		public function insertar (montoJugado:Number,premios:Number,banca:int,taquilla:String,fecha:String,hipodromo:String,carrera:int):void {
			Global.ganador.insertar(PREMIOS,{Taquilla:taquilla,MontoJugado:montoJugado,Premios:premios,BancaID:banca,Fecha:fecha,Hipodromo:hipodromo,Carrera:carrera,FHC:Modulo.fhc(fecha,hipodromo,carrera)});
		}
		public function guardar (premios:Array):void {
			Global.ganador.insertarUnion(PREMIOS,premios);
		}
		public function eliminar (carrera:Object,bancaID:int):void {
			if (bancaID>0) carrera.BancaID = bancaID;
			Global.ganador.eliminar(PREMIOS,carrera);
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.ganador.sql(Modulo.buildSelect(PREMIOS,columnas,campos,agrupar,ordenar)).data; 
		}
		public function leerFHC (fecha:String,hipodromo:String="",carrera:int=0,banca:int=0,taquilla:String=null,agrupar:String=null,columnas:String="*"):Array {
			s = 'SELECT '+columnas+' FROM '+PREMIOS+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'"';
			if (banca>0)
				s += ' AND BancaID = '+banca;
			if (taquilla)
				
				s += ' AND Taquilla = "'+taquilla+'"';
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			return Global.ganador.sql(s).data;
		}
		public function leerFH (fecha:String,hipodromo:String="",banca:int=0,taquilla:String=null,agrupar:String=null,columnas:String="*"):Array {
			s = 'SELECT '+columnas+' FROM '+PREMIOS+' WHERE FHC LIKE "'+Modulo.fhc(fecha,hipodromo)+'%"';
			if (banca>0)
				s += ' AND BancaID = '+banca;
			if (taquilla)
				
				s += ' AND Taquilla = "'+taquilla+'"';
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			return Global.ganador.sql(s).data;
		}
		public function enviarPremios(carrera:Object,ganadores:Array,tickets:Array,bancaID:int,taquilla:String,jugado:Number,premios:Number):void {
			Global.net.ganador.premios_enviar(carrera,ganadores,tickets,bancaID,taquilla,jugado,premios);
		}
		public function premiar(dividendos:Vector.<VOPremiar>,carrera:VOCarrera,ganadores:Vector.<VOEjemplar>,dividendo:Number):void {
			var t:uint = getTimer();
			var len:int; var len2:int; var i:int; var j:int;
			var _array:Array; var _ventas:Vector.<VentasTaquilla>;
			var _string:String;
			len = dividendos.length;
			_array=[];
			for (i = 0; i < len; i++) { _array.push("BancaID = "+dividendos[i].banca); }
			_string = _array.join(" OR "); // bancas
			// ventas
			_array = Global.ganador.sql('SELECT * FROM Ventas WHERE FHC = "'+carrera.FHC+'" ' +
				'AND Eliminado = false AND Retirado = false '+
				'AND ('+_string+') ORDER BY BancaID, Taquilla').data;
			
			_ventas = new Vector.<VentasTaquilla>;
			var venta:VentasTaquilla;
			venta = new VentasTaquilla;
			if (_array) {
			venta.banca = _array[0].BancaID;
			venta.taquilla = _array[0].Taquilla;
			venta.ventas = [_array[0]];
			_ventas.push(venta);
			}
			var indice:int; len = _array?_array.length:0;
			for (i = 1; i < len; i++) {
				indice = indiceTaquilla(_array[i].BancaID,_array[i].Taquilla,_ventas);
				if (indice>-1) {
					_ventas[indice].ventas.push(_array[i]);
				} else {
					venta = new VentasTaquilla;
					venta.banca = _array[i].BancaID;
					venta.taquilla = _array[i].Taquilla;
					venta.ventas = [_array[i]];
					_ventas.push(venta);
				}
			}
			len = _ventas.length;
			var _premiados:Array = [];
			var _premios:Array = [];
			var _ganadores:Array = [];
			
			for (i = 0; i < len; i++) {
				_ventas[i].data(dividendos,dividendo,carrera)
				_premios.push(_ventas[i].premio);
				_premiados = _premiados.concat(_ventas[i].premiados);
			}
			
			len = dividendos.length;
			_ganadores = []; var _obj:Object;
			for (i = 0; i < len; i++) {
				len2 = dividendos[i].dividendos.length;
				for (j = 0; j < len2; j++) {
					_obj = carrera.toDB;
					_obj.FHC = carrera.FHC;
					_obj.BancaID = dividendos[i].banca;
					_obj.Paga = dividendos[i].dividendos[j].dividendo;
					_obj.Numero = dividendos[i].dividendos[j].numero;
					_obj.Nombre = dividendos[i].dividendos[j].ejemplar;
					_ganadores.push(_obj);
				}
			}
			if (_ganadores.length>0)
				Global.ganador.insertarUnion("Ganadores",_ganadores);
			if (_premiados.length>0)
				Global.ganador.insertarUnion("Premiados",_premiados);
			if (_premios.length>0)
				Global.ganador.insertarUnion("Premios",_premios);
			len = _ventas.length;
			_obj = carrera.toDB;
			for (i = 0; i < len; i++) {
				Global.net.ganador.premios_enviar(_obj,ganadoresBanca(_ventas[i].banca,_ganadores),_ventas[i].premiados,_ventas[i].banca,_ventas[i].taquilla,_ventas[i].jugado,_ventas[i].premios);
			}
			//dispose
			_ventas=null;
			_array=_premiados=_premios=_ganadores=null;
			venta=null;
		}
		public function ganadoresBanca(banca:int,ganadores:Array):Array {
			var a:Array = []; var i:int;
			for (i = 0; i < ganadores.length; i++) {
				if (ganadores[i].BancaID==banca) {
					a.push(ganadores[i]);
				}
			}
			return a;
		}
		public function indiceTaquilla (banca:int,taq:String,ventas:Vector.<VentasTaquilla>):int {
			var i:int;
			for (i=0; i<ventas.length; i++) {
				if (banca==ventas[i].banca && taq==ventas[i].taquilla) { return i; }
			}
			return -1;
		}
	}
}
import Clases.Ganador.VOPremiar;

import VOs.VOCarrera;
import VOs.VODividendo;

class VentasTaquilla {
	public var taquilla:String;
	public var banca:int;
	public var ventas:Array;
	public var premiados:Array;
	public var premio:Object;
	
	public var jugado:Number;
	public var premios:Number;
	
	public function data (dividendos:Vector.<VOPremiar>,dividendo:int,carrera:VOCarrera):Object {
		//dividendos
		var i:int; var l:int;
		var _dividendos:Vector.<VODividendo>;  
		l = dividendos.length;
		for (i = 0; i < l; i++) {
			if (dividendos[i].banca==banca) { _dividendos = dividendos[i].dividendos; break; }
		}
		//premiados
		_premiados(_dividendos,dividendo);
		//premio
		premio = carrera.toDB;
		premio.FHC = carrera.FHC;
		premio.Taquilla = taquilla;
		premio.BancaID = banca;
		premio.MontoJugado = jugado;
		premio.Premios = 0;
		for (i = 0; i < premiados.length; i++) {
			premio.Premios += premiados[i].Premio;
		}
		return premio;
	}
	public function _premiados(dividendos:Vector.<VODividendo>,dividendo:int):void {
		var i:int; var li:int;
		var d:int; var ld:int;
		premiados = []; var venta:Object;
		li = ventas.length; ld = dividendos.length;
		jugado=0; premios=0;
		for (i = 0; i < li; i++) {
			jugado+=ventas[i].Monto;
			for (d = 0; d < ld; d++) {
				if (ventas[i].Numero==dividendos[d].numero) {
					venta = ventas[i];
					venta.Premio = (venta.Monto/dividendo)*dividendos[d].dividendo;
					delete venta.Devuelto;
					premiados.push(venta); 
					premios += venta.Premio;
				}
			}
		}
	}
}