package VOs
{
	import sr.modulo.MapObject;
	
	public final class BancaTabla extends MapObject
	{
		public static var bancasPermitidas:Array;
		
		public var banca:String;
		public var paga:int;
		public var tabla:Array;
				
		public function BancaTabla()
		{
			super();
		}
	}
}