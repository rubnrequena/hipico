package VOs
{
	import Common.Misc;
	
	import sr.modulo.MapObject;

	public class VOCarrera
	{
		public var fecha:String;
		public var hipodromo:String;
		public var carrera:int;
		
		public function get FHC():String {
			return fecha.split("-").join("")+hipodromo+Misc.fillZeros(carrera,2);
		}
		public function get FH():String {
			return fecha+hipodromo;
		}
		public function get toDB():Object {
			var o:Object = {};
			o.Fecha = fecha;
			o.Hipodromo = hipodromo;
			o.Carrera = carrera;
			return o;
		}
		public function VOCarrera()
		{
			
		}
	}
}