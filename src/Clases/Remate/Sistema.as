package Clases.Remate
{
	public class Sistema
	{
		public static const SISTEMA:String = "Sistema";
		
		public function Sistema() {
			_ventaID =Global.remate.sql('SELECT * FROM '+SISTEMA+' WHERE SistemaID = 1').data[0].ventaID;
		}
		
		private var _ventaID:int;
		public function get ventaID():int { return _ventaID; }
		public function set ventaID(value:int):void { 
			_ventaID = value;
			Global.remate.actualizar(SISTEMA,{ventaID:value},{SistemaID:1});
		}
		
	}
}