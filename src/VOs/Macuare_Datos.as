package VOs
{
	import sr.modulo.MapObject;

	[Bindable]
	public class Macuare_Datos extends MapObject
	{
		public var descripcion:String;
		public var inicio:int;
		public var macuareId:int;
		public var mDatoId:int=-1;
		public var paga:Number;
		public var fecha:String;
		public var hipodromo:String;
		public var abierta:Boolean;
		public function Macuare_Datos() 
		{
		}
	}
}