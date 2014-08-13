package Clases.Ganador
{
	import sr.modulo.Modulo;

	public class Topes
	{
		public static const TOPES:String = "Topes";
		
		public function Topes() {
			Global.ganador.sql('SELECT * FROM '+TOPES);
		}
		
		private var _numTopes:int;
		public function get numTopes():int { return _numTopes; }
		
		private var _topes:Array;
		public function get topes():Array { return _topes; }

		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null):Array {
			return Global.ganador.sql(Modulo.buildSelect(TOPES,columnas,campos,agrupar,ordenar)).data;
		}
		public function modificar (set:Object,where:Object):void {
			Global.ganador.actualizar(TOPES,set,where);
		}
		
		public function insertar (campos:Object):void {
			Global.ganador.insertar(TOPES,campos);
			_numTopes++;
		}
		public function remover (id:int,hipo:String):void {
			Global.ganador.eliminar(TOPES,{topeId:id,hipodromo:hipo});
			_numTopes--;
		}
	}
}