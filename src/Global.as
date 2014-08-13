package
{

import Clases.Banca.Banca;
import Clases.Ganador.Ganador;
import Clases.Macuare.Macuare;
import Clases.Remate.Remate;
import Clases.Tabla.Tabla;
import Clases.network.netManager;

import UI.Noticia;

import VOs.ExternalOpcion;

import core.Registros;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.media.Sound;
import flash.net.SharedObject;
import flash.net.URLRequest;
import flash.net.registerClassAlias;
import flash.utils.Timer;

import spark.formatters.NumberFormatter;

public class Global
	{
		//static public var recibeChat:Signal = new Signal;
		static public var noticia:Noticia = new Noticia;
		static public var registros:Registros;
        static public var extOptions:ExternalOpcion;
		// Iniciar modulos
		static public var net:netManager;
		static public var ganador:Ganador;
		static public var banca:Banca;
		static public var tablas:Tabla;
		static public var remate:Remate;
		static public var macuare:Macuare;
		
		static public var nf:NumberFormatter;
		static public function iniciarModulos():void {
			iniciarExtOptions();            

			var so:SharedObject = SharedObject.getLocal("Hipico");
			var carpetaBD:File = new File(so.data.carpetaBD);
			banca = new Banca(carpetaBD);
			ganador = new Ganador(carpetaBD);
			tablas = new Tabla(carpetaBD);
			remate = new Remate(carpetaBD);
			macuare = new Macuare(carpetaBD);
			
			banca.inicializar();
			ganador.inicializar();
			tablas.inicializar();
			remate.inicializar();
			macuare.inicializar();
			
			//chatManager = new ChatManager;
			
			nf = new NumberFormatter;
			nf.decimalSeparator = ",";
			nf.groupingSeparator = ".";
			nf.fractionalDigits = 2;


		}
		
		public static function iniciarExtOptions():void {
			registerClassAlias("extOpt",VOs.ExternalOpcion);
			var fs:FileStream = new FileStream()
			if (ExternalOpcion.externalFile.exists){
				fs.open(ExternalOpcion.externalFile,FileMode.READ);
				extOptions = fs.readObject();
			} else {
				extOptions = new ExternalOpcion();
				fs.open(ExternalOpcion.externalFile,FileMode.WRITE);
				fs.writeObject(extOptions);
			}
			fs.close();
			fs=null;
		}
		
		public static function closeBD(name:String):void {
			switch(name) {
				case "BDGanador.db": { ganador.close(); break; }
				case "BDTablas.db": { tablas.close(); break; }
				case "BDBanca.db": { banca.close(); break; }
				case "BDMacuare.db": { macuare.close(); break; }
				case "BDRemate.db": { remate.close(); break; }
			}
		}
		
		//Iniciar Configuracion
		static public var db:*;
				
		//Sonido de alarma
		static private var beepSnd:Sound = new Sound(new URLRequest("alerta.mp3"));
		static private var beepTimer:Timer = new Timer(200,3)
		public static var isAdmin:Boolean=false;
		static public function beep(repetir:int=0):void {
			beepSnd.play(0,repetir);
		}
		public function Global()
		{
		}
	}
}