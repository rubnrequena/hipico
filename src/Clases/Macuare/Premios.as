package Clases.Macuare
{
	import sr.modulo.Modulo;

	public class Premios
	{
		public function Premios()
		{
		}
		
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null,itemClass:Class=null):Array {
			return Global.macuare.sql(Modulo.buildSelect(Macuare.PREMIOS,columnas,campos,agrupar,ordenar),itemClass).data;
		}
		public function premiados (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null,itemClass:Class=null):Array {
			return Global.macuare.sql(Modulo.buildSelect(Macuare.PREMIADOS,columnas,campos,agrupar,ordenar),itemClass).data;
		}
		public function eliminarPremios(fecha:String,hipodromo:String):void {
			Global.macuare.sql('DELETE FROM '+Macuare.PREMIOS+' WHERE fecha = "'+fecha+'" AND hipodromo = "'+hipodromo+'"');
			Global.macuare.sql('DELETE FROM '+Macuare.PREMIADOS+' WHERE fecha = "'+fecha+'" AND hipodromo = "'+hipodromo+'"');
		}
	}
}