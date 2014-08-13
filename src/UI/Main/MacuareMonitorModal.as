package UI.Main
{
	import UI.shared.ModalSkin;
	
	import flash.events.MouseEvent;
	
	public class MacuareMonitorModal extends ModalSkin
	{
		private var mm:MonitorMacuare;
		public function MacuareMonitorModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			mm = new MonitorMacuare;
			view.addElement(mm);
			
			mm.btnAtras.addEventListener(MouseEvent.CLICK,atrasClick);
			mm.btnAtras.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
		}
		
		protected function atrasClick(event:MouseEvent):void {
			closeModal();
		}
	}
}