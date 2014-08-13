package Clases.Tabla
{
	import sr.modulo.Modulo;

	public class Ventas
	{
		public static const VENTAS:String = "Ventas";

		private var s:String;
		public function Ventas() {
			
		}
		 
		public function insertar(ventas:Array):Array {
			var i:int; var ventaID:int = Global.tablas.sistema.ventaID++;
			for (i = 0; i < ventas.length; i++) { 
				ventas[i].VentaID = ventaID;
				ventas[i].pago = false;
			}
			Global.tablas.insertarUnion(VENTAS,ventas);
			return ventas;
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			s = 'SELECT '+columnas+' FROM '+VENTAS+' WHERE ';
			var cc:Array = new Array;
			if (campos) {
				for (var c:String in campos) {
					cc.push(c+' = '+Modulo.formatString(campos[c]));
				}
			}
			s += cc.join(" AND ");
			if (agrupar) s += ' GROUP BY '+agrupar;
			if (ordenar) s += ' ORDER BY '+ordenar; 
			return Global.tablas.sql(s).data;
		}
		public function leerVentasTaquilla (fecha:String,hipodromo:String,carrera:int,banca:int,taquilla:String,agrupar:String=null,campos:Object=null,columnas:String="*"):Array {
			fecha=fecha.split("-").join("");
			s = 'SELECT '+columnas+' FROM '+VENTAS+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'" AND Taquilla = "'+taquilla+'"';
			if (banca>0) 
				s += ' AND BancaID = '+banca.toString();
			if (campos) {
				for (var c:String in campos) {
					s += ' AND '+c+' = '+Modulo.normalize(campos[c]);
				}
			}
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			return Global.tablas.sql(s).data;
		}
		public function leerVentasBanca (fecha:String,hipodromo:String,carrera:int,banca:int,agrupar:String=null,campos:Object=null,columnas:String="*"):Array {
			fecha=fecha.split("-").join("");
			s = 'SELECT '+columnas+' FROM '+VENTAS+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'"';
			if (banca>0) 
				s += ' AND BancaID = '+banca.toString();
			if (campos) {
				for (var c:String in campos) {
					s += ' AND '+c+' = '+Modulo.normalize(campos[c]);
				}
			}
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			return Global.tablas.sql(s).data;
		}
		public function leerVentasCarrera (fecha:String,hipodromo:String,carrera:int,agrupar:String=null,orden:String=null,campos:Object=null,columnas:String="*"):Array {
			fecha=fecha.split("-").join("");
			s = 'SELECT '+columnas+' FROM '+VENTAS+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'"';
			if (campos) {
				for (var c:String in campos) {
					s += ' AND '+c+' = '+Modulo.normalize(campos[c]);
				}
			}
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			if (orden)
				s += ' ORDER BY '+orden;
			return Global.tablas.sql(s).data;
		}
		public function leerVentasCarreraAgrupada (fhc:String):Array {
			return Global.tablas.sql('SELECT *, SUM(Monto) Monto, SUM(Cantidad) Cantidad FROM (SELECT BancaID,Numero, Nombre, SUM(Cantidad) Cantidad, (Monto*SUM(Cantidad)) Monto FROM Ventas WHERE FHC = "'+fhc+'" AND Eliminado = false AND Retirado = false GROUP BY BancaID,Numero ORDER BY Numero ASC) GROUP BY Numero').data;
		}
		public function eliminarTickets (tickets:Array,eliminado:Boolean):void {
			for (var i:int = 0; i < tickets.length; i++) {
				Global.tablas.actualizar(VENTAS,{Eliminado:eliminado},{VentaID:tickets[i].VentaID});	
			}
		}
		public function retirarEjemplar(fhc:String,numero:int,retirado:Boolean):void {
			Global.tablas.actualizar(VENTAS,{Retirado:retirado},{FHC:fhc,Numero:numero});
		}
	}
}