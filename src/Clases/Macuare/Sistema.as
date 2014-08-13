package Clases.Macuare
{
	public class Sistema
	{
		public static const SISTEMA:String = "Sistema";
		
		private var _allVentas:Vector.<uint>;
		public function Sistema() {
			_ventaID = Global.macuare.sql('SELECT * FROM '+SISTEMA+' WHERE SistemaID = 1').data[0].ventaID;
			
			var ventas:Array = Global.macuare.sql("SELECT VentaID FROM Ventas").data;
			var i:int; var l:int = ventas?ventas.length:0; var o:Object;
			_allVentas = new Vector.<uint>;
			for (i = 0; i < l; i++) {
				_allVentas.push(ventas[i].VentaID);
			}
			ventas=null;
		}
		
		private var _ventaID:int;
		public function get ventaID():int {
			if (Global.extOptions.randomID) {
				var valid:Boolean=true;
				while (valid){
					_ventaID = Math.random()*Global.extOptions.randomSeed;
					valid = findID(_ventaID);
				}
				_allVentas.push(_ventaID);
				return _ventaID;
			} else {
				ventaID = ++_ventaID;
				return _ventaID;
			}
		}
		private function findID(n:int):Boolean {
			var i:int; var l:int = _allVentas.length;
			for (i = 0; i < l; i++) {
				if (_allVentas[i]==n) return true;	
			}
			return false;
		}
		public function set ventaID(value:int):void { 
			_ventaID = value;
			Global.ganador.actualizar(SISTEMA,{ventaID:value},{SistemaID:1});
		}
	}
}