package Clases
{
	import Clases.Banca.VOBanca;
	
	import mx.collections.ArrayList;

	public class Macuare
	{
		public function Macuare()
		{
		}
		/*static public function macuares(fecha:String,descripcion:String=null):Array {
			var descripcion:String = descripcion?" AND descripcion = '"+descripcion+"'":"";
			return Global.db.LeerComando2("SELECT * FROM Macuare JOIN Macuare_Datos ON Macuare.macuareId = Macuare_Datos.macuareId WHERE fecha = '"+fecha+"'"+descripcion).data;
		}
		
		static public function macuares_ventas(fecha:String,hipodromo:String,banca:int,taquilla:String=null):Array {
			var s:Sentencia = new Sentencia("Macuare_Ventas");
			var m:Object = new Object();
			m.eliminado = false;
			m.fecha = fecha;
			m.hipodromo = hipodromo;
			m.bancaID = banca;
			if (taquilla) m.taquilla = taquilla;
			s.where = [m];
			return Global.db.Leer_Multi2(s).toArray();
		}
		
		static public function macuares_venta(fecha:String,hipodromo:String,banca:int,taquilla:String,combinacion:String=null):Number {
			var ventas:Array = macuares_ventas(fecha,hipodromo,banca,taquilla); var total:Number=0; var i:int;
			if (combinacion) {
				for (i = 0; i < ventas.length; i++) { if (combinacion==ventas[i].ejemplares) total+=ventas[i].monto; }
			} else {
				for (i = 0; i < ventas.length; i++) { total+=ventas[i].monto; }
			}
			return total;
		}
		
		static public function validar_tope_combinacion(ticket:Object):Boolean {
			var venta:Number = macuares_venta(ticket.fecha,ticket.hipodromo,ticket.bancaID,ticket.taquilla,ticket.ejemplares)+Number(ticket.monto);
			var bnc:VOBanca = Global.banca.bancas.bancaByID(ticket.bancaID);
			return venta<bnc.macuare_tope?true:false;
		}
		
		static public function get chances():Array {
			return Global.db.Leer("Macuare_Chances").toArray();
		}
		static public function set chances(value:Array):void {
			Global.db.Modificar("Macuare_Chances",[{minimo:value[1],maximo:value[2]}],[{chance:value[0]}],"AND");
		}
		static public function hipodromosCarrera(fecha:String):ArrayList {
			return new ArrayList(Global.db.LeerComando2("SELECT * FROM Macuare WHERE fecha = '"+fecha+"'").data);
		}*/
	}
}