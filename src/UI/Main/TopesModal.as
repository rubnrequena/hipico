package UI.Main
{
	import UI.Main.Topes.wTope;
	import UI.shared.ModalSkin;
	
	import flash.events.MouseEvent;
	
	public class TopesModal extends ModalSkin
	{
		private var topes:wTope;
		public function TopesModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			topes = new wTope;
			view.addElement(topes);
			topes.btnAtras.addEventListener(MouseEvent.CLICK,atrasClick);
			topes.btnAtras.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
		}
		
		protected function atrasClick(event:MouseEvent):void {
			closeModal();
		}
	}
}