package Clases.Tabla
{
	import flash.data.SQLResult;
	
	import mx.collections.ArrayList;

	public class Tablas_Rangos
	{
		static public const TABLAS_RANGOS:String = "Tablas_Rangos";
		
		public function Tablas_Rangos() {
			_rangos = Global.tablas.sql('SELECT * FROM '+TABLAS_RANGOS,VOTablas_Rango).data;
			_numRangos = _rangos?_rangos.length:0;
		}
		private var _numRangos:int;
		public function get numRangos():int { return _numRangos; }
		
		private var _rangos:Array;
		public function get rangos():Array { return _rangos; }
		
		public function get activo():Boolean { return _numRangos>0; }
		
		public function aplicar (tablas:ArrayList):ArrayList {
			for (var i:int = 0; i < tablas.length; i++) {
				tablas.getItemAt(i).Tablas = getValor(tablas.getItemAt(i).Monto);
				tablas.getItemAt(i).Cantidad = getValor(tablas.getItemAt(i).Monto);
			}
			return tablas;
		}		
		private function getValor(valor:int):int {
			var rango:VOTablas_Rango;
			for each (rango in _rangos) {
				if (rango.match(valor)) return rango.Tablas;	
			}
			return 0;
		}

		public function insertar (minimo:int,maximo:int,tablas:int):int {
			var r:SQLResult = Global.tablas.insertar(TABLAS_RANGOS,{Minimo:minimo,Maximo:maximo,Tablas:tablas});
			if (r.rowsAffected>0) _numRangos++;
			return r.lastInsertRowID;
		}
		public function remover (rangoId:int):void {
			if (Global.tablas.eliminar(TABLAS_RANGOS,{RangoID:rangoId}).rowsAffected>0) _numRangos--;
		}

	}
}