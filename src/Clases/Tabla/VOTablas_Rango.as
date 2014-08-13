package Clases.Tabla
{
	import sr.modulo.MapObject;
	
	public class VOTablas_Rango extends MapObject
	{
		public var RangoID:int;
		public var Minimo:int;
		public var Maximo:int;
		public var Tablas:int;
		
		public function VOTablas_Rango()
		{
			super();
		}
		
		public function match(valor:int):Boolean {
			if (valor>=Minimo && valor<=Maximo) return true;
			return false;
		}
	}
}