package Clases.Macuare
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import sr.modulo.Modulo;

	public class Macuare extends Modulo {
		
		static public const MACUARES:String = "Macuares";
		public static const VENTAS:String = "Ventas";
		public static const PREMIOS:String = "Premios";
		public static const PREMIADOS:String = "Premiados";
		public static const SISTEMA:String = "Sistema";
		public static const CARRERAS:String = "Carreras";
		public static const GANADORES:String = "Ganadores";
		
		public var macuares:Macuares;
		public var ventas:Ventas;
		public var premios:Premios;
		public var ganadores:Ganadores;
		public var carreras:Carreras;
		public var sistema:Sistema;
		public function get chances():Array {
			return Global.macuare.sql('SELECT * FROM Chances').data;
		}
		public function set chances(value:Array):void {
			Global.macuare.sql("DELETE FROM Chances");
			Global.macuare.insertarUnion("Chances",value);
		}
		
		public function Macuare(carpeta:File) {
			addEventListener("construirEstructura",construirEstructura);
			iniciar(carpeta.resolvePath("BDMacuare.db"));
		}
		public function inicializar():void {
			macuares = new Macuares;
			ventas = new Ventas;
			premios = new Premios;
			ganadores = new Ganadores;
			carreras = new Carreras;
			sistema = new Sistema;
		}
		private function construirEstructura(event:Event):void {
			sql('CREATE TABLE "Macuares" (macuareId INTEGER PRIMARY KEY AUTOINCREMENT,   fecha TEXT,   hipodromo TEXT)');
			sql('CREATE TABLE "Carreras" (mDatoId INTEGER PRIMARY KEY AUTOINCREMENT,  descripcion TEXT,  paga REAL,  inicio INTEGER,  macuareId INTEGER, abierta BOOLEAN)');
			sql('CREATE TABLE "Chances" (mChanceID INTEGER PRIMARY KEY AUTOINCREMENT, minimo INTEGER, maximo INTEGER, chance INTEGER)');
			sql('INSERT INTO "Chances" (mChanceID,minimo,maximo,chance) VALUES (1,4,6,1)');
			sql('INSERT INTO "Chances" (mChanceID,minimo,maximo,chance) VALUES (2,7,9,2)');
			sql('INSERT INTO "Chances" (mChanceID,minimo,maximo,chance) VALUES (3,10,20,3)');
			sql('CREATE TABLE "Premiados" (mVentaId INTEGER PRIMARY KEY,   mDatoId INTEGER,   monto REAL,   taquilla TEXT,  nombre TEXT,  fecha TEXT,  hora TEXT, bancaID INTEGER, ejemplares TEXT, hipodromo TEXT, eliminado BOOLEAN, pago BOOLEAN,premio NUMERIC)');
			sql('CREATE TABLE "Premios" (mPremio INTEGER PRIMARY KEY AUTOINCREMENT, mDatoId INTEGER, jugado REAL, premio REAL, bancaID INTEGER, fecha TEXT, hipodromo TEXT, taquilla TEXT)');
			sql('CREATE TABLE "Ventas" (VentaID INTEGER PRIMARY KEY,   mDatoId INTEGER,   monto REAL,   taquilla TEXT,  nombre TEXT,  fecha TEXT,  hora TEXT, bancaID INTEGER, ejemplares TEXT, hipodromo TEXT, eliminado BOOLEAN, pago BOOLEAN)');
			sql('CREATE TABLE "Sistema" (SistemaID INTEGER PRIMARY KEY AUTOINCREMENT, ventaID INTEGER)');
			sql('INSERT INTO "Sistema" (SistemaID,ventaID) VALUES (1,1)');
		}
	}
}