package Clases.Macuare
{
	import sr.modulo.Modulo;

	public class Ganadores
	{
		public function Ganadores()
		{
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null,itemClass:Class=null):Array {
			return Global.macuare.sql(Modulo.buildSelect(Macuare.GANADORES,columnas,campos,agrupar,ordenar),itemClass).data;
		}
	}
}