package Clases.Tabla
{
	import sr.modulo.Modulo;
	
	import flash.data.SQLStatement;

	public class Tablas
	{
		public static const TABLAS:String = "Tablas";
		
		public function Tablas() {
		}
		public function insertar (carreras:Array):void {
			Global.tablas.insertarUnion(TABLAS,carreras);
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.tablas.sql(Modulo.buildSelect(TABLAS,columnas,campos,agrupar,ordenar)).data;
		}
		public function retirarEjemplar(fhc:String,numero:int,retirado:Boolean):void {
			Global.tablas.actualizar(TABLAS,{Retirado:retirado},{FHC:fhc,Numero:numero});
		}
		public function bloquearEjemplar(fhc:String,numero:int,bloqueado:Boolean,banca:int=0):void {
			var where:Object = {FHC:fhc,Numero:numero};
			if (banca>0) where.BancaID = banca;
			Global.tablas.actualizar(TABLAS,{Bloqueado:bloqueado},where);
		}
	}
}