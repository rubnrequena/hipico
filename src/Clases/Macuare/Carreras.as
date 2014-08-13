package Clases.Macuare
{
	import sr.modulo.Modulo;

	public class Carreras
	{
		public function Carreras()
		{
		}
		
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null,itemClass:Class=null):Array {
			return Global.macuare.sql(Modulo.buildSelect(Macuare.CARRERAS,columnas,campos,agrupar,ordenar,"AND")).data;
		}
		public function insertar (datos:Array):void {
			Global.macuare.insertarUnion(Macuare.CARRERAS,datos);
		}
		public function status(macuare:int,status:Boolean):void {
			Global.macuare.actualizar(Macuare.CARRERAS,{abierta:status},{mDatoId:macuare});
		}
	}
}