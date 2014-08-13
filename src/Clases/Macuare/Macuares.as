package Clases.Macuare
{
	import sr.modulo.Modulo;

	public class Macuares
	{	
		public function Macuares() {
			
		}
		
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null,itemClass:Class=null):Array {
			return Global.macuare.sql(Modulo.buildSelect(Macuare.MACUARES,columnas,campos,agrupar,ordenar),itemClass).data;
		}
		public function leerMacuare (fecha:String,hipodromo:String,itemClass:Class=null):Array {
			return Global.macuare.sql('SELECT * FROM '+Macuare.MACUARES+' JOIN '+Macuare.CARRERAS+' ON Macuares.macuareId = Carreras.macuareId WHERE fecha = "'+fecha+'" AND Hipodromo = "'+hipodromo+'"').data;
		}
		public function insertar (macuare:Object):int {
			return Global.macuare.insertar(Macuare.MACUARES,macuare).lastInsertRowID;
		}
		public function eliminar(id:int):void {
			Global.macuare.eliminar(Macuare.MACUARES,{macuareId:id});
			Global.macuare.eliminar(Macuare.CARRERAS,{macuareId:id});
		}
	}
}