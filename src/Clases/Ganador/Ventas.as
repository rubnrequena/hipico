package Clases.Ganador
{
	import sr.modulo.Modulo;

	public class Ventas
	{
		public static const VENTAS:String = "Ventas";

		private var s:String;
		public function Ventas() {
			
		}
		public function insertar(ventas:Array):Array {
			var i:int; var ventaID:int = Global.ganador.sistema.ventaID;
			for (i = 0; i < ventas.length; i++) { 
				ventas[i].VentaID = ventaID;
				ventas[i].pago = false;
			}
			Global.ganador.insertarUnion(VENTAS,ventas);
			return ventas;
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null,itemClass:Class=null):Array {
			return Global.ganador.sql(Modulo.buildSelect(VENTAS,columnas,campos,agrupar,ordenar),itemClass).data;
		}
		public function leerVentas (campos:Object,columnas:String="*",agrupar:String="",ordernar:String="*",itemClass:Class=null):Array {
			return Global.ganador.sql(Modulo.buildSelect(VENTAS,"SUM(Monto),Numero,Carrera",campos,"Numero","Numero ASC")).data;
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
			return Global.ganador.sql(s).data;
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
			return Global.ganador.sql(s).data;
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
			return Global.ganador.sql(s).data;
		}
		public function eliminarTickets (tickets:Array,eliminado:Boolean):void {
			for (var i:int = 0; i < tickets.length; i++) {
				Global.ganador.actualizar(VENTAS,{Eliminado:eliminado},{VentaID:tickets[i].VentaID});	
			}
		}
		public function retirarEjemplar(fhc:String,numero:int,retirado:Boolean):void {
			Global.ganador.actualizar(VENTAS,{Retirado:retirado},{FHC:fhc,Numero:numero});
		}
	}
}