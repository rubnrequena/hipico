package Ventanas.Bancas
{
	import appkit.responders.NResponder;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayList;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	public class configBancas extends configBancasUI
	{
		public function configBancas()
		{
			super();
			NResponder.addNative(this,FlexEvent.CREATION_COMPLETE,creationComplete,1);
		}
		protected function creationComplete(event:FlexEvent):void {
			listBancas.dataProvider = new ArrayList(Global.banca.bancas.bancas);
		}
	}
}