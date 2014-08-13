package Comps.verJugadas.Tablas
{
	import SQLite.vo.Sentencia;
	
	import Clases.Tabla.VOTablas_Rango;
	
	import libVOs.Tablas;
	
	import mx.collections.ArrayList;

	public class Tablas_Rangos
	{
		private var rangos:Array;
		public function Tablas_Rangos()
		{
			var s:Sentencia = new Sentencia(libVOs.Tablas.tablasRangos);
			s.itemClass = VOTablas_Rango;
			rangos = Global.db.Leer2(s).toArray();
		}
		
		public function get activo():Boolean {
			return rangos.length>0?true:false;
		}
		public function aplicar (tablas:ArrayList):ArrayList {
			for (var i:int = 0; i < tablas.length; i++) {
				tablas.getItemAt(i).Cantidad = getValor(tablas.getItemAt(i).Monto);
			}
			return tablas;
		}
		
		private function getValor(valor:int):int {
			var rango:VOTablas_Rango;
			for each (rango in rangos) {
				if (rango.match(valor)) return rango.tablas;	
			}
			return 0;
		}
	}
}