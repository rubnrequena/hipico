package VOs
{
	public class VOTablaPremio extends VOTaquillaPremio
	{
		public var tablaPaga:int;
		public function VOTablaPremio(banca:int, taquilla:String, venta:Object) {
			super(banca, taquilla, venta);
			jugado = Number(venta.Monto)*int(venta.Cantidad)
		}
		
		override public function addVenta(v:Object):void {
			ventas.push(v);
			jugado += Number(v.Monto)*int(v.Cantidad);
		}
	}
}