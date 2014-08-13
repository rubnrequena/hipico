package Clases.Ganador
{
	import flash.data.SQLColumnSchema;
	import flash.data.SQLSchemaResult;
	import flash.data.SQLTableSchema;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import sr.modulo.Modulo;

	public class Ganador extends Modulo {
		
		public var ventas:Ventas;
		public var premios:Premios;
		public var ganadores:Ganadores;
		public var carreras_padre:Carreras_Padre;
		public var carreras:Carrera;
		public var sistema:Sistema;
		public var topes:Topes;
		
		public function Ganador(carpeta:File) {
			addEventListener("construirEstructura",construirEstructura);
			iniciar(carpeta.resolvePath("BDGanador.db"));
		}
		
		public function inicializar():void {
			ventas = new Ventas;
			premios = new Premios;
			ganadores = new Ganadores;
			topes = new Topes;
			carreras_padre = new Carreras_Padre;
			carreras = new Carrera;
			sistema = new Sistema;
			
			checkTablas();
		}
		
		private function checkTablas():void {
			con.loadSchema(SQLTableSchema);
			var s:SQLSchemaResult = con.getSchemaResult();
			var table:SQLTableSchema;
			table = getTable(s,"Premiados");
			if (!hasColumn(table,"Premio")) {
				sql('ALTER TABLE Premiados ADD COLUMN Premio REAL');
			}
			table = getTable(s,"Ventas");
			if (!hasColumn(table,"Devuelto")) {
				sql('ALTER TABLE Ventas ADD COLUMN Devuelto BOOLEAN');
			}
		}
		private function getTable(schema:SQLSchemaResult,table:String):SQLTableSchema {
			var i:int; var len:int = schema.tables.length;
			for (i = 0; i < len; i++) {
				if (schema.tables[i].name==table) return schema.tables[i];
			}
			return null;
		}
		private function hasColumn (table:SQLTableSchema,columnName:String):Boolean {
			var i:int; var len:int = table.columns.length;
			for (i = 0; i < len; i++) {
				if (table.columns[i].name==columnName) return true;
			}
			return false;
		}
		private function construirEstructura(event:Event):void {
			sql('CREATE TABLE "Ganadores" (GanadorID INTEGER PRIMARY KEY AUTOINCREMENT, FHC TEXT, Numero INTEGER, Nombre TEXT, Paga NUMERIC, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Premios" (PremioID INTEGER PRIMARY KEY AUTOINCREMENT,FHC TEXT, Taquilla TEXT,   MontoJugado NUMERIC,   Premios NUMERIC, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Premiados" (VentaID INTEGER, FHC TEXT, Nombre TEXT, Monto REAL, Taquilla TEXT, Retirado BOOLEAN, Hora TEXT, Numero INTEGER,  BancaID INTEGER, Eliminado BOOLEAN, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER, pago BOOLEAN, Premio REAL)');
			sql('CREATE TABLE "Ventas" (VentaID INTEGER, FHC TEXT, Nombre TEXT, Monto REAL, Taquilla TEXT, Retirado BOOLEAN, Hora TEXT, Numero NUMERIC,  BancaID INTEGER, Eliminado BOOLEAN, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER, pago BOOLEAN, Devuelto BOOLEAN DEFAULT 0)');
			sql('CREATE TABLE "Sistema" (SistemaID INTEGER PRIMARY KEY AUTOINCREMENT, ventaID INTEGER)');
			sql('INSERT INTO "Sistema" (SistemaID,ventaID) VALUES (1,1)');
			sql('CREATE TABLE "Carreras" (FHC TEXT,  Nombre TEXT,Numero INTEGER, Retirado BOOLEAN, Bloqueado BOOLEAN, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Carreras_Padre" (FHC TEXT, Abierta BOOLEAN, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Topes" (topeId INTEGER PRIMARY KEY AUTOINCREMENT, banca INTEGER, hipodromo TEXT, tope INTEGER, activo BOOLEAN)');
		}
	}
}