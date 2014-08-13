package Clases.Banca {
	import sr.modulo.MapObject;

	public class VOBanca extends MapObject {
		public var Nombre:String;
		public var ID:int;
		public var RIF:String;
		public var remate_porcentaje:int;
		public var macuare_tope:Number;
		public var tablas_cantidad:int;
		public var tablas_paga:Number;
		public var tablas_multiplo:Number;
		
		public function VOBanca() { }
		
		private var _numMacuares:int;
		public function get numMacuares():int { return _numMacuares; }
		public function set numMacuares(value:int):void { _numMacuares = value; }
		
		private var _numGanadores:int;
		public function get numGanadores():int { return _numGanadores; }
		public function set numGanadores(value:int):void { _numGanadores = value; }
		
		private var _numTablas:int;
		public function get numTablas():int { return _numTablas; }
		public function set numTablas(value:int):void { _numTablas = value; }
		
		private var _numRemates:int;
		public function get numRemates():int { return _numRemates; }
		public function set numRemates(value:int):void { _numRemates = value; }
		
		public function get numTaquillas():int { return _numGanadores+_numTablas+_numRemates; }
		
		public function mod (campo:String,valor:*):void {
			if (this[campo]!=valor) {
				Global.banca.sql('UPDATE Bancas SET '+campo+' = "'+valor+'" WHERE ID = '+ID);
				this[campo] = valor;
			}
		}

        public function dividendo(div:Number, hipodromo:String, empate:Boolean = false):Number {
            return Global.banca.dividendos.dividendo(ID,hipodromo,div,empate);
        }
		
		override public function get toObject():Object {
			var o:Object = {};
			o.Nombre = Nombre;
			o.ID = ID;
			o.RIF = RIF;
			o.remate_porcentaje = remate_porcentaje;
			o.macuare_tope = macuare_tope;
			o.tablas_cantidad = tablas_cantidad;
			o.tablas_paga = tablas_paga;
			o.tablas_multiplo = tablas_multiplo;
			return o;
		}
	}
}