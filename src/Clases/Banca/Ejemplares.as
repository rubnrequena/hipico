package Clases.Banca
{
	import VOs.VOEjemplar;

	public class Ejemplares
	{
		public static const EJEMPLARES:String = "Ejemplares";
		public function Ejemplares() {
			_data = Global.banca.sql('SELECT * FROM '+EJEMPLARES).data;
			_numEjemplares = _data?_data.length:0;
		}
		
		private var _data:Array;
		public function get datos():Array { return _data; }
		
		public function insertar (nombre:String):void {
			for (var i:int = 0; i < _numEjemplares; i++) {
				if (nombre==_data[i].Nombres) return;
			}
			_data.push({Nombres:nombre});
			Global.banca.insertar(EJEMPLARES,{Nombres:nombre});
			_numEjemplares++;
		}

		private var _numEjemplares:int;
		public function get numCaballos():int {
			return _numEjemplares;
		}

	}
}