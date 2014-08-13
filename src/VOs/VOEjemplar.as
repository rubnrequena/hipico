package VOs
{
	public class VOEjemplar
	{
		public var numero:int;
		public var nombre:String;
		
		public function VOEjemplar(numero:int=0,nombre:String="") {
			this.numero = numero;
			this.nombre = nombre;
		}
		
		public function get toObject():Object {
			var o:Object = {};
			o.Nombre = nombre;
			o.Numero = numero;
			return o;
		}
	}
}