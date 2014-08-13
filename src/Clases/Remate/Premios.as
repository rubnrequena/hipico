package Clases.Remate
{
	import sr.modulo.Modulo;
	
	public class Premios {
		public static const PREMIOS:String = "Premios";
		
		private var s:String;
		
		public function Premios() { }
		
		public function insertarPremio (premio:Object):void {
			Global.remate.insertar(PREMIOS,premio);
		}
		public function eliminar (carrera:Object,bancaID:int):void {
			if (bancaID>0) carrera.BancaID = bancaID;
			Global.remate.eliminar(PREMIOS,carrera);
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.remate.sql(Modulo.buildSelect(PREMIOS,columnas,campos,agrupar,ordenar)).data; 
		}
		public function leerFH (fecha:String,hipodromo:String="",banca:int=0,taquilla:String=null,agrupar:String=null,columnas:String="*"):Array {
			s = 'SELECT '+columnas+' FROM '+PREMIOS+' WHERE FHC LIKE "'+Modulo.fhc(fecha,hipodromo)+'%"';
			if (banca>0)
				s += ' AND BancaID = '+banca;
			if (taquilla)
				s += ' AND Taquilla = "'+taquilla+'"';
			if (agrupar)
				s += ' GROUP BY '+agrupar;
			return Global.remate.sql(s).data;
		}
	}
}