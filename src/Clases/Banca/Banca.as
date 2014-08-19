package Clases.Banca
{
import flash.data.SQLSchemaResult;
import flash.data.SQLTableSchema;
import flash.events.Event;
import flash.filesystem.File;

import mx.utils.BitFlagUtil;

import sr.modulo.Modulo;

public class Banca extends Modulo
	{
		public function Banca(carpeta:File) {
			addEventListener("construirEstructura",construirEstructura_handler);
			iniciar(carpeta.resolvePath("BDBanca.db"));
		}
		private var _hipodromos:Hipodromos;
		public function get hipodromos():Hipodromos { return _hipodromos; }
		
		private var _carreras:Carreras;
		public function get carreras():Carreras { return _carreras; }
		
		private var _ejemplares:Ejemplares;
		public function get ejemplares():Ejemplares { return _ejemplares; }
		
		private var _config:Configuracion;
		public function get config():Configuracion { return _config; }
		
		private var _bancas:Bancas;
		public function get bancas():Bancas {
			return _bancas;
		}
        private var _dividendos:Dividendos;
        public function get dividendos():Dividendos {
            return _dividendos;
        }
        private var _taquillas:Taquillas;
		public function get taquillas():Taquillas {
			return _taquillas;
		}


        public function inicializar():void {
            checkEstructura();
			_carreras = new Carreras;
			_hipodromos = new Hipodromos;
			_bancas = new Bancas;
			_config = new Configuracion;
			_ejemplares = new Ejemplares;
            _dividendos = new Dividendos;
			_taquillas = new Taquillas;
		}

        private function checkEstructura():void {
            var esquema:SQLSchemaResult = Global.banca.sqlSchema(SQLTableSchema);
            var tableSchema:SQLTableSchema;

            var tablas:uint;
            for (var i:int = 0; i < esquema.tables.length; i++) {
                tableSchema = esquema.tables[i] as SQLTableSchema;
                if (tableSchema.name == "Dividendos") tablas = BitFlagUtil.update(tablas,0x01,true);
				if (tableSchema.name == "Hipodromos") tablas = BitFlagUtil.update(tablas,0x02,true);
				if (tableSchema.name == "Taquillas") tablas = BitFlagUtil.update(tablas,0x04,true);
            }
            if (BitFlagUtil.isSet(tablas,0x01)==false) {
                Global.banca.sql('CREATE TABLE "Dividendos" (divID INTEGER PRIMARY KEY AUTOINCREMENT,  bancaID INTEGER, hipodromos TEXT, rangos TEXT, empate REAL DEFAULT 0, tope REAL DEFAULT 0)');
            }
			if (BitFlagUtil.isSet(tablas,0x02)==false) {
				sql('CREATE TABLE "Hipodromos" (Hipodromo TEXT PRIMARY KEY, Ganador REAL)');
				insertarUnion("Hipodromos",[{Hipodromo:"VALENCIA",Ganador:5},{Hipodromo:"SANTA RITA",Ganador:5},{Hipodromo:"RINCONADA",Ganador:5},{Hipodromo:"RANCHO ALEGRE",Ganador:2}]);
			}
			if (BitFlagUtil.isSet(tablas,0x04)==false) {
				sql('CREATE TABLE Taquillas (taquillaID TEXT PRIMARY KEY, nombre TEXT, banca INTEGER, activa BOOLEAN, contrasena TEXT, tipo INTEGER)');
			}
        }
		
		protected function construirEstructura_handler(event:Event):void {
			sql('CREATE TABLE Carreras (FHC TEXT, Fecha TEXT, Hipodromo TEXT, Carrera INTEGER, Numero INTEGER, Nombre TEXT, Retirado BOOLEAN)');
			sql('CREATE TABLE Bancas (Nombre TEXT PRIMARY KEY, ID INTEGER, RIF TEXT, remate_porcentaje INTEGER, tablas_cantidad INTEGER, tablas_paga REAL, tablas_multiplo REAL, macuare_tope INTEGER)');
			sql('INSERT INTO Bancas (Nombre,ID,RIF,remate_porcentaje,tablas_cantidad,tablas_paga,tablas_multiplo,macuare_tope) VALUES ("BANCA",1,"J-00000000-0",30,20,260,1,500)');
			sql('CREATE TABLE "Hipodromos" (Hipodromo TEXT PRIMARY KEY, Ganador REAL)');
			insertarUnion("Hipodromos",[{Hipodromo:"VALENCIA",Ganador:5},{Hipodromo:"SANTA RITA",Ganador:5},{Hipodromo:"RINCONADA",Ganador:5},{Hipodromo:"RANCHO ALEGRE",Ganador:5}]);
			sql('CREATE TABLE "Ejemplares" (Nombres TEXT PRIMARY KEY)');
			sql('CREATE TABLE "Dividendos" (divID INTEGER PRIMARY KEY AUTOINCREMENT,  bancaID INTEGER, hipodromos TEXT, rangos TEXT, empate REAL DEFAULT 0, tope REAL DEFAULT 0)');
			sql('CREATE TABLE "Config" (Configid INTEGER PRIMARY KEY AUTOINCREMENT,  Nombre TEXT,  Valor TEXT,  Info TEXT)');
			sql('CREATE TABLE Taquillas (taquillaID TEXT PRIMARY KEY, nombre TEXT, banca INTEGER, activa BOOLEAN, contrasena TEXT, tipo INTEGER)');
			var configData:Array = [];
			configData.push({Nombre:"enviarDoble",Valor:"0",Info:"Establece si ademas de las tablas originales se almacenará una segunda tabla duplicando todos los valores."});
			configData.push({Nombre:"tablaPorcentaje",Valor:"30",Info:"Establece el porcentaje de ganacia de la casa por tabla."});
			configData.push({Nombre:"publicarTablasUI",Valor:"0",Info:""});
			configData.push({Nombre:"contrasena",Valor:"admin",Info:"Contraseña de acceso"});
			configData.push({Nombre:"servidorLocal",Valor:"0.0.0.0",Info:"Dirección IP del servidor local"});
			configData.push({Nombre:"servidorWeb",Valor:"http://sistemasrequena.com/apps/hipico/",Info:""});
			configData.push({Nombre:"webID",Valor:"master",Info:""});
			configData.push({Nombre:"inicioTaquillas",Valor:"1",Info:"Establece si las carreras inician abiertas o cerradas"});
			configData.push({Nombre:"agruparBalance",Valor:"1",Info:""});
			configData.push({Nombre:"publicarTablas",Valor:"0",Info:"Establece si las tablas a guardar serán o no publicadas en la nube."});
			configData.push({Nombre:"tablasWebAllowed",Valor:"goldplaza,goldpena,mrpasta,muralla",Info:""});
			insertarUnion("Config",configData);
			configData=null;
		}
	}
}