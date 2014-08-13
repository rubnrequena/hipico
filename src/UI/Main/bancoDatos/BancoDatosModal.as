package UI.Main.bancoDatos
{
	import UI.shared.ModalSkin;
	
	import flash.events.MouseEvent;
	
	public class BancoDatosModal extends ModalSkin
	{
		private var banco:bancoDatos;
		public function BancoDatosModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			banco = new bancoDatos;
			view.addElement(banco);
			
			banco.btnCerrar.addEventListener(MouseEvent.CLICK,atrasClick);
		}
		
		protected function atrasClick(event:MouseEvent):void {
			closeModal();
		}
	}
}