package Clases.Ganador
{
	import VOs.VODividendo;

	public class VOPremiar
	{
		public var banca:int;
		public var dividendos:Vector.<VODividendo>;
		
		public function VOPremiar() {
			dividendos = new Vector.<VODividendo>;
		}
	}
}