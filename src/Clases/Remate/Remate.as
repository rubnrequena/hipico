package Clases.Remate
{
	import sr.modulo.Modulo;
	
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class Remate extends Modulo {
		
		public var premios:Premios;
		public var ganadores:Ganadores;
		public var carreras:Carrera;
		public var sistema:Sistema;
		
		public function Remate(carpeta:File) {
			addEventListener("construirEstructura",construirEstructura);
			iniciar(carpeta.resolvePath("BDRemate.db"));
		}
		
		public function inicializar():void {
			premios = new Premios;
			ganadores = new Ganadores;
			carreras = new Carrera;
			sistema = new Sistema;
		}
		
		private function construirEstructura(event:Event):void {
			sql('CREATE TABLE "Premios" (PremioID INTEGER PRIMARY KEY AUTOINCREMENT,FHC TEXT, Taquilla TEXT,   MontoJugado NUMERIC,   Premios NUMERIC, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Ganadores" (GanadorID INTEGER PRIMARY KEY AUTOINCREMENT, FHC TEXT, Numero INTEGER, Nombre TEXT, Paga NUMERIC, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE "Carreras" (FHC TEXT,  Nombre TEXT,Numero INTEGER, Retirado BOOLEAN, Bloqueado BOOLEAN, BancaID INTEGER, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER)');
			sql('CREATE TABLE Sistema (SistemaID INTEGER PRIMARY KEY AUTOINCREMENT, ventaID INTEGER)');
			sql('INSERT INTO Sistema (SistemaID,ventaID) VALUES (1,1)');
		}
	}
}