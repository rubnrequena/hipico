package UI.Main
{
	import UI.shared.ModalSkin;
	
	import flash.events.MouseEvent;
	
	public class PanelHipodromos extends ModalSkin
	{
		private var panel:PanelHipodromosUI;
		public function PanelHipodromos()
		{
			super();
			panel = new PanelHipodromosUI;
			view.addElement(panel);
			panel.btnAtras.addEventListener(MouseEvent.CLICK,atrasHandler);	
			panel.btnAtras.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
		}
		
		protected function atrasHandler(event:MouseEvent):void {
			closeModal();
		}
	}
}