package Clases.Tabla
{
	import flash.data.SQLSchemaResult;
	import flash.data.SQLTableSchema;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import sr.modulo.Modulo;

	public class Tabla extends Modulo {
		
		public var ventas:Ventas;
		public var premios:Premios;
		public var ganadores:Ganadores;
		public var tablas_padre:Tablas_Padre;
		public var tablas:Tablas;
		public var sistema:Sistema;
		public var rangos:Tablas_Rangos;
		
		public function Tabla(carpeta:File) {
			addEventListener("construirEstructura",construirEstructura);
			iniciar(carpeta.resolvePath("BDTabla.db"));
		}
		
		public function inicializar():void {
			ventas = new Ventas;
			premios = new Premios;
			ganadores = new Ganadores;
			tablas_padre = new Tablas_Padre;
			tablas = new Tablas;
			sistema = new Sistema;
			rangos = new Tablas_Rangos;
			
			checkTablas();
		}
		
		private function checkTablas():void {
			con.loadSchema(SQLTableSchema);
			var s:SQLSchemaResult = con.getSchemaResult();
			var table:SQLTableSchema = getTable(s,"Premiados");
			if (!hasColumn(table,"Premio")) {
				sql('ALTER TABLE Premiados ADD COLUMN Premio REAL DEFAULT 0');
			}
			table = getTable(s,"Ventas");
			trace("hasColumn",hasColumn(table,"Devuelto"));
			if (hasColumn(table,"Devuelto")==false) {
				sql('ALTER TABLE Ventas ADD COLUMN Devuelto BOOLEAN DEFAULT 0');
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
		
		public function guardarTablas(tablasPadre:Array,tablas:Array):void {
			insertarUnion(Tablas_Padre.TABLAS_PADRE,tablasPadre);
			for (var i:int = 0; i < tablas.length; i++) {
				tablas[i].Nombre = String(tablas[i].Nombre).split("'").join("");
				if (tablas[i].hasOwnProperty("Cantidad")) {
					tablas[i].Tablas = tablas[i].Cantidad;
					delete tablas[i].Cantidad;
				}
				if (tablas[i].hasOwnProperty("nCarrera")) {
					tablas[i].Carrera = tablas[i].nCarrera;
					delete tablas[i].nCarrera;
				}
				if (!tablas[i].FHC) {
					tablas[i].FHC = Modulo.fhc(tablas[i].Fecha,tablas[i].Hipodromo,tablas[i].Carrera);
				}
			}
			insertarUnion(Tablas.TABLAS,tablas);
		}
		public function reiniciarTablas(bancas:Vector.<int>,fhc:String):void {
			if (bancas.length>0) {
				var s:Array = new Array;
				for (var i:int = 0; i < bancas.length; i++) { s.push('BancaID = '+bancas[i]); }
				Global.tablas.sql('DELETE FROM '+Tablas.TABLAS+' WHERE FHC = "'+fhc+'" AND ('+s.join(' OR ')+')');
				Global.tablas.sql('DELETE FROM '+Tablas_Padre.TABLAS_PADRE+' WHERE FHC = "'+fhc+'" AND ('+s.join(' OR ')+')');
				s=null;
			}
		}
		private function construirEstructura(event:Event):void {
			sql('CREATE TABLE "Ganadores" (GanadorID INTEGER PRIMARY KEY AUTOINCREMENT, FHC TEXT, Numero INTEGER, Nombre TEXT, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Premios" (PremioID INTEGER PRIMARY KEY AUTOINCREMENT,FHC TEXT, Taquilla TEXT,   MontoJugado NUMERIC,   Premios NUMERIC, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Sistema" (SistemaID INTEGER PRIMARY KEY AUTOINCREMENT, ventaID INTEGER)');
			sql('INSERT INTO "Sistema" (SistemaID,ventaID) VALUES (1,1)');
			sql('CREATE TABLE "Ventas" (VentaID INTEGER, FHC TEXT, Nombre TEXT, Monto NUMERIC, Cantidad INTEGER, Taquilla TEXT, Retirado BOOLEAN, Hora TEXT, Numero NUMERIC,  BancaID INTEGER, Eliminado BOOLEAN, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER, pago BOOLEAN, Devuelto BOOLEAN DEFAULT 0)');
			sql('CREATE TABLE "Tablas" (FHC TEXT,  Nombre TEXT, Numero INTEGER, Tablas INTEGER, Monto INTEGER, Retirado BOOLEAN, Bloqueado BOOLEAN, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Tablas_Padre" (FHC TEXT, Abierta BOOLEAN, Paga INTEGER, Porcentaje INTEGER, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Tablas_Rangos" (RangoID INTEGER PRIMARY KEY AUTOINCREMENT, Minimo INTEGER, Maximo INTEGER, Tablas INTEGER)');
			sql('CREATE TABLE "Premiados" (VentaID INTEGER, FHC TEXT, Nombre TEXT, Monto NUMERIC, Cantidad INTEGER, Taquilla TEXT, Retirado BOOLEAN, Hora TEXT, Numero NUMERIC,  BancaID INTEGER, Eliminado BOOLEAN, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER, pago BOOLEAN, Premio REAL)');
		}
	}
}