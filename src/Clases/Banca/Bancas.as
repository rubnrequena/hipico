package Clases.Banca
{
	import flash.data.SQLColumnSchema;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLTableSchema;
	import flash.events.EventDispatcher;

	public class Bancas extends EventDispatcher
	{
		public static const BANCAS:String = "Bancas";
		public function Bancas() {
			checkStructura();
			_bancas = Global.banca.sql('SELECT * FROM '+BANCAS+' ORDER BY ID',VOBanca).data;
			if (!_bancas) _bancas = [];
			_numBancas = _bancas.length;
		}
		
		private function checkStructura():void {
			var esquema:SQLSchemaResult = Global.banca.sqlSchema(SQLTableSchema,"Bancas");
			var tableSchema:SQLTableSchema = esquema.tables[0] as SQLTableSchema;
			var columnSchema:SQLColumnSchema;
			
			var tablas_multiplo:Boolean;
			for (var i:int = 0; i < tableSchema.columns.length; i++) {
				columnSchema = tableSchema.columns[i] as SQLColumnSchema; 
				if (columnSchema.name=="tablas_multiplo") {
					tablas_multiplo=true;
				}
			}
			if (!tablas_multiplo) {
				Global.banca.sql('ALTER TABLE Bancas ADD COLUMN tablas_multiplo REAL default 1');
			}
		}
		
		private var _numBancas:uint;
		public function get numBancas():uint { return _numBancas; }

		private var _bancas:Array;
		public function get bancas():Array {
			return _bancas;
		}
		public function bancaByID(id:int):VOBanca {
			var i:int; var bl:int = _bancas.length;
			for (i = 0; i < bl; i++) {
				if (id==_bancas[i].ID) return _bancas[i]; 
			}
			return null;
		}
		public function bancaByIndex(index:int):VOBanca {
			if (index > -1 && index <= _numBancas) {
				return _bancas[index] as VOBanca;
			}
			throw RangeError("Error de indice en bancas");
		}
		public function bancaByNombre(nombre:String):VOBanca {
			for (var i:int = 0; i < _bancas.length; i++) {
				if (nombre==_bancas[i].Nombre) return _bancas[i];
			}
			return null;
		}
		
		public function insertar (nombre:String,rif:String):VOBanca {
			var i:int; var indice:int=1;
			for (i = 0; i < numBancas; i++) {
				if (indice!=_bancas[i].ID) break;
				indice++;
			}
			var bnc:VOBanca = new VOBanca;
			bnc.Nombre = nombre;
			bnc.RIF = rif;
			bnc.ID = indice;
			bnc.macuare_tope = 0;
			bnc.remate_porcentaje = 30;
			bnc.tablas_cantidad = 0;
			bnc.tablas_paga = 0;
            bnc.tablas_multiplo = 1;
			
			_bancas.splice(indice,0,bnc);
			_bancas.sortOn("ID",Array.NUMERIC);
			
			_numBancas++;
			Global.banca.insertar(BANCAS,bnc.toObject);
			//Global.banca.insertar(BANCAS,{ID:indice,Nombre:nombre,RIF:rif,remate_porcentaje:30,tablas_cantidad:0,tablas_paga:0,macuare_tope:0});
			//Global.db.sInsertar("Penas",[bnc]);
			/*var carreras:Array = Global.db.Leer_Multi("Carreras_Padre",[{Fecha:Misc.formatFecha()}],"AND","*","Carrera").toArray();
			if (carreras && carreras.length>0) {
				for (i = 0; i < carreras.length; i++) {
					carreras[i].bancaID = indice; 
				}
				Global.db.buildUnion("Carreras_Padre","Fecha,Carrera,Hipodromo,Abierta,bancaID",carreras);
			}*/
			return bnc;
		}
		public function remover(bancaID:int):void {
			Global.banca.eliminar(BANCAS,{ID:bancaID});
			for (var i:int = 0; i < _numBancas; i++) {
				if (_bancas[i].ID==bancaID) {
					_bancas.splice(i,1);
					_numBancas--;
					break;
				}
			}
		}
	}
}