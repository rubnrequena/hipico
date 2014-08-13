package VOs
{
	public class VOTaquillaPremio
	{
		public var banca:int;
		public var taquilla:String;
		public var ventas:Array;
		
		public var jugado:Number;
		public var premio:Number=0;
		
		public var ganadores:Array;
		
		public function VOTaquillaPremio(banca:int,taquilla:String,venta:Object) {
			this.banca = banca;
			this.taquilla = taquilla;
			ventas = [venta];
			jugado = venta.Monto;
			ganadores = [];
		}
		
		public function addVenta(v:Object):void {
			ventas.push(v);
			jugado += v.Monto;
		}
	}
}