package Clases.Macuare
{
	import mx.controls.Alert;
	
	import sr.modulo.Modulo;

	public class Ventas
	{
		static private const VENTAS:String = "Ventas";
		
		public function Ventas()
		{
		}
		public function leer (campos:Object,columnas:String="*",agrupar:String=null,ordenar:String=null,itemClass:Class=null):Array {
			return Global.macuare.sql(Modulo.buildSelect(Macuare.VENTAS,columnas,campos,agrupar,ordenar),itemClass).data;
		}
		public function insertar (venta:Object):Object {
			venta.ticket.VentaId = Global.macuare.sistema.ventaID++;
			venta.ticket.pago = false;
			
			Global.macuare.insertar(VENTAS,venta.ticket);
			return venta;
		}
		public function eliminar(ticket:int):Number {
			return Global.macuare.sql('UPDATE Ventas SET eliminado = true WHERE VentaId = '+ticket).rowsAffected;
		}
	}
}