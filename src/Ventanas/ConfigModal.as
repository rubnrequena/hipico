package Ventanas
{
	import UI.shared.ModalSkin;
	
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	public class ConfigModal extends ModalSkin
	{
		private var config:wConfig;
		public function ConfigModal(width:int=0, height:int=0)
		{
			super(width, height);
			
			config = new wConfig;
			view.addElement(config);
			
			config.addEventListener(FlexEvent.CREATION_COMPLETE,onComplete,false,0,true);
		}
		
		protected function onComplete(event:FlexEvent):void {			
			config.btnAtras.addEventListener(MouseEvent.CLICK,atrasClick);
			config.btnAtras.setStyle("chromeColor",CANCEL_COLOR_BUTTON);
		}
		
		protected function atrasClick(event:MouseEvent):void {
			closeModal();
		}
	}
}