package Clases.Ganador
{
	import flash.utils.Dictionary;
	
	import generics.Sistema;

	public class Sistema extends generics.Sistema
	{
		public function Sistema() {
			super(Global.ganador);
		}
		
		override public function set ventaID(value:int):void {
			super.ventaID = value;
			Global.ganador.actualizar(SISTEMA,{ventaID:value},{SistemaID:1});
		}
	}
}