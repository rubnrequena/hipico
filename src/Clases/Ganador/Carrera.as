package Clases.Ganador
{
	import sr.modulo.Modulo;
	
	import flash.data.SQLStatement;

	public class Carrera
	{
		public static const CARRERA:String = "Carreras";
		
		public function Carrera() {
			
		}
		public function insertar (carreras:Array):void {
			Global.ganador.insertarUnion(CARRERA,carreras);
		}
		public function eliminar (campos:Object):void {
			Global.ganador.sql(Modulo.buildDelete(CARRERA,campos));		
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.ganador.sql(Modulo.buildSelect(CARRERA,columnas,campos,agrupar,ordenar)).data;
		}
		public function retirarEjemplar(fhc:String,numero:int,retirado:Boolean):void {
			Global.ganador.actualizar(CARRERA,{Retirado:retirado},{FHC:fhc,Numero:numero});
		}
		public function bloquearEjemplar(fhc:String,numero:int,bloqueado:Boolean,banca:int=0):void {
			var where:Object = {FHC:fhc,Numero:numero};
			if (banca>0) where.BancaID = banca;
			Global.ganador.actualizar(CARRERA,{Bloqueado:bloqueado},where);
		}
	}
}