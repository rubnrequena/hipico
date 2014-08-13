package Comps.Macuare
{
	import UI.shared.ModalSkin;
	
	import flash.events.MouseEvent;
	
	public class MacuarePremiarModal extends ModalSkin
	{
		private var mp:wPermiarMacuare;
		public function MacuarePremiarModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			mp = new wPermiarMacuare;
			view.addElement(mp);
			
			mp.btnCerrar.addEventListener(MouseEvent.CLICK,atrasClick);
			mp.btnCerrar.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
		}
		
		protected function atrasClick(event:MouseEvent):void {
			closeModal();
		}
	}
}