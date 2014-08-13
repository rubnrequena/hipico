package Clases.Tabla
{
	import VOs.VOCarrera;
	import VOs.VOEjemplar;
	import VOs.VOTablaPremio;
	
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	
	import mx.controls.Alert;
	
	import sr.modulo.Modulo;

	public class Premios
	{
		public static const PREMIOS:String = "Premios";
		public static const PREMIADOS:String = "Premiados";

		private var s:String;
		
		public function Premios() { }
		
		public function guardar (premios:Array):void {
			Global.tablas.insertarUnion(PREMIOS,premios);
		}
		public function premiados (fhc:String,banca:int,taquilla:String=null):Array {
			taquilla = taquilla?'Premiados.Taquilla = "'+taquilla+'" AND ':'';
			return Global.tablas.sql('SELECT "Tabla" Tipo, Premiados.FHC,Taquilla,Numero,Nombre,Monto,Cantidad,VentaID,Hora,pago,Paga,(cantidad*Paga) Premio FROM Premiados ' +
				'JOIN Tablas_Padre ON Premiados.FHC = Tablas_Padre.FHC AND Premiados.BancaID = Tablas_Padre.BancaID ' +
				'WHERE '+taquilla+'Premiados.BancaID = '+banca+' AND Premiados.FHC = "'+fhc+'"').data;
		}
		public function ticketsPremiados (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.tablas.sql(Modulo.buildSelect(PREMIADOS,columnas,campos,agrupar,ordenar)).data; 
		}
		public function marcarPagado (ventaID:int):void {
			Global.tablas.actualizar(PREMIADOS,{pago:true},{VentaID:ventaID});
		}
		public function insertar (montoJugado:Number,premios:Number,banca:int,taquilla:String,fecha:String,hipodromo:String,carrera:int):void {
			Global.tablas.insertar(PREMIOS,{Taquilla:taquilla,MontoJugado:montoJugado,Premios:premios,BancaID:banca,Fecha:fecha,Hipodromo:hipodromo,Carrera:carrera,FHC:Modulo.fhc(fecha,hipodromo,carrera)});
		}
		public function eliminar (carrera:Object,bancaID:int):void {
			if (bancaID>0) carrera.BancaID = bancaID;
			Global.tablas.eliminar(PREMIOS,carrera);
			Global.tablas.eliminar(PREMIADOS,carrera);
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.tablas.sql(Modulo.buildSelect(PREMIOS,columnas,campos,agrupar,ordenar)).data; 
		}
		public function leerFH (fecha:String,hipodromo:String="",banca:int=0,taquilla:String=null,agrupar:String=null,columnas:String="*"):Array {
			s = 'SELECT '+columnas+' FROM '+PREMIOS+' WHERE FHC LIKE "'+Modulo.fhc(fecha,hipodromo)+'%"';
			if (banca>0)
				s += ' AND BancaID = '+banca;
			if (taquilla)
				s += ' AND Taquilla = "'+taquilla+'"';
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			return Global.tablas.sql(s).data;
		}
		public function premiar (bancas:Vector.<int>,carrera:VOCarrera,ganadores:Vector.<VOEjemplar>):void {
			var tt:int = getTimer();
			var tts:Vector.<int> = new Vector.<int>;
			var len:int; var len2:int;
			var i:int; var j:int; var k:int; var c:int;
			var o:Object;
			var _string:String;
			var _array:Array;
			//SQL: filtrar bancas statement
			_array = [];
			len = bancas.length;
			for (i = 0; i < len; i++) {
				_array.push("BancaID = "+bancas[i]);	
			}
			_string = _array.join(" OR ");
			_array.length=0;
			//SQL: leer ventas
			_array = Global.tablas.sql('SELECT VentaID,FHC,Fecha,Hora,Hipodromo,Carrera,Nombre,Numero,Monto,Cantidad,Taquilla,Retirado,Eliminado,pago,BancaID FROM Ventas ' +
				'WHERE FHC = "'+carrera.FHC+'" ' +
				'AND Eliminado = false AND Retirado = false '+
				'AND ('+_string+') ORDER BY BancaID, Taquilla').data;
			
			//separar taquillas
			var taquillas:Vector.<VOTablaPremio> = new Vector.<VOTablaPremio>
			len = _array?_array.length-1:-1;
			for (i = len; i > -1; --i) {
				o = _array[i];
				if (addTaquilla(taquillas,o)) {
					taquillas.push(new VOTablaPremio(o.BancaID,o.Taquilla,o));
				}
			}
			//remover no ganadores
			len = taquillas.length;
			for (i=0;i<len;i++) {
				_array = taquillas[i].ventas;
				len2 = _array.length-1;
				for (j=len2;j>-1;j--) {
					o=_array[j];
					c=0;
					for (k=0;k<ganadores.length;k++) {
						if (int(o.Numero)!=ganadores[k].numero) { c++; }
					}
					if (c==ganadores.length) { _array.splice(j,1); }
				}
			}
			//asignar ejemplares ganadores
			trace("len",_array.length);
			_array = [];
			len2 = ganadores.length;
			_string = carrera.FHC;
			for (i=0;i<len2;i++) {
				o = ganadores[i].toObject;
				o.FHC = _string;
				o.Fecha = carrera.fecha;
				o.Hipodromo = carrera.hipodromo;
				o.Carrera = carrera.carrera;
				_array.push(o);
			}
			for (i=0;i<len;i++) {
				taquillas[i].ganadores = _array;
			}
			//asignar info tabla
			_array = Global.tablas.sql('SELECT * FROM Tablas_Padre WHERE FHC = "'+carrera.FHC+'"',VOTablas_Padre).data;
			var tp:VOTablas_Padre;
			len = taquillas.length;
			len2 = _array?_array.length:0;
			for (i=0;i<len;i++) {
				for (j=0;j<len2;j++) {
					tp = _array[j] as VOTablas_Padre;
					if (taquillas[i].banca==tp.BancaID) {
						taquillas[i].tablaPaga = tp.Paga;
					}
				}
			}
			//asignar premios
			var taq:VOTablaPremio;
			for (i = 0; i < len; i++) {
				taq = taquillas[i];
				len2 = taq.ventas.length;
				for (j=0;j<len2;j++) {
					o = taq.ventas[j];
					o.Premio = o.Cantidad*taq.tablaPaga;
					taquillas[i].premio += o.Premio;
				}
			}
			//ganadores
			_array = new Array(bancas.length*ganadores.length);
			k=0;
			len = bancas.length;
			len2 = ganadores.length;
			for (i=0;i<len;i++) {
				for (j=0;j<len2;j++) {
					o = ganadores[j].toObject;
					o.FHC = _string;
					o.Fecha = carrera.fecha;
					o.Hipodromo = carrera.hipodromo;
					o.Carrera = carrera.carrera;
					o.BancaID = bancas[i];
					_array[k] = o;
					k++;
				}
			}
			if (_array.length>0)
				Global.tablas.insertarUnion("Ganadores",_array);
			
			//todos los premiados
			_array.length=0;
			len = taquillas.length;
			for (i=0;i<len;i++) {
				_array = _array.concat(taquillas[i].ventas);
			}
			if (_array.length>0)
				Global.tablas.insertarUnion("Premiados",_array);
			//premios
			_array = new Array(len);
			for (i=0;i<len;i++) {
				o = {};
				o.BancaID = taquillas[i].banca;
				o.Taquilla = taquillas[i].taquilla;
				o.FHC = _string;
				o.Fecha = carrera.fecha;
				o.Hipodromo = carrera.hipodromo;
				o.Carrera = carrera.carrera;
				o.MontoJugado = taquillas[i].jugado;
				o.Premios = taquillas[i].premio;
				_array[i] = o;
			}
			if (_array.length>0)
			Global.tablas.insertarUnion("Premios",_array);
			len = taquillas.length-1;
			for (i = len; i > -1; --i) {
				taq = taquillas[i];
				o = {jugado:taq.jugado,premios:taq.premio,paga:taq.tablaPaga};
				Global.net.tabla.premios_enviar(carrera.toDB,taquillas[i].ganadores,taq.ventas,o,taq.banca,taq.taquilla);
			}
		}
		
		private function addTaquilla(taquillas:Vector.<VOTablaPremio>,venta:Object):Boolean {
			var j:int; var len:int = taquillas.length;
			for (j = 0; j < len; j++) {
				if (venta.BancaID==taquillas[j].banca && venta.Taquilla==taquillas[j].taquilla) {
					taquillas[j].addVenta(venta); return false;
				}
			}
			return true;
		}
	}
}