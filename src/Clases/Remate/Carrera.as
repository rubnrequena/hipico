package Clases.Remate
{
	import sr.modulo.Modulo;
	
	import flash.data.SQLStatement;
	
	public class Carrera {
		public static const CARRERA:String = "Carreras";
		
		public function Carrera() {
		}
		public function insertar (carreras:Array):void {
			Global.remate.insertarUnion(CARRERA,carreras);
		}
		public function eliminar (campos:Object):void {
			Global.remate.sql(Modulo.buildDelete(CARRERA,campos));		
		}
		public function leer (fecha:String,hipodromo:String,carrera:int,banca:int=0):Array {
			fecha=fecha.split("-").join("");
			var s:String = 'SELECT * FROM '+CARRERA+' WHERE FHC = "'+Modulo.fhc(fecha,hipodromo,carrera)+'"';
			if (banca>0)  s += ' AND BancaID = '+banca.toString();
			s+= ' ORDER BY Numero';
			return Global.remate.sql(s).data;
		}
		public function leer2 (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String="Numero ASC"):Array {
			return Global.remate.sql(Modulo.buildSelect(CARRERA,columnas,campos,agrupar,ordenar)).data;
		}
		public function retirarEjemplar(fhc:String,numero:int,retirado:Boolean):void {
			Global.remate.actualizar(CARRERA,{Retirado:retirado},{FHC:fhc,Numero:numero});
		}
		public function bloquearEjemplar(fhc:String,numero:int,bloqueado:Boolean,banca:int=0):void {
			var where:Object = {FHC:fhc,Numero:numero};
			if (banca>0) where.BancaID = banca;
			Global.remate.actualizar(CARRERA,{Bloqueado:bloqueado},where);
		}
	}
}