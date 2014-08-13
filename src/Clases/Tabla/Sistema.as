package Clases.Tabla
{
	import generics.Sistema;

	public class Sistema extends generics.Sistema
	{
		public function Sistema() {
			super(Global.tablas);
		}
		override public function set ventaID(value:int):void {
			super.ventaID = value;
			Global.tablas.actualizar(SISTEMA,{ventaID:value},{SistemaID:1});
		}
	}
}