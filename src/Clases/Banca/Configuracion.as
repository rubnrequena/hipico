package Clases.Banca
{
	public class Configuracion {
		public var enviarDoble:Boolean;
		public var publicarTablas:Boolean;
		public var publicarTablasUI:Boolean;
		public var agruparBalance:int;
		public var inicioTaquillas:Boolean;
		public var servidorLocal:String;
		public var tablaPorcentaje:int;
		public var contrasena:String;
		public var tablasWebAllowed:String;
		public var servidorWeb:String;
		public var webID:String;
		public var dividendoGanador:Number=-1;
		
		public function Configuracion() {
			var _config:Array = Global.banca.sql("SELECT * FROM Config").data;
			for (var i:int = 0; i < _config.length; i++) {
				this[_config[i].Nombre] = type(_config[i].Valor);
			}
			if (dividendoGanador<0) {
				Global.banca.insertar("Config",{Nombre:"dividendoGanador",valor:2,info:"Dividendo para ganadores"});
				dividendoGanador = 2;
			}
		}
		
		private function type(valor:String):* {
			if (!isNaN(Number(valor)))
				return int(valor);
			return valor;
		}
		
		public function setConfig(campo:String,valor:*):void {
			Global.banca.actualizar("Config",{Valor:valor},{Nombre:campo});
			this[campo]=valor;
		}
	}
}