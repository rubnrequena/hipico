package VOs
{
	public class VODividendo
	{
		public var numero:int;
		public var ejemplar:String;
		public var dividendo:Number;
		public function VODividendo(numero:int,ejemplar:String,dividendo:Number) {
			this.numero = numero;
			this.ejemplar = ejemplar;
			this.dividendo = dividendo;
		}
		public function get toObject():Object {
			var o:Object = {};
			o.Numero = numero;
			o.Nombre = ejemplar;
			o.Paga = dividendo;
			return o;
		}
	}
}