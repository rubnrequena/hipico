package Ventanas.Bancas
{
	import UI.shared.ModalSkin;
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	public class BancasModal extends ModalSkin
	{
		private var bancas:configBancas;
		public function BancasModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			bancas = new configBancas;
			view.addElement(bancas);
			
			bancas.btnAtras.addEventListener(MouseEvent.CLICK,atrasClick);
			bancas.btnAtras.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
			
		}
		
		protected function atrasClick(event:MouseEvent):void {
			closeModal();
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void {
			if (event.keyCode==Keyboard.ESCAPE) closeModal();
		}
		
	}
}