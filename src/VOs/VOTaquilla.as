package VOs
{
	import flash.utils.ByteArray;

	public class VOTaquilla
	{
		static public const TIPOS:Array = ["GANADOR","TABLA","REMATE","MACUARE","TABLAVISOR"]
		
		static public const CONECTADO:uint=0;
		static public const CONECTANDO:uint=1;
		static public const USUARIO_INVALIDO:uint=2;
		static public const USUARIO_INACTIVO:uint=3;
		
		static public const ACTIVA_STRING:String = "Si";
		static public const INACTIVA_STRING:String = "No";
		
		public var taquillaID:String;
		public var nombre:String;
		public var banca:int;
		public var tipo:int;
		public var activa:Boolean;
		public var contrasena:String;
				
		public function get bancaString():String {
			return Global.banca.bancas.bancaByID(banca).Nombre;
		}
		public function get activaString ():String {
			return activa?ACTIVA_STRING:INACTIVA_STRING;
		}
		public function get tipoString():String {
			return VOTaquilla.TIPOS[tipo];
		}
		
		public function update (campo:String,valor:*):void {
			if (campo=="activa") valor = int(valor);
			if (valor is String) {
				valor = '"'+valor+'"';
			}
			Global.banca.sql('UPDATE Taquillas SET '+campo+' = '+valor+' WHERE taquillaID = "'+taquillaID+'"');
			this[campo]=valor;
		}
		public function get toObject():Object {
			var ba:ByteArray = new ByteArray;
			ba.writeObject(this);
			ba.position=0;
			return ba.readObject();
		}
	}
}