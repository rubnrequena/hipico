package generics
{
	import flash.utils.Dictionary;
	
	import sr.modulo.Modulo;
	
	public class Sistema
	{
		public static const SISTEMA:String = "Sistema";
		
		private var _allVentas:Dictionary;
		private var _numVentas:int;
		private var _seed:int;
		public function Sistema(modulo:Modulo) {
			var ventas:Array = modulo.sql("SELECT VentaID FROM Ventas GROUP BY VentaID ORDER BY VentaID ASC").data;
			var i:int;
			if (ventas) {
				_numVentas=ventas.length;
				_ventaID = ventas[_numVentas-1].VentaID;
			}
			_allVentas = new Dictionary;
			for (i = 0; i < _numVentas; i++) {
				_allVentas[i] = true;
			}
			ventas=null;
			_seed = Global.extOptions.randomSeed;
		}
		
		private var _ventaID:int;
		private var low:int;
		private var high:int;
		private var mid:int;
		private var valid:Boolean;

		
		public function get ventaID():int {
			if (Global.extOptions.randomID) {
				if (_numVentas>_seed*0.8) {
					_seed += 100000;
					Global.extOptions.randomSeed = _seed;
					Global.extOptions.save();
				}
				valid=true;
				while (valid){
					_ventaID = int(Math.random()*Global.extOptions.randomSeed);
					valid = _ventaID in _allVentas;
				}
				_allVentas[_ventaID]=true;
				_numVentas++;
				return _ventaID;
			} else {
				ventaID = ++_ventaID;
				return _ventaID;
			}
		}
		/*
		only for vector base list
		private function findID(n:int):Boolean {
			var i:int; var l:int = _allVentas.length;
			low = 0;
			high = l-1;
			while (low <= high) {
				mid = low + (high-low)/2;
				if (_allVentas[mid] > n) {
					high = mid-1;
				}
				else if (_allVentas[mid] < n) {
					low = mid+1;
				} else {
					return true
				}
			}
			return false;
		}*/
		public function set ventaID(value:int):void { 
			_ventaID = value;
		}
	}
}